/**
 * @file        notifications.module.ts
 * @module      NotificationsModule
 * @description Module đóng gói NotificationsGateway để các module khác có thể inject.
 *
 * @responsibility
 *   - Khai báo và export NotificationsGateway
 *   - Cho phép UsersModule và các module tương lai inject Gateway để phát sự kiện
 *
 * @dependencies
 *   - NotificationsGateway (Socket.IO WebSocket Gateway)
 *
 * @todo
 *   - (Không có cho MVP)
 */

import { Module } from '@nestjs/common';
import { NotificationsGateway } from './notifications.gateway';

@Module({
  providers: [NotificationsGateway],
  // Export để UsersModule (và các module khác) có thể inject và gọi notifyPointsEarned()
  exports: [NotificationsGateway],
})
export class NotificationsModule {}
