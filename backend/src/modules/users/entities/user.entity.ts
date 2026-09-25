/**
 * @file        user.entity.ts
 * @module      UsersModule
 * @description Định nghĩa cấu trúc bảng Users trong cơ sở dữ liệu.
 *
 * @responsibility
 *   - Lưu trữ thông tin người dùng cuối (B2C)
 *   - Quản lý điểm thưởng tổng và hạng thành viên
 *
 * @dependencies
 *   - TypeORM
 *
 * @todo
 *   -
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from "typeorm";
import { Transaction } from "../../transactions/entities/transaction.entity";
import { UserVoucher } from "../../user-vouchers/entities/user-voucher.entity";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ type: "varchar", length: 20, unique: true })
  phone_number: string;

  @Column({ type: "varchar", length: 100, nullable: true })
  full_name: string;

  @Column({ type: "int", default: 0 })
  total_points: number;

  @Column({ type: "varchar", length: 50, default: "STANDARD" })
  membership_tier: string;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Transaction, (transaction) => transaction.user)
  transactions: Transaction[];

  @OneToMany(() => UserVoucher, (userVoucher) => userVoucher.user)
  userVouchers: UserVoucher[];
}
