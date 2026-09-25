import { AppDataSource } from "../config/database.config";
import { runSeed } from "./seed";

AppDataSource.initialize()
  .then(async (dataSource) => {
    await runSeed(dataSource);
    process.exit(0);
  })
  .catch((error) => {
    console.error("Lỗi khi chạy seed:", error);
    process.exit(1);
  });
