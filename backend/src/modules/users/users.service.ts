/**
 * @file        users.service.ts
 * @module      UsersModule
 * @description Service xử lý nghiệp vụ Users và Points của TingTing.
 *
 * @responsibility
 *   - Trả về thông tin profile và lịch sử giao dịch của User đang đăng nhập
 *   - Trả về số dư điểm hiện tại của User
 *   - Cộng điểm cho User sau khi giao dịch tại Merchant (Merchant only)
 *     + Tính điểm theo POINTS_RATIO từ biến môi trường
 *     + Cập nhật membership_tier nếu vượt ngưỡng
 *     + Dùng PostgreSQL Row-Level Lock (SELECT FOR UPDATE) chống race condition
 *
 * @dependencies
 *   - TypeORM (DataSource, Repository)
 *   - ConfigService (đọc POINTS_RATIO, MEMBERSHIP_TIERS_CONFIG từ .env)
 *
 * @todo
 *   - [ ] Cache GET /users/me bằng Redis để giảm tải DB khi nhiều user đồng thời
 *   - [ ] Phát sự kiện WebSocket khi cộng điểm thành công (Task 1.5)
 */

import {
  Injectable,
  NotFoundException,
  Logger,
  BadRequestException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { DataSource, Repository } from "typeorm";
import { ConfigService } from "@nestjs/config";

import { User } from "./entities/user.entity";
import {
  Transaction,
  TransactionType,
} from "../transactions/entities/transaction.entity";
import { Merchant } from "../merchants/entities/merchant.entity";
import { EarnPointsDto } from "./dto/earn-points.dto";

// ==========================================
// KIỂU DỮ LIỆU HỖ TRỢ
// ==========================================

/**
 * Cấu hình ngưỡng điểm cho từng hạng thành viên.
 * Ví dụ: { STANDARD: 0, SILVER: 1000, GOLD: 5000, PLATINUM: 20000 }
 */
type MembershipTiersConfig = Record<string, number>;

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  /**
   * Tỉ lệ đổi tiền → điểm: cứ POINTS_RATIO đồng = 1 điểm.
   * Đọc từ biến môi trường POINTS_RATIO (mặc định 1000).
   */
  private readonly pointsRatio: number;

  /**
   * Cấu hình ngưỡng điểm từng hạng, parse từ MEMBERSHIP_TIERS_CONFIG JSON.
   * Các tier được sắp xếp giảm dần để so sánh từ cao đến thấp.
   */
  private readonly membershipTiers: Array<{ tier: string; minPoints: number }>;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    @InjectRepository(Transaction)
    private readonly transactionRepository: Repository<Transaction>,

    @InjectRepository(Merchant)
    private readonly merchantRepository: Repository<Merchant>,

    // DataSource dùng để tạo QueryRunner cho Row-Level Lock transaction
    private readonly dataSource: DataSource,

    private readonly configService: ConfigService,
  ) {
    // Đọc POINTS_RATIO từ .env, mặc định 1000 (1.000đ = 1 điểm)
    this.pointsRatio = parseInt(
      this.configService.get<string>("POINTS_RATIO") || "1000",
      10,
    );

    // Parse MEMBERSHIP_TIERS_CONFIG từ JSON string trong .env
    // Sắp xếp giảm dần theo minPoints để dễ so sánh tier cao → thấp
    const tiersConfig = JSON.parse(
      this.configService.get<string>("MEMBERSHIP_TIERS_CONFIG") ||
        '{"STANDARD":0,"SILVER":1000,"GOLD":5000,"PLATINUM":20000}',
    ) as MembershipTiersConfig;

    this.membershipTiers = Object.entries(tiersConfig)
      .map(([tier, minPoints]) => ({ tier, minPoints }))
      .sort((a, b) => b.minPoints - a.minPoints); // Cao → Thấp
  }

  // ==========================================
  // API: GET /users/me
  // ==========================================

  /**
   * Trả về thông tin profile đầy đủ của User đang đăng nhập.
   *
   * @param userId - UUID lấy từ JWT payload (req.user.userId)
   * @returns User entity (không trả password vì User không có password)
   * @throws NotFoundException nếu user không tồn tại
   */
  async getMe(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException("Không tìm thấy tài khoản người dùng");
    }
    return user;
  }

  // ==========================================
  // API: GET /users/me/transactions
  // ==========================================

  /**
   * Trả về lịch sử giao dịch của User đang đăng nhập, sắp xếp mới nhất trước.
   *
   * @param userId - UUID lấy từ JWT payload
   * @returns Danh sách Transaction kèm thông tin Merchant
   */
  async getMyTransactions(userId: string): Promise<Transaction[]> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException("Không tìm thấy tài khoản người dùng");
    }

    return this.transactionRepository.find({
      where: { user_id: userId },
      // Kèm thông tin merchant (tên cửa hàng) để hiển thị trên UI
      relations: ["merchant"],
      order: { created_at: "DESC" },
    });
  }

  // ==========================================
  // API: GET /points/balance
  // ==========================================

  /**
   * Trả về số dư điểm và hạng thành viên hiện tại của User.
   *
   * @param userId - UUID lấy từ JWT payload
   * @returns Object chứa total_points và membership_tier
   */
  async getPointsBalance(
    userId: string,
  ): Promise<{ total_points: number; membership_tier: string }> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      select: ["id", "total_points", "membership_tier"],
    });
    if (!user) {
      throw new NotFoundException("Không tìm thấy tài khoản người dùng");
    }
    return {
      total_points: user.total_points,
      membership_tier: user.membership_tier,
    };
  }

  // ==========================================
  // API: POST /points/earn (Merchant only)
  // ==========================================

  /**
   * Cộng điểm cho User sau khi giao dịch tại Merchant.
   *
   * Luồng xử lý:
   *   1. Xác thực Merchant đang đăng nhập còn active.
   *   2. Xác thực User được cộng điểm tồn tại.
   *   3. Tính số điểm = floor(bill_amount / POINTS_RATIO).
   *   4. Mở PostgreSQL Transaction + Row-Level Lock (SELECT FOR UPDATE)
   *      để tránh race condition khi nhiều request cộng điểm cùng lúc.
   *   5. Cộng điểm, cập nhật membership_tier nếu đủ ngưỡng.
   *   6. Lưu Transaction record vào lịch sử.
   *   7. Commit. Nếu lỗi → Rollback.
   *
   * @param merchantId - UUID Merchant đang đăng nhập (từ JWT)
   * @param dto        - Chứa user_id và bill_amount đã validate
   * @returns Số điểm vừa cộng và tổng điểm mới của User
   */
  async earnPoints(
    merchantId: string,
    dto: EarnPointsDto,
  ): Promise<{
    points_earned: number;
    new_total_points: number;
    new_membership_tier: string;
    tier_upgraded: boolean;
  }> {
    const { user_id, bill_amount } = dto;

    // ==========================================
    // BƯỚC 1: XÁC THỰC MERCHANT VÀ USER
    // ==========================================
    const merchant = await this.merchantRepository.findOne({
      where: { id: merchantId, is_active: true },
    });
    if (!merchant) {
      throw new NotFoundException("Cửa hàng không tồn tại hoặc đã bị khoá");
    }

    // Kiểm tra user có tồn tại không (ngoài transaction để fail-fast)
    const userExists = await this.userRepository.findOne({
      where: { id: user_id },
    });
    if (!userExists) {
      throw new NotFoundException(
        `Không tìm thấy người dùng với ID: ${user_id}`,
      );
    }

    // ==========================================
    // BƯỚC 2: TÍNH SỐ ĐIỂM
    // Dùng Math.floor để làm tròn xuống (không tặng điểm lẻ)
    // ==========================================
    const pointsEarned = Math.floor(bill_amount / this.pointsRatio);

    if (pointsEarned <= 0) {
      throw new BadRequestException(
        `Số tiền hóa đơn quá thấp để tích điểm. ` +
          `Tối thiểu ${this.pointsRatio.toLocaleString()}đ để nhận 1 điểm.`,
      );
    }

    // ==========================================
    // BƯỚC 3: MỞ POSTGRESQL TRANSACTION + ROW-LEVEL LOCK
    // Dùng QueryRunner để có toàn quyền kiểm soát commit/rollback.
    // SELECT FOR UPDATE khóa dòng User lại trong suốt transaction,
    // ngăn 2 request đồng thời cộng điểm gây sai số (race condition).
    // ==========================================
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Khóa dòng User bằng pessimistic_write (SELECT ... FOR UPDATE)
      // Mọi request khác muốn đọc/ghi user này phải chờ transaction này xong
      const user = await queryRunner.manager.findOne(User, {
        where: { id: user_id },
        lock: { mode: "pessimistic_write" },
      });

      if (!user) {
        throw new NotFoundException("Người dùng không tồn tại");
      }

      // ==========================================
      // BƯỚC 4: CỘNG ĐIỂM VÀ CẬP NHẬT TIER
      // ==========================================
      const oldTier = user.membership_tier;
      user.total_points += pointsEarned;

      // Tính lại tier dựa vào tổng điểm mới
      const newTier = this._calculateTier(user.total_points);
      user.membership_tier = newTier;
      const tierUpgraded = newTier !== oldTier;

      await queryRunner.manager.save(User, user);

      // ==========================================
      // BƯỚC 5: LƯU LỊCH SỬ GIAO DỊCH
      // ==========================================
      const transaction = queryRunner.manager.create(Transaction, {
        user_id: user.id,
        merchant_id: merchantId,
        type: TransactionType.EARN,
        points_delta: pointsEarned,
        bill_amount: bill_amount,
      });
      await queryRunner.manager.save(Transaction, transaction);

      // ==========================================
      // BƯỚC 6: COMMIT
      // ==========================================
      await queryRunner.commitTransaction();

      if (tierUpgraded) {
        this.logger.log(
          `User ${user_id} lên hạng: ${oldTier} → ${newTier} ` +
            `(tổng điểm: ${user.total_points})`,
        );
      }

      this.logger.log(
        `Cộng ${pointsEarned} điểm cho User ${user_id} ` +
          `(hóa đơn: ${bill_amount}đ | Merchant: ${merchantId})`,
      );

      return {
        points_earned: pointsEarned,
        new_total_points: user.total_points,
        new_membership_tier: newTier,
        tier_upgraded: tierUpgraded,
      };
    } catch (error) {
      // ==========================================
      // XỬ LÝ LỖI & ROLLBACK
      // Đảm bảo dữ liệu không bị ghi dở nếu có lỗi giữa chừng
      // ==========================================
      await queryRunner.rollbackTransaction();
      this.logger.error(
        `Lỗi khi cộng điểm cho User ${user_id}: ${error.message}`,
        error.stack,
      );
      throw error;
    } finally {
      // Luôn giải phóng connection về pool, dù thành công hay thất bại
      await queryRunner.release();
    }
  }

  // ==========================================
  // HELPER — TÍNH HẠNG THÀNH VIÊN
  // ==========================================

  /**
   * Tính hạng thành viên dựa vào tổng điểm hiện tại.
   * So sánh từ tier cao nhất xuống, trả về tier đầu tiên user đạt được.
   *
   * @param totalPoints - Tổng điểm sau khi cộng
   * @returns Tên tier tương ứng (STANDARD | SILVER | GOLD | PLATINUM)
   */
  private _calculateTier(totalPoints: number): string {
    for (const { tier, minPoints } of this.membershipTiers) {
      if (totalPoints >= minPoints) {
        return tier;
      }
    }
    // Fallback an toàn nếu config rỗng
    return "STANDARD";
  }
}
