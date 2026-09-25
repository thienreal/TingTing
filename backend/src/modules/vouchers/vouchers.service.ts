/**
 * @file        vouchers.service.ts
 * @module      VouchersModule
 * @description Service xử lý toàn bộ nghiệp vụ Voucher của TingTing.
 *
 * @responsibility
 *   - Lấy danh sách / chi tiết Voucher (User)
 *   - Lấy danh sách Voucher User đang sở hữu (User)
 *   - Merchant tạo Voucher mới
 *   - User đổi điểm lấy Voucher: chống double-spending bằng
 *     PostgreSQL Transaction + Row-Level Lock (SELECT FOR UPDATE)
 *   - Merchant quét và xác nhận sử dụng Voucher (chuyển ACTIVE → USED)
 *
 * @dependencies
 *   - TypeORM (DataSource, Repository)
 *   - ConfigService (không cần cho module này, giữ để mở rộng sau)
 *
 * @todo
 *   - [ ] Thêm cron job tự động cập nhật status EXPIRED khi voucher quá hạn
 *   - [ ] Thêm cache danh sách Voucher bằng Redis (GET /vouchers là hot endpoint)
 */

import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { DataSource, Repository, MoreThan } from "typeorm";

import { Voucher } from "./entities/voucher.entity";
import {
  UserVoucher,
  UserVoucherStatus,
} from "../user-vouchers/entities/user-voucher.entity";
import { User } from "../users/entities/user.entity";
import { Merchant } from "../merchants/entities/merchant.entity";
import { CreateVoucherDto } from "./dto/create-voucher.dto";
import { UseVoucherDto } from "./dto/use-voucher.dto";

@Injectable()
export class VouchersService {
  private readonly logger = new Logger(VouchersService.name);

  constructor(
    @InjectRepository(Voucher)
    private readonly voucherRepository: Repository<Voucher>,

    @InjectRepository(UserVoucher)
    private readonly userVoucherRepository: Repository<UserVoucher>,

    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    @InjectRepository(Merchant)
    private readonly merchantRepository: Repository<Merchant>,

    private readonly dataSource: DataSource,
  ) {}

  // ==========================================
  // API: GET /vouchers  (User)
  // ==========================================

  /**
   * Lấy danh sách toàn bộ Voucher còn hiệu lực và còn hàng.
   * Kèm thông tin Merchant (tên cửa hàng, danh mục).
   * Sắp xếp theo điểm đổi tăng dần để User thấy voucher dễ đổi trước.
   *
   * @returns Danh sách Voucher còn hạn, còn tồn kho
   */
  async findAll(): Promise<Voucher[]> {
    return this.voucherRepository.find({
      where: {
        // Chỉ hiển thị voucher còn tồn kho
        remaining_quantity: MoreThan(0),
      },
      relations: ["merchant"],
      order: { points_cost: "ASC" },
    });
  }

  // ==========================================
  // API: GET /vouchers/:id  (User)
  // ==========================================

  /**
   * Lấy chi tiết một Voucher theo ID.
   *
   * @param id - UUID của Voucher
   * @returns Voucher kèm thông tin Merchant
   * @throws NotFoundException nếu không tìm thấy
   */
  async findOne(id: string): Promise<Voucher> {
    const voucher = await this.voucherRepository.findOne({
      where: { id },
      relations: ["merchant"],
    });
    if (!voucher) {
      throw new NotFoundException(`Không tìm thấy voucher với ID: ${id}`);
    }
    return voucher;
  }

  // ==========================================
  // API: GET /vouchers/mine  (User)
  // ==========================================

  /**
   * Lấy danh sách UserVoucher của User đang đăng nhập.
   * Kèm thông tin Voucher gốc và Merchant để hiển thị trên UI.
   * Sắp xếp theo trạng thái: ACTIVE trước, rồi đến USED và EXPIRED.
   *
   * @param userId - UUID lấy từ JWT payload
   * @returns Danh sách UserVoucher kèm Voucher + Merchant
   */
  async findMyVouchers(userId: string): Promise<UserVoucher[]> {
    return this.userVoucherRepository.find({
      where: { user_id: userId },
      relations: ["voucher", "voucher.merchant"],
      order: { created_at: "DESC" },
    });
  }

  // ==========================================
  // API: POST /merchants/vouchers  (Merchant)
  // ==========================================

