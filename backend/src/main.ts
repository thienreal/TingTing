import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Enable CORS if needed for Flutter Web, though mobile doesn't strictly need it.
  app.enableCors();

  // Bật ValidationPipe global để DTO tự động được validate bởi class-validator
  // whitelist: true -> loại bỏ field lạ không có trong DTO (bảo mật)
  // forbidNonWhitelisted: true -> throw lỗi nếu gửi field không hợp lệ
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true, // Tự động chuyển đổi kiểu dữ liệu (vd: string -> number)
    }),
  );

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
