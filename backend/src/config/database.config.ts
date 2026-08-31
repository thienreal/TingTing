import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import * as dotenv from 'dotenv';

// Nạp biến môi trường từ file .env
dotenv.config();

/**
 * Cấu hình kết nối TypeORM dùng cho TypeOrmModule.forRoot() trong AppModule.
 * Đọc toàn bộ thông số từ biến môi trường (.env), không hardcode bất kỳ giá trị nào.
 */
export const typeOrmConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'tingting_db',

  // TypeORM tự động tìm và nạp tất cả file Entity có đuôi .entity.ts
  entities: [__dirname + '/../modules/**/*.entity{.ts,.js}'],

  // Migration: TypeORM tự động tìm và nạp tất cả file Migration
  migrations: [__dirname + '/../migrations/**/*{.ts,.js}'],

  // TYPEORM_SYNC=true: TypeORM tự tạo/cập nhật bảng theo Entity (CHỈ dùng khi DEV)
  // CẢNH BÁO: Đặt thành false khi deploy Production, dùng Migration thay thế
  synchronize: process.env.TYPEORM_SYNC === 'true',

  // TYPEORM_LOGGING=true: In ra terminal các câu SQL thực thi (hữu ích khi debug)
  logging: process.env.TYPEORM_LOGGING === 'true',
};

/**
 * DataSource dùng cho TypeORM CLI (chạy lệnh migration từ terminal).
 * Lệnh ví dụ:
 *   - Tạo migration mới:  npx typeorm migration:generate src/migrations/TenMigration -d src/config/database.config.ts
 *   - Chạy migration:     npx typeorm migration:run -d src/config/database.config.ts
 *   - Hoàn tác migration: npx typeorm migration:revert -d src/config/database.config.ts
 */
export const AppDataSource = new DataSource({
  ...(typeOrmConfig as DataSourceOptions),
});