  /**
   * Merchant tạo Voucher mới cho cửa hàng mình.
   * remaining_quantity được khởi tạo bằng total_quantity.
   *
   * @param merchantId - UUID Merchant từ JWT
   * @param dto        - Thông tin Voucher đã validate
   * @returns Voucher vừa tạo
   * @throws NotFoundException nếu Merchant không tồn tại / bị khoá
   */
  async createVoucher(
    merchantId: string,
    dto: CreateVoucherDto,
  ): Promise<Voucher> {
    const merchant = await this.merchantRepository.findOne({
      where: { id: merchantId, is_active: true },
    });
    if (!merchant) {
      throw new NotFoundException("Cửa hàng không tồn tại hoặc đã bị khoá");
    }

    const voucher = this.voucherRepository.create({
      merchant_id: merchantId,
      title: dto.title,
      description: dto.description,
      points_cost: dto.points_cost,
      total_quantity: dto.total_quantity,
      // remaining_quantity ban đầu = total_quantity
      remaining_quantity: dto.total_quantity,
      expired_at: new Date(dto.expired_at),
    });

    const saved = await this.voucherRepository.save(voucher);
    this.logger.log(
      `Merchant ${merchantId} tạo voucher: "${dto.title}" | ` +
        `${dto.points_cost} điểm | SL: ${dto.total_quantity}`,
    );
    return saved;
  }

  // ==========================================
  // API: POST /vouchers/:id/redeem  (User)
  // ==========================================

  /**
   * User đổi điểm lấy Voucher.
   *
   * Luồng chống double-spending (PostgreSQL Transaction + Row-Level Lock):
   *   1. Mở PostgreSQL Transaction.
   *   2. Lock dòng Voucher (SELECT FOR UPDATE) — chặn đồng thời giảm tồn kho.
   *   3. Lock dòng User (SELECT FOR UPDATE) — chặn đồng thời trừ điểm.
   *   4. Kiểm tra:
   *      a. Voucher còn hạn (expired_at > now)
   *      b. Voucher còn tồn kho (remaining_quantity > 0)
   *      c. User chưa đổi voucher này (status ACTIVE chưa tồn tại)
   *      d. User đủ điểm
   *   5. Giảm remaining_quantity, trừ điểm User, tạo UserVoucher.
   *   6. COMMIT. Nếu lỗi → ROLLBACK.
   *
   * @param voucherId - UUID Voucher muốn đổi
   * @param userId    - UUID User từ JWT
   * @returns UserVoucher vừa tạo kèm thông tin Voucher
   */
  async redeemVoucher(voucherId: string, userId: string): Promise<UserVoucher> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // ==========================================
      // BƯỚC 1: LOCK VOUCHER (chặn giảm tồn kho đồng thời)
      // ==========================================
      const voucher = await queryRunner.manager.findOne(Voucher, {
        where: { id: voucherId },
        lock: { mode: "pessimistic_write" },
      });

      if (!voucher) {
        throw new NotFoundException(
          `Không tìm thấy voucher với ID: ${voucherId}`,
        );
      }

      // ==========================================
      // BƯỚC 2: KIỂM TRA ĐIỀU KIỆN VOUCHER
      // ==========================================
      const now = new Date();

      // Kiểm tra còn hạn
      if (voucher.expired_at <= now) {
        throw new BadRequestException("Voucher này đã hết hạn sử dụng");
      }

      // Kiểm tra còn tồn kho
      if (voucher.remaining_quantity <= 0) {
        throw new BadRequestException("Voucher này đã hết số lượng phát hành");
      }

      // ==========================================
      // BƯỚC 3: LOCK USER (chặn trừ điểm đồng thời)
      // ==========================================
      const user = await queryRunner.manager.findOne(User, {
        where: { id: userId },
        lock: { mode: "pessimistic_write" },
      });

      if (!user) {
        throw new NotFoundException("Không tìm thấy tài khoản người dùng");
      }

      // ==========================================
      // BƯỚC 4: KIỂM TRA USER CHƯA ĐỔI VOUCHER NÀY
      // Chặn trường hợp cùng user gửi 2 request đồng thời
      // ==========================================
      const existingUserVoucher = await queryRunner.manager.findOne(
        UserVoucher,
        {
          where: {
            user_id: userId,
            voucher_id: voucherId,
            status: UserVoucherStatus.ACTIVE,
          },
        },
      );

      if (existingUserVoucher) {
        throw new BadRequestException(
          "Bạn đã đổi voucher này rồi và vẫn còn hiệu lực",
        );
      }

      // ==========================================
      // BƯỚC 5: KIỂM TRA ĐỦ ĐIỂM
      // ==========================================
      if (user.total_points < voucher.points_cost) {
        throw new BadRequestException(
          `Không đủ điểm để đổi voucher này. ` +
            `Cần ${voucher.points_cost} điểm, bạn đang có ${user.total_points} điểm.`,
        );
      }

