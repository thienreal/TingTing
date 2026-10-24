/**
 * @file        seed.ts
 * @module      Seed
 * @description Script tạo dữ liệu mẫu thực tế và phong phú cho dự án TingTing.
 *   Đặc biệt tối ưu hóa tài khoản thử nghiệm 0900000001 để hiển thị đầy đủ giao diện:
 *   - Hồ sơ: Nguyễn Hoàng Nam, 1.250 điểm VUI (Hạng Bạc - SILVER)
 *   - Kho Voucher: 3 voucher đang có (Active), 2 voucher đã dùng (Used), 1 voucher hết hạn (Expired)
 *   - Lịch sử giao dịch: 13 biến động tích và đổi điểm chân thực qua các mốc thời gian
 *   - 10 thương hiệu F&B, Bán lẻ, Giải trí quen thuộc tại Việt Nam
 *
 * @responsibility
 *   - Xóa sạch dữ liệu cũ theo thứ tự khóa ngoại an toàn
 *   - Nạp 10 Merchant thương hiệu lớn
 *   - Nạp 20 User, định danh người dùng chân thực
 *   - Nạp 20 Voucher ưu đãi hấp dẫn
 *   - Nạp UserVoucher và Transactions sinh động cho tài khoản 0900000001
 *
 * @dependencies
 *   - TypeORM
 *   - bcrypt
 */

import { DataSource } from "typeorm";
import * as bcrypt from "bcrypt";
import { User } from "../modules/users/entities/user.entity";
import { Merchant } from "../modules/merchants/entities/merchant.entity";
import {
  Transaction,
  TransactionType,
} from "../modules/transactions/entities/transaction.entity";
import { Voucher } from "../modules/vouchers/entities/voucher.entity";
import {
  UserVoucher,
  UserVoucherStatus,
} from "../modules/user-vouchers/entities/user-voucher.entity";

