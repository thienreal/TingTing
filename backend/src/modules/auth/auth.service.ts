/**
 * @file        auth.service.ts
 * @module      AuthModule
 * @description Service xử lý toàn bộ nghiệp vụ xác thực của hệ thống TingTing.
 *   Bao gồm: gửi OTP (Mock), xác thực OTP và cấp JWT cho User,
 *   đăng nhập email/password và cấp JWT cho Merchant.
 *
 * @responsibility
 *   - Gửi Mock OTP (MVP) hoặc SMS OTP thật (tương lai) cho User
 *   - Xác thực OTP, tự động tạo tài khoản User nếu chưa tồn tại
 *   - Xác thực email/password cho Merchant, trả về JWT
 *   - Ký và cấp JWT Access Token với payload phân biệt role USER / MERCHANT
 *
 * @dependencies
 *   - TypeORM (UserRepository, MerchantRepository)
 *   - @nestjs/jwt (JwtService)
 *   - bcrypt (so sánh password hash của Merchant)
 *   - ConfigService (đọc JWT_SECRET, JWT_EXPIRES_IN từ .env)
 *
 * @todo
 *   - [ ] MVP: Thay Mock OTP bằng SMS Gateway thật (Twilio/ESMS.vn).
 *         Xem docs/Future_Development.md §1 — "Tích hợp SMS OTP Thực tế"
 *   - [ ] Lưu OTP vào Redis với TTL = OTP_EXPIRY_SECONDS thay vì Map in-memory
 *   - [ ] Thêm cơ chế Refresh Token để kéo dài phiên đăng nhập
 */

import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  Logger,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { JwtService } from "@nestjs/jwt";
import { ConfigService } from "@nestjs/config";
import * as bcrypt from "bcrypt";

import { User } from "../users/entities/user.entity";
import { Merchant } from "../merchants/entities/merchant.entity";
import { SendOtpDto } from "./dto/send-otp.dto";
import { VerifyOtpDto } from "./dto/verify-otp.dto";
import { MerchantLoginDto } from "./dto/merchant-login.dto";
import { JwtPayload } from "./strategies/jwt.strategy";

// ==========================================
// HẰNG SỐ MVP
// ==========================================

/**
 * Mock OTP cố định dùng cho toàn bộ Giai đoạn 1 (MVP).
 *
 * @mvp Giá trị này được cố định để đơn giản hóa quá trình Demo
 *       và kiểm thử mà không cần SMS Gateway thật.
 *
 * @future Khi tích hợp SMS thật (Giai đoạn 2+), xoá hằng số này và
 *         thay bằng logic sinh OTP ngẫu nhiên + lưu vào Redis với TTL.
 *         Xem docs/Future_Development.md §1 — "Tích hợp SMS OTP Thực tế".
 */
