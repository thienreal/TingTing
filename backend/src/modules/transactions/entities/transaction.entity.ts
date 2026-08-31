/**
 * @file        transaction.entity.ts
 * @module      TransactionsModule
 * @description Định nghĩa cấu trúc bảng Transactions.
 *
 * @responsibility
 *   - Lưu trữ lịch sử giao dịch tích điểm và đổi điểm
 *
 * @dependencies
 *   - TypeORM
 */

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Merchant } from '../../merchants/entities/merchant.entity';

export enum TransactionType {
  EARN = 'EARN',
  REDEEM = 'REDEEM',
}

@Entity('transactions')
export class Transaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  user_id: string;

  @Column({ type: 'uuid' })
  merchant_id: string;

  @Column({ type: 'enum', enum: TransactionType })
  type: TransactionType;

  @Column({ type: 'int' })
  points_delta: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  bill_amount: number;

  @CreateDateColumn()
  created_at: Date;

  @ManyToOne(() => User, (user) => user.transactions)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Merchant, (merchant) => merchant.transactions)
  @JoinColumn({ name: 'merchant_id' })
  merchant: Merchant;
}
