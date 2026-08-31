/**
 * @file        merchant.entity.ts
 * @module      MerchantsModule
 * @description Định nghĩa cấu trúc bảng Merchants trong cơ sở dữ liệu.
 *
 * @responsibility
 *   - Lưu trữ thông tin cửa hàng/đối tác (SME)
 *   - Quản lý thông tin đăng nhập và danh mục
 *
 * @dependencies
 *   - TypeORM
 *
 * @todo
 *   - 
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { Transaction } from '../../transactions/entities/transaction.entity';
import { Voucher } from '../../vouchers/entities/voucher.entity';

@Entity('merchants')
export class Merchant {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 150 })
  name: string;

  @Column({ type: 'varchar', length: 100, unique: true })
  email: string;

  @Column({ type: 'varchar', length: 255 })
  password: string; // Hashed password

  @Column({ type: 'varchar', length: 100, nullable: true })
  category: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  qr_static_code: string;

  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => Transaction, (transaction) => transaction.merchant)
  transactions: Transaction[];

  @OneToMany(() => Voucher, (voucher) => voucher.merchant)
  vouchers: Voucher[];
}