const MOCK_OTP_CODE = "000000";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  /**
   * Store OTP in-memory tạm thời cho MVP.
   * Key = phone_number, Value = mã OTP (hiện tại luôn là MOCK_OTP_CODE).
   *
   * @future Thay Map in-memory bằng Redis để hỗ trợ multi-instance
   *         và TTL tự động theo OTP_EXPIRY_SECONDS.
   *         Xem docs/Future_Development.md §1 — "Tích hợp SMS OTP Thực tế".
   */
  private readonly otpStore = new Map<string, string>();

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,

    @InjectRepository(Merchant)
    private readonly merchantRepository: Repository<Merchant>,

    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  // ==========================================
  // API: POST /auth/send-otp
  // ==========================================

  /**
   * Nhận số điện thoại và "gửi" OTP cho người dùng.
   *
   * @mvp Hiện tại KHÔNG gửi SMS thật — chỉ lưu Mock OTP ("000000")
   *       vào store in-memory và in ra log để developer biết.
   *       Mọi số điện thoại hợp lệ đều được chấp nhận.
   *
   * @future Thay khối comment bên dưới bằng lời gọi SMS Gateway thật.
   *         Xem docs/Future_Development.md §1 — "Tích hợp SMS OTP Thực tế".
   *
   * @param dto - Chứa số điện thoại đã được validate
   * @returns Thông báo xác nhận đã "gửi" OTP
   */
  async sendOtp(dto: SendOtpDto): Promise<{ message: string }> {
    const { phone_number } = dto;

    // ==========================================
    // [MVP] SINH VÀ LƯU MOCK OTP
    // Trong tương lai: sinh OTP ngẫu nhiên 6 chữ số,
    // lưu vào Redis với TTL = OTP_EXPIRY_SECONDS,
    // gọi SMS Gateway (Twilio/ESMS) để gửi đến phone_number.
    // ==========================================
    this.otpStore.set(phone_number, MOCK_OTP_CODE);

    // Log rõ ràng để Developer biết OTP đang là mock
    this.logger.warn(
      `[MVP - MOCK OTP] Số điện thoại: ${phone_number} | OTP: ${MOCK_OTP_CODE} ` +
        `(Chưa gửi SMS thật — xem Future_Development.md §1)`,
    );

    return {
      message: `[MVP] Mã OTP đã được "gửi" đến ${phone_number}. Dùng mã "${MOCK_OTP_CODE}" để xác thực.`,
    };
  }

  // ==========================================
  // API: POST /auth/verify-otp
  // ==========================================

  /**
   * Xác thực OTP người dùng nhập.
   * Nếu đúng: tự động tạo User nếu chưa có, cấp JWT Access Token.
   *
   * @mvp Kiểm tra OTP bằng cách so sánh với MOCK_OTP_CODE ("000000").
   *       Không có TTL, không có giới hạn số lần thử.
   *
   * @future Khi tích hợp OTP thật:
   *   1. Lấy OTP từ Redis bằng key = phone_number.
   *   2. So sánh và kiểm tra TTL.
   *   3. Xoá OTP khỏi Redis sau khi xác thực thành công (one-time use).
   *   Xem docs/Future_Development.md §1 — "Tích hợp SMS OTP Thực tế".
   *
   * @param dto - Chứa phone_number và otp đã validate
   * @returns JWT Access Token và thông tin User cơ bản
   */
  async verifyOtp(dto: VerifyOtpDto): Promise<{
    access_token: string;
    user: Partial<User>;
    is_new_user: boolean;
  }> {
    const { phone_number, otp } = dto;

    // ==========================================
    // [MVP] KIỂM TRA MOCK OTP
    // OTP hợp lệ duy nhất là "000000" cho toàn bộ MVP.
    // Trong tương lai: so sánh với OTP lưu trong Redis + kiểm tra TTL.
    // ==========================================
    const storedOtp = this.otpStore.get(phone_number);

    if (!storedOtp) {
      throw new BadRequestException(
        "Chưa gửi OTP cho số điện thoại này. Vui lòng gọi /auth/send-otp trước.",
      );
    }

    if (storedOtp !== otp) {
      throw new UnauthorizedException("Mã OTP không chính xác");
    }

    // Xoá OTP sau khi dùng để tránh replay attack (dù là mock)
    this.otpStore.delete(phone_number);

    // ==========================================
    // TỰ ĐỘNG TẠO USER NẾU CHƯA TỒN TẠI (Auto-registration)
    // ==========================================
    let user = await this.userRepository.findOne({ where: { phone_number } });
    let isNewUser = false;

    if (!user) {
      user = this.userRepository.create({
        phone_number,
        full_name: null,
        total_points: 0,
        membership_tier: "STANDARD",
      });
      user = await this.userRepository.save(user);
      isNewUser = true;
      this.logger.log(`Tạo User mới: ${user.id} | SĐT: ${phone_number}`);
    }

    // ==========================================
    // KÝ VÀ CẤP JWT ACCESS TOKEN
    // ==========================================
    const accessToken = this._signToken({
      sub: user.id,
      role: "USER",
      phone: user.phone_number,
    });

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        phone_number: user.phone_number,
        full_name: user.full_name,
        total_points: user.total_points,
        membership_tier: user.membership_tier,
      },
      is_new_user: isNewUser,
    };
  }

  // ==========================================
  // API: POST /auth/merchant/login
  // ==========================================

  /**
   * Đăng nhập Merchant bằng email và password.
   * Xác thực bcrypt hash, cấp JWT Access Token với role MERCHANT.
   *
   * @param dto - Chứa email và password đã validate
   * @returns JWT Access Token và thông tin Merchant cơ bản
   * @throws NotFoundException nếu email không tồn tại
   * @throws UnauthorizedException nếu password sai hoặc tài khoản bị khoá
   */
  async merchantLogin(
    dto: MerchantLoginDto,
  ): Promise<{ access_token: string; merchant: Partial<Merchant> }> {
    const { email, password } = dto;

    // ==========================================
    // TÌM MERCHANT THEO EMAIL
    // ==========================================
    const merchant = await this.merchantRepository.findOne({
      where: { email },
    });

    if (!merchant) {
      // Dùng UnauthorizedException thay vì NotFoundException để tránh
      // lộ thông tin tài khoản có tồn tại hay không (Security best practice)
      throw new UnauthorizedException("Email hoặc mật khẩu không chính xác");
    }

    if (!merchant.is_active) {
      throw new UnauthorizedException(
        "Tài khoản cửa hàng đã bị khoá. Vui lòng liên hệ Admin.",
      );
    }

    // ==========================================
    // XÁC THỰC PASSWORD BẰNG BCRYPT
    // ==========================================
    const isPasswordValid = await bcrypt.compare(password, merchant.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException("Email hoặc mật khẩu không chính xác");
    }

    // ==========================================
    // KÝ VÀ CẤP JWT ACCESS TOKEN
    // ==========================================
    const accessToken = this._signToken({
      sub: merchant.id,
      role: "MERCHANT",
      email: merchant.email,
    });

    this.logger.log(`Merchant đăng nhập: ${merchant.id} | Email: ${email}`);

    return {
      access_token: accessToken,
      merchant: {
        id: merchant.id,
        name: merchant.name,
        email: merchant.email,
        category: merchant.category,
        qr_static_code: merchant.qr_static_code,
      },
    };
  }

  // ==========================================
  // HELPER — KÝ JWT TOKEN
  // ==========================================

  /**
   * Ký một JWT Access Token với payload đã cho.
   * Dùng JWT_SECRET và JWT_EXPIRES_IN từ biến môi trường.
   *
   * @param payload - Dữ liệu cần mã hoá vào token
   * @returns JWT Access Token string
   */
  private _signToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>("JWT_SECRET"),
      expiresIn: this.configService.get<string>("JWT_EXPIRES_IN") || "7d",
    });
  }
}