export async function runSeed(dataSource: DataSource) {
  console.log("🚀 Bắt đầu nạp dữ liệu mẫu sinh động (Seed Data)...");

  const userRepository = dataSource.getRepository(User);
  const merchantRepository = dataSource.getRepository(Merchant);
  const transactionRepository = dataSource.getRepository(Transaction);
  const voucherRepository = dataSource.getRepository(Voucher);
  const userVoucherRepository = dataSource.getRepository(UserVoucher);

  // ==========================================
  // 1. XÓA DỮ LIỆU CŨ THEO THỨ TỰ KHÓA NGOẠI
  // ==========================================
  console.log("🧹 Dọn dẹp dữ liệu cũ...");
  await userVoucherRepository.createQueryBuilder().delete().execute();
  await transactionRepository.createQueryBuilder().delete().execute();
  await voucherRepository.createQueryBuilder().delete().execute();
  await merchantRepository.createQueryBuilder().delete().execute();
  await userRepository.createQueryBuilder().delete().execute();

  // ==========================================
  // 2. SINH 10 THƯƠNG HIỆU ĐỐI TÁC (MERCHANTS)
  // ==========================================
  console.log("🏬 Tạo 10 thương hiệu đối tác nổi tiếng...");
  const passwordHash = await bcrypt.hash("123456", 10);

  const merchantsConfig = [
    { name: "Highlands Coffee", email: "highlands@tingting.dev", category: "F&B", code: "QR_HIGHLANDS" },
    { name: "Phúc Long Coffee & Tea", email: "phuclong@tingting.dev", category: "F&B", code: "QR_PHUCLONG" },
    { name: "The Coffee House", email: "thecoffeehouse@tingting.dev", category: "F&B", code: "QR_TCH" },
    { name: "Gong Cha", email: "gongcha@tingting.dev", category: "F&B", code: "QR_GONGCHA" },
    { name: "Pizza 4P's", email: "pizza4ps@tingting.dev", category: "F&B", code: "QR_PIZZA4PS" },
    { name: "Haidilao Hotpot", email: "haidilao@tingting.dev", category: "F&B", code: "QR_HAIDILAO" },
    { name: "Circle K", email: "circlek@tingting.dev", category: "Bán lẻ", code: "QR_CIRCLEK" },
    { name: "CGV Cinemas", email: "cgv@tingting.dev", category: "Giải trí", code: "QR_CGV" },
    { name: "Uniqlo Việt Nam", email: "uniqlo@tingting.dev", category: "Thời trang", code: "QR_UNIQLO" },
    { name: "Guardian", email: "guardian@tingting.dev", category: "Làm đẹp", code: "QR_GUARDIAN" },
  ];

  const merchantsData = merchantsConfig.map((m) =>
    merchantRepository.create({
      name: m.name,
      email: m.email,
      password: passwordHash,
      category: m.category,
      qr_static_code: m.code,
      is_active: true,
    }),
  );
  const merchants = await merchantRepository.save(merchantsData);
  const merchantMap = new Map(merchants.map((m) => [m.name, m]));

  // ==========================================
  // 3. SINH 20 USER (TỐI ƯU HÓA USER 0900000001)
  // ==========================================
  console.log("👤 Tạo danh sách người dùng...");
  const vietnameseNames = [
    "Nguyễn Hoàng Nam", // User 0900000001 (Tài khoản chính kiểm thử)
    "Trần Minh Tuấn",
    "Lê Thị Thu Hà",
    "Phạm Quốc Bảo",
    "Hoàng Diệu Linh",
    "Đỗ Hải Đăng",
    "Vũ Bích Ngọc",
    "Bùi Tiến Dũng",
    "Ngô Phương Anh",
    "Đặng Thành Long",
    "Lý Gia Hưng",
    "Dương Mai Chi",
    "Trịnh Văn Quyết",
    "Phan Thanh Thảo",
    "Hồ Tuấn Kiệt",
    "Trương Mỹ Duyên",
    "Võ Hoàng Yến",
    "Lâm Khánh Chi",
    "Đoàn Văn Hậu",
    "Nguyễn Quang Hải",
  ];

  const usersData = vietnameseNames.map((name, index) => {
    const num = index + 1;
    const phone = `09000000${num < 10 ? "0" + num : num}`;
    const isMainUser = num === 1;

    return userRepository.create({
      phone_number: phone,
      full_name: name,
      // User 1: 1.250 điểm -> Hạng Bạc (SILVER)
      total_points: isMainUser ? 1250 : 200 + num * 120,
      membership_tier: isMainUser ? "SILVER" : num % 3 === 0 ? "GOLD" : "STANDARD",
    });
  });
  const users = await userRepository.save(usersData);
  const mainUser = users[0]; // 0900000001

  // ==========================================
  // 4. SINH 20 VOUCHER CHỢ ƯU ĐÃI THỰC TẾ
  // ==========================================
  console.log("🎟️ Tạo 20 voucher ưu đãi sinh động...");
  const voucherConfigs = [
    // Highlands Coffee
    {
      merchantName: "Highlands Coffee",
      title: "Voucher giảm 30.000đ cho đơn từ 99.000đ",
      desc: "Áp dụng tại toàn bộ chuỗi Highlands Coffee trên toàn quốc cho đồ uống và bánh ngọt.",
      cost: 300,
      days: 30,
    },
    {
      merchantName: "Highlands Coffee",
      title: "Giảm 50% Phin Sữa Đá Cỡ Lớn",
      desc: "Thưởng thức ly Phin Sữa Đá truyền thống chuẩn vị Highlands với giá nửa giá.",
      cost: 200,
      days: 20,
    },
    // Phúc Long
    {
      merchantName: "Phúc Long Coffee & Tea",
      title: "Mua 1 Tặng 1 Trà Sữa Phúc Long size L",
      desc: "Tặng 01 ly Trà Sữa Phúc Long cùng size khi mua bất kỳ đồ uống nguyên giá.",
      cost: 450,
      days: 25,
    },
    {
      merchantName: "Phúc Long Coffee & Tea",
      title: "Giảm 25.000đ khi mua từ 2 ly đồ uống",
      desc: "Áp dụng cho dòng Trà Đào Cam Sả, Trà Vải Lài và Trà Sữa Thảo Mộc.",
      cost: 250,
      days: 15,
    },
    // The Coffee House
    {
      merchantName: "The Coffee House",
      title: "Giảm 20% toàn menu thức uống",
      desc: "Không giới hạn số lượng món trên mỗi hóa đơn, áp dụng dùng tại quán hoặc mang đi.",
      cost: 250,
      days: 30,
    },
    {
      merchantName: "The Coffee House",
      title: "Tặng 01 Bánh Mì Chà Bông Phô Mai",
      desc: "Áp dụng kèm hóa đơn thức uống từ 55.000đ tại tất cả chi nhánh The Coffee House.",
      cost: 350,
      days: 14,
    },
    // Gong Cha
    {
      merchantName: "Gong Cha",
      title: "Giảm 50.000đ Trà sữa Trân châu đen",
      desc: "Voucher giảm trực tiếp 50k áp dụng cho dòng Trà sữa Alisan và Trà sữa Earl Grey.",
      cost: 500,
      days: 30,
    },
    {
      merchantName: "Gong Cha",
      title: "Free Upsize toàn bộ dòng trà sủi bọt",
      desc: "Nâng cấp miễn phí từ size M lên size L cho dòng Gong Cha Milk Foam đặc trưng.",
      cost: 150,
      days: 45,
    },
    // Pizza 4P's
    {
      merchantName: "Pizza 4P's",
      title: "Tặng 01 Pizza 4 Cheese cỡ vừa kèm mật ong",
      desc: "Đặc quyền dành riêng cho thành viên TingTing khi dùng bữa tại nhà hàng Pizza 4P's.",
      cost: 1200,
      days: 60,
    },
    {
      merchantName: "Pizza 4P's",
      title: "Giảm 100.000đ cho hóa đơn từ 500.000đ",
      desc: "Áp dụng cho toàn bộ thực đơn khai vị, pizza lò củi thủ công và mì Ý sốt cua.",
      cost: 800,
      days: 30,
    },
    // Haidilao
    {
      merchantName: "Haidilao Hotpot",
      title: "Giảm 15% tổng hóa đơn bàn tiệc",
      desc: "Áp dụng cho bàn từ 4 người trở lên tại Haidilao vào tất cả các ngày trong tuần.",
      cost: 850,
      days: 30,
    },
    {
      merchantName: "Haidilao Hotpot",
      title: "Tặng 01 Đĩa Thịt Bò Mỹ Thượng Hạng",
      desc: "Tặng phần bò Wagyu hoặc ba chỉ bò Mỹ thượng hạng khi gọi lẩu 4 ngăn.",
      cost: 600,
      days: 30,
    },
    // Circle K
    {
      merchantName: "Circle K",
      title: "Voucher mua sắm 50.000đ tiện lợi",
      desc: "Áp dụng thanh toán cho tất cả mặt hàng bánh kẹo, nước ngọt và đồ ăn nhanh.",
      cost: 400,
      days: 30,
    },
    {
      merchantName: "Circle K",
      title: "Combo Nước ngọt + Mì trộn chỉ 100 điểm",
      desc: "Thưởng thức mì trộn trứng xúc xích kèm 01 ly Coca-Cola mát lạnh.",
      cost: 100,
      days: 15,
    },
    // CGV Cinemas
    {
      merchantName: "CGV Cinemas",
      title: "Vé xem phim 2D áp dụng tất cả các ngày",
      desc: "Đổi 01 vé xem phim tiêu chuẩn 2D tại tất cả cụm rạp CGV toàn quốc.",
      cost: 650,
      days: 45,
    },
    {
      merchantName: "CGV Cinemas",
      title: "Combo Bắp Rang Bơ + Nước ngọt CGV",
      desc: "01 phần bắp phô mai/caramel lớn và 02 ly nước ngọt tự chọn.",
      cost: 300,
      days: 30,
    },
    // Uniqlo
    {
      merchantName: "Uniqlo Việt Nam",
      title: "Giảm 100.000đ đơn hàng từ 599.000đ",
      desc: "Áp dụng tại cửa hàng Uniqlo Đồng Khởi, Vincom Landmark 81 và Uniqlo Online.",
      cost: 900,
      days: 60,
    },
    {
      merchantName: "Uniqlo Việt Nam",
      title: "Voucher 200.000đ cho bộ sưu tập LifeWear",
      desc: "Dành cho các dòng sản phẩm AIRism, áo giữ nhiệt HEATTECH và áo thun UT.",
      cost: 1500,
      days: 60,
    },
    // Guardian
    {
      merchantName: "Guardian",
      title: "Voucher 50.000đ cho mỹ phẩm chăm sóc da",
      desc: "Áp dụng cho hóa đơn mua sắm mỹ phẩm, kem chống nắng và dưỡng ẩm từ 199.000đ.",
      cost: 450,
      days: 30,
    },
    {
      merchantName: "Guardian",
      title: "Giảm 15% tất cả sản phẩm chăm sóc sức khỏe",
      desc: "Áp dụng cho vitamin, thực phẩm chức năng và khẩu trang y tế.",
      cost: 300,
      days: 30,
    },
    // ==========================================
    // CÁC VOUCHER LIÊN MINH KÍCH CẦU CHÉO (CROSS-MERCHANT)
    // ==========================================
    {
      merchantName: "Highlands Coffee",
      targetMerchantName: "CGV Cinemas",
      title: "Highlands x CGV: Tặng 01 Vé Xem Phim 2D",
      desc: "Ưu đãi liên minh: Highlands Coffee tài trợ vé xem phim 2D áp dụng tại tất cả cụm rạp CGV toàn quốc.",
      cost: 500,
      days: 45,
    },
    {
      merchantName: "CGV Cinemas",
      targetMerchantName: "The Coffee House",
      title: "CGV x The Coffee House: Giảm 35.000đ sau suất chiếu",
      desc: "Xem phim xong ghé The Coffee House! Giảm ngay 35k cho hóa đơn từ 70k tại toàn bộ chuỗi The Coffee House.",
      cost: 200,
      days: 30,
    },
    {
      merchantName: "Pizza 4P's",
      targetMerchantName: "Uniqlo Việt Nam",
      title: "Pizza 4P's x Uniqlo: Voucher 100.000đ thời trang LifeWear",
      desc: "Thưởng thức Pizza 4P's nhận ngay voucher mua sắm 100.000đ áp dụng tại toàn bộ cửa hàng Uniqlo Việt Nam.",
      cost: 600,
      days: 60,
    },
  ];

  const vouchersData = voucherConfigs.map((vc: any) => {
    const merchant = merchantMap.get(vc.merchantName)!;
    const targetMerchant = vc.targetMerchantName
      ? merchantMap.get(vc.targetMerchantName)
      : null;

    return voucherRepository.create({
      merchant_id: merchant.id,
      target_merchant_id: targetMerchant ? targetMerchant.id : undefined,
      title: vc.title,
      description: vc.desc,
      points_cost: vc.cost,
      total_quantity: 200,
      remaining_quantity: 165,
      expired_at: new Date(Date.now() + vc.days * 24 * 60 * 60 * 1000),
    });
  });
  const vouchers = await voucherRepository.save(vouchersData);
  const voucherMap = new Map(vouchers.map((v) => [v.title, v]));

  // ==========================================
  // 5. SINH KHO VOUCHER CÁ NHÂN (USER 0900000001)
  // ==========================================
  console.log("🎫 Nạp voucher vào ví của tài khoản 0900000001...");
  const userVouchersData = [
    // 3 Voucher ĐANG CÓ (ACTIVE)
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Mua 1 Tặng 1 Trà Sữa Phúc Long size L")!.id,
      status: UserVoucherStatus.ACTIVE,
      created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // Đổi 2 ngày trước
    }),
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Voucher giảm 30.000đ cho đơn từ 99.000đ")!.id,
      status: UserVoucherStatus.ACTIVE,
      created_at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000), // Đổi 4 ngày trước
    }),
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Vé xem phim 2D áp dụng tất cả các ngày")!.id,
      status: UserVoucherStatus.ACTIVE,
      created_at: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000), // Đổi 6 ngày trước
    }),

    // 2 Voucher ĐÃ DÙNG (USED)
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Giảm 20% toàn menu thức uống")!.id,
      status: UserVoucherStatus.USED,
      redeemed_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // Dùng 3 ngày trước tại TCH
      created_at: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000),
    }),
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Giảm 50.000đ Trà sữa Trân châu đen")!.id,
      status: UserVoucherStatus.USED,
      redeemed_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // Dùng 10 ngày trước tại Gong Cha
      created_at: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
    }),

    // 1 Voucher HẾT HẠN (EXPIRED)
    userVoucherRepository.create({
      user_id: mainUser.id,
      voucher_id: voucherMap.get("Voucher mua sắm 50.000đ tiện lợi")!.id,
      status: UserVoucherStatus.EXPIRED,
      created_at: new Date(Date.now() - 35 * 24 * 60 * 60 * 1000),
    }),
  ];
  await userVoucherRepository.save(userVouchersData);

  // ==========================================
  // 6. SINH LỊCH SỬ GIAO DỊCH (USER 0900000001)
  // Tổng biến động: +450 + 2000 + 55 + 350 - 250 + 95 - 500 + 80 - 650 + 250 - 300 - 450 + 120 = 1250 VUI (Khớp 100% total_points)
  // ==========================================
  console.log("📊 Nạp lịch sử giao dịch điểm cho 0900000001...");
  const mainUserTransactions = [
    // Hôm qua: Tích điểm Highlands Coffee
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Highlands Coffee")!.id,
      type: TransactionType.EARN,
      points_delta: 120,
      bill_amount: 1200000,
      created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
    }),
    // 2 ngày trước: Đổi voucher Phúc Long Mua 1 Tặng 1
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Phúc Long Coffee & Tea")!.id,
      type: TransactionType.REDEEM,
      points_delta: 450,
      bill_amount: 0,
      created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
    }),
    // 3 ngày trước: Tích điểm The Coffee House
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("The Coffee House")!.id,
      type: TransactionType.EARN,
      points_delta: 80,
      bill_amount: 800000,
      created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    }),
    // 4 ngày trước: Đổi voucher Highlands Coffee
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Highlands Coffee")!.id,
      type: TransactionType.REDEEM,
      points_delta: 300,
      bill_amount: 0,
      created_at: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
    }),
    // 5 ngày trước: Tích điểm Haidilao Hotpot
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Haidilao Hotpot")!.id,
      type: TransactionType.EARN,
      points_delta: 250,
      bill_amount: 2500000,
      created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
    }),
    // 6 ngày trước: Đổi vé xem phim CGV
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("CGV Cinemas")!.id,
      type: TransactionType.REDEEM,
      points_delta: 650,
      bill_amount: 0,
      created_at: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
    }),
    // 8 ngày trước: Tích điểm Pizza 4P's
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Pizza 4P's")!.id,
      type: TransactionType.EARN,
      points_delta: 350,
      bill_amount: 3500000,
      created_at: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000),
    }),
    // 10 ngày trước: Đổi voucher Gong Cha
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Gong Cha")!.id,
      type: TransactionType.REDEEM,
      points_delta: 500,
      bill_amount: 0,
      created_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
    }),
    // 12 ngày trước: Tích điểm Gong Cha
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Gong Cha")!.id,
      type: TransactionType.EARN,
      points_delta: 95,
      bill_amount: 950000,
      created_at: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000),
    }),
    // 15 ngày trước: Đổi voucher The Coffee House
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("The Coffee House")!.id,
      type: TransactionType.REDEEM,
      points_delta: 250,
      bill_amount: 0,
      created_at: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000),
    }),
    // 18 ngày trước: Tích điểm Circle K
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Circle K")!.id,
      type: TransactionType.EARN,
      points_delta: 55,
      bill_amount: 550000,
      created_at: new Date(Date.now() - 18 * 24 * 60 * 60 * 1000),
    }),
    // 22 ngày trước: Tích điểm mua sắm thời trang Uniqlo
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Uniqlo Việt Nam")!.id,
      type: TransactionType.EARN,
      points_delta: 2000,
      bill_amount: 20000000,
      created_at: new Date(Date.now() - 22 * 24 * 60 * 60 * 1000),
    }),
    // 28 ngày trước: Điểm thưởng chào mừng thành viên mới TingTing
    transactionRepository.create({
      user_id: mainUser.id,
      merchant_id: merchantMap.get("Highlands Coffee")!.id,
      type: TransactionType.EARN,
      points_delta: 450,
      bill_amount: 0,
      created_at: new Date(Date.now() - 28 * 24 * 60 * 60 * 1000),
    }),
  ];
  await transactionRepository.save(mainUserTransactions);

  // Sinh thêm một số giao dịch cho các User khác để bảng tổng thể phong phú
  const extraTransactions = [];
  for (let i = 1; i < users.length; i++) {
    const u = users[i];
    const m = merchants[i % merchants.length];
    extraTransactions.push(
      transactionRepository.create({
        user_id: u.id,
        merchant_id: m.id,
        type: TransactionType.EARN,
        points_delta: 100,
        bill_amount: 1000000,
      }),
    );
  }
  await transactionRepository.save(extraTransactions);

  console.log("✅ Hoàn tất nạp dữ liệu mẫu sinh động thành công 100%!");
}