      // ==========================================
      // BƯỚC 6: THỰC HIỆN GIAO DỊCH
      // Thứ tự: Giảm tồn kho → Trừ điểm → Tạo UserVoucher
      // ==========================================

      // 6a. Giảm tồn kho Voucher
      voucher.remaining_quantity -= 1;
      await queryRunner.manager.save(Voucher, voucher);

      // 6b. Trừ điểm User
      user.total_points -= voucher.points_cost;
      await queryRunner.manager.save(User, user);

      // 6c. Tạo bản ghi UserVoucher (status = ACTIVE, chưa dùng)
      const userVoucher = queryRunner.manager.create(UserVoucher, {
        user_id: userId,
        voucher_id: voucherId,
        status: UserVoucherStatus.ACTIVE,
        redeemed_at: now,
      });
      const savedUserVoucher = await queryRunner.manager.save(
        UserVoucher,
        userVoucher,
      );

      // ==========================================
      // BƯỚC 7: COMMIT
      // ==========================================
      await queryRunner.commitTransaction();

      this.logger.log(
        `User ${userId} đổi voucher "${voucher.title}" ` +
          `(${voucher.points_cost} điểm | còn lại: ${voucher.remaining_quantity})`,
      );

      // Load lại relation voucher để trả về đủ thông tin cho client
      return this.userVoucherRepository.findOne({
        where: { id: savedUserVoucher.id },
        relations: ["voucher", "voucher.merchant"],
      });
    } catch (error) {
      // ==========================================
      // XỬ LÝ LỖI & ROLLBACK
      // ==========================================
      await queryRunner.rollbackTransaction();
      this.logger.error(
        `Lỗi khi User ${userId} đổi voucher ${voucherId}: ${error.message}`,
        error.stack,
      );
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  // ==========================================
  // API: POST /points/use-voucher  (Merchant)
  // ==========================================

  /**
   * Merchant quét barcode voucher của khách để xác nhận áp dụng.
   * Chuyển trạng thái UserVoucher từ ACTIVE → USED.
   *
   * Kiểm tra:
   *   - UserVoucher tồn tại
   *   - Voucher thuộc cửa hàng của Merchant đang đăng nhập (bảo mật)
   *   - Trạng thái đang là ACTIVE (chưa dùng, chưa hết hạn)
   *   - Voucher gốc chưa hết hạn
   *
   * @param merchantId     - UUID Merchant từ JWT
   * @param dto            - Chứa user_voucher_id đã validate
   * @returns UserVoucher đã cập nhật status = USED
   */
  async useVoucher(
    merchantId: string,
    dto: UseVoucherDto,
  ): Promise<UserVoucher> {
    const { user_voucher_id } = dto;

    // ==========================================
    // TÌM USER VOUCHER KÈM VOUCHER GỐC
    // ==========================================
    const userVoucher = await this.userVoucherRepository.findOne({
      where: { id: user_voucher_id },
      relations: ["voucher"],
    });

    if (!userVoucher) {
      throw new NotFoundException(
        `Không tìm thấy voucher với mã: ${user_voucher_id}`,
      );
    }

    // ==========================================
    // BẢO MẬT: CHỈ MERCHANT CÓ VOUCHER ĐÓ MỚI ĐƯỢC QUÉT
    // Tránh trường hợp Merchant A quét voucher của Merchant B
    // ==========================================
    if (userVoucher.voucher.merchant_id !== merchantId) {
      throw new ForbiddenException("Voucher này không thuộc cửa hàng của bạn");
    }

    // ==========================================
    // KIỂM TRA TRẠNG THÁI VOUCHER
    // ==========================================
    if (userVoucher.status === UserVoucherStatus.USED) {
      throw new BadRequestException("Voucher này đã được sử dụng rồi");
    }

    if (userVoucher.status === UserVoucherStatus.EXPIRED) {
      throw new BadRequestException("Voucher này đã hết hạn");
    }

    // Kiểm tra lại ngày hết hạn của voucher gốc
    const now = new Date();
    if (userVoucher.voucher.expired_at <= now) {
      // Cập nhật status EXPIRED đồng thời
      userVoucher.status = UserVoucherStatus.EXPIRED;
      await this.userVoucherRepository.save(userVoucher);
      throw new BadRequestException("Voucher này đã hết hạn sử dụng");
    }

    // ==========================================
    // CẬP NHẬT TRẠNG THÁI → USED
    // ==========================================
    userVoucher.status = UserVoucherStatus.USED;
    const updated = await this.userVoucherRepository.save(userVoucher);

    this.logger.log(
      `Merchant ${merchantId} xác nhận dùng UserVoucher ${user_voucher_id}`,
    );

    return updated;
  }
}
