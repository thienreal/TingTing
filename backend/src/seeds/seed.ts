/**
 * @file        seed.ts
 * @module      Seed
 * @description Script tạo dữ liệu mẫu cho dự án TingTing
 *
 * @responsibility
 *   - Tạo 10 Merchant, 20 User, 30 Voucher, 50 Transaction
 */

import { DataSource } from "typeorm";
import { User } from "../modules/users/entities/user.entity";
import { Merchant } from "../modules/merchants/entities/merchant.entity";
import {
  Transaction,
  TransactionType,
} from "../modules/transactions/entities/transaction.entity";
import { Voucher } from "../modules/vouchers/entities/voucher.entity";
import { UserVoucher } from "../modules/user-vouchers/entities/user-voucher.entity";
import * as bcrypt from "bcrypt";

export async function runSeed(dataSource: DataSource) {
  console.log("Bắt đầu sinh dữ liệu mẫu (Seed Data)...");

  const userRepository = dataSource.getRepository(User);
  const merchantRepository = dataSource.getRepository(Merchant);
  const transactionRepository = dataSource.getRepository(Transaction);
  const voucherRepository = dataSource.getRepository(Voucher);
  const userVoucherRepository = dataSource.getRepository(UserVoucher);

  // Xóa dữ liệu cũ để tránh lỗi unique constraint (theo thứ tự khóa ngoại)
  await userVoucherRepository.createQueryBuilder().delete().execute();
  await transactionRepository.createQueryBuilder().delete().execute();
  await voucherRepository.createQueryBuilder().delete().execute();
  await merchantRepository.createQueryBuilder().delete().execute();
  await userRepository.createQueryBuilder().delete().execute();

  // Sinh 10 Merchant
  const merchantsData = [];
  const passwordHash = await bcrypt.hash("123456", 10);
  for (let i = 1; i <= 10; i++) {
    merchantsData.push(
      merchantRepository.create({
        name: `Cửa hàng Mẫu ${i}`,
        email: `merchant${i}@tingting.dev`,
        password: passwordHash,
        category: i % 2 === 0 ? "F&B" : "Bán lẻ",
        qr_static_code: `QR_MERCHANT_${i}`,
      }),
    );
  }
  const merchants = await merchantRepository.save(merchantsData);

  // Sinh 20 User
  const usersData = [];
  for (let i = 1; i <= 20; i++) {
    usersData.push(
      userRepository.create({
        phone_number: `0900000${i < 10 ? "0" + i : i}`,
        full_name: `Người Dùng ${i}`,
        total_points: 1000 + i * 100, // Đa dạng điểm số
        membership_tier: i % 3 === 0 ? "GOLD" : "STANDARD",
      }),
    );
  }
  const users = await userRepository.save(usersData);

  // Sinh 30 Voucher (mỗi merchant ~3 voucher)
  const vouchersData = [];
  for (let i = 1; i <= 30; i++) {
    const merchant = merchants[i % merchants.length];
    vouchersData.push(
      voucherRepository.create({
        merchant_id: merchant.id,
        title: `Voucher giảm giá ${i * 10}%`,
        description: `Áp dụng tại cửa hàng ${merchant.name}`,
        points_cost: i * 50,
        total_quantity: 100,
        remaining_quantity: 90,
        expired_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // Hết hạn sau 30 ngày
      }),
    );
  }
  await voucherRepository.save(vouchersData);

  // Sinh 50 Transaction
  const transactionsData = [];
  for (let i = 1; i <= 50; i++) {
    const user = users[i % users.length];
    const merchant = merchants[i % merchants.length];
    transactionsData.push(
      transactionRepository.create({
        user_id: user.id,
        merchant_id: merchant.id,
        type: TransactionType.EARN,
        points_delta: 50,
        bill_amount: 50000,
      }),
    );
  }
  await transactionRepository.save(transactionsData);

  console.log("Sinh dữ liệu mẫu thành công!");
}
