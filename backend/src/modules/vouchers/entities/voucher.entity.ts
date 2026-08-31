/**
 * @file        voucher.entity.ts
 * @module      VouchersModule
 * @description Định nghĩa cấu trúc bảng Vouchers.
 *
 * @responsibility
 *   - Lưu trữ các ưu đãi do cửa hàng tạo ra
 *
 * @dependencies
 *   - TypeORM
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Merchant } from '../../merchants/entities/merchant.entity';
import { UserVoucher } from '../../user-vouchers/entities/user-voucher.entity';

@Entity('vouchers')
export class Voucher {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  merchant_id: string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'int' })
  points_cost: number;

  @Column({ type: 'int' })
  total_quantity: number;

  @Column({ type: 'int' })
  remaining_quantity: number;

  @Column({ type: 'timestamp' })
  expired_at: Date;

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => Merchant, (merchant) => merchant.vouchers)
  @JoinColumn({ name: 'merchant_id' })
  merchant: Merchant;

  @OneToMany(() => UserVoucher, (userVoucher) => userVoucher.voucher)
  userVouchers: UserVoucher[];
}
