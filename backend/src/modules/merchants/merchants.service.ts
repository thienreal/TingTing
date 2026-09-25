/**
 * @file        merchants.service.ts
 * @module      MerchantsModule
 * @description Service xử lý nghiệp vụ cho Merchant.
 *
 * @responsibility
 *   - Cung cấp dữ liệu thống kê, báo cáo cho cửa hàng (dashboard)
 *
 * @dependencies
 *   - TypeORM (Merchant, Transaction, Voucher, UserVoucher)
 *
 * @todo
 *   - [ ] Thêm các báo cáo nâng cao (theo khoảng thời gian từ ngày - đến ngày)
 */

import { Injectable, Logger } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, MoreThan } from "typeorm";

import { Merchant } from "./entities/merchant.entity";
import {
  Transaction,
  TransactionType,
} from "../transactions/entities/transaction.entity";
import { Voucher } from "../vouchers/entities/voucher.entity";
import {
  UserVoucher,
  UserVoucherStatus,
} from "../user-vouchers/entities/user-voucher.entity";

@Injectable()
export class MerchantsService {
  private readonly logger = new Logger(MerchantsService.name);

  constructor(
    @InjectRepository(Merchant)
    private readonly merchantRepository: Repository<Merchant>,
    @InjectRepository(Transaction)
    private readonly transactionRepository: Repository<Transaction>,
    @InjectRepository(Voucher)
    private readonly voucherRepository: Repository<Voucher>,
    @InjectRepository(UserVoucher)
    private readonly userVoucherRepository: Repository<UserVoucher>,
  ) {}

  /**
   * Trả về báo cáo thống kê tổng quan cho Merchant.
   *
   * @param merchantId - UUID của Merchant (từ JWT)
   * @returns Object chứa các chỉ số thống kê
   */
  async getReport(merchantId: string) {
    const now = new Date();

    // 1. Tổng số lượng voucher đang phát hành (còn hạn)
    const activeVouchersCount = await this.voucherRepository.count({
      where: {
        merchant_id: merchantId,
        expired_at: MoreThan(now),
      },
    });

    // 2. Tổng số điểm đã cấp cho User (EARN)
    const { total_points_issued } = await this.transactionRepository
      .createQueryBuilder("transaction")
      .select("SUM(transaction.points_delta)", "total_points_issued")
      .where("transaction.merchant_id = :merchantId", { merchantId })
      .andWhere("transaction.type = :type", { type: TransactionType.EARN })
      .getRawOne();

    // 3. Tổng số lượt giao dịch (cả cộng điểm và có thể mở rộng sau này)
    const totalTransactions = await this.transactionRepository.count({
      where: { merchant_id: merchantId },
    });

    // 4. Tổng số lượng voucher của cửa hàng này đã được người dùng sử dụng (USED)
    const usedVouchersCount = await this.userVoucherRepository
      .createQueryBuilder("user_voucher")
      .innerJoin("user_voucher.voucher", "voucher")
      .where("voucher.merchant_id = :merchantId", { merchantId })
      .andWhere("user_voucher.status = :status", {
        status: UserVoucherStatus.USED,
      })
      .getCount();

    this.logger.log(`Generate report for Merchant: ${merchantId}`);

    return {
      active_vouchers_count: activeVouchersCount,
      total_points_issued: parseInt(total_points_issued || "0", 10),
      total_transactions: totalTransactions,
      used_vouchers_count: usedVouchersCount,
    };
  }
}
