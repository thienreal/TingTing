/**
 * @file        user-voucher.entity.ts
 * @module      UserVouchersModule
 * @description Định nghĩa cấu trúc bảng trung gian UserVouchers.
 *
 * @responsibility
 *   - Quản lý trạng thái voucher của người dùng đã đổi
 *
 * @dependencies
 *   - TypeORM
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Voucher } from '../../vouchers/entities/voucher.entity';

export enum UserVoucherStatus {
  ACTIVE = 'ACTIVE',
  USED = 'USED',
  EXPIRED = 'EXPIRED',
}

@Entity('user_vouchers')
export class UserVoucher {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  user_id: string;

  @Column({ type: 'uuid' })
  voucher_id: string;

  @Column({ type: 'enum', enum: UserVoucherStatus, default: UserVoucherStatus.ACTIVE })
  status: UserVoucherStatus;

  @Column({ type: 'timestamp', nullable: true })
  redeemed_at: Date;

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => User, (user) => user.userVouchers)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Voucher, (voucher) => voucher.userVouchers)
  @JoinColumn({ name: 'voucher_id' })
  voucher: Voucher;
}
