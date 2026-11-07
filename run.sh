#!/usr/bin/env bash
# ==============================================================================
# File: run.sh
# Description: Script khởi chạy 1-chạm (One-Click Launcher) cho toàn bộ hệ thống TingTing
# ==============================================================================

set -e

# Thư mục gốc dự án
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Nạp đường dẫn cho Flutter và Android SDK Platform-tools (ADB)
export PATH="/home/thien/Android/Sdk/platform-tools:/var/lib/snapd/snap/bin:$PATH"

# Bảng mã màu terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}====================================================${NC}"
echo -e "${CYAN}${BOLD}   🔔 TingTing - One-Click Launcher (Khởi Chạy Nhanh) ${NC}"
echo -e "${CYAN}${BOLD}====================================================${NC}"

# ------------------------------------------------------------------------------
# 1. Khởi động Cơ sở dữ liệu (PostgreSQL qua Docker)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/4] Kiểm tra Cơ sở dữ liệu (Docker PostgreSQL)...${NC}"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q 'tingting_postgres'; then
    echo -e "${GREEN}✓ Database PostgreSQL đang chạy.${NC}"
else
    echo -e "Đang khởi động Docker PostgreSQL..."
    docker-compose up -d
    echo -e "${GREEN}✓ Đã bật Docker PostgreSQL thành công.${NC}"
fi

# ------------------------------------------------------------------------------
# 2. Khởi động Backend Server (NestJS - Port 3000 & 3001)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/4] Kiểm tra Backend NestJS Server...${NC}"
if ss -tulpn 2>/dev/null | grep -q ':3000 ' || lsof -i :3000 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend server đã đang chạy tại http://localhost:3000.${NC}"
else
    echo -e "Đang bật Backend server ngầm..."
    cd "$PROJECT_DIR/backend"
    nohup npm run start:dev > /tmp/tingting_backend.log 2>&1 &
    
    # Chờ port 3000 mở (tối đa 15 giây)
    echo -n "Đang chờ backend sẵn sàng"
    for i in {1..20}; do
        if ss -tulpn 2>/dev/null | grep -q ':3000 ' || nc -z 127.0.0.1 3000 2>/dev/null; then
            break
        fi
        echo -n "."
        sleep 1
    done
    echo ""
    echo -e "${GREEN}✓ Backend đã sẵn sàng tại http://localhost:3000 (Log: /tmp/tingting_backend.log).${NC}"
    cd "$PROJECT_DIR"
fi

# ------------------------------------------------------------------------------
# 3. Kết nối Điện thoại Android & Mở Merchant App
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/4] Kiểm tra kết nối Điện thoại (Merchant App)...${NC}"
DEVICE=$(adb devices 2>/dev/null | grep -w "device" | awk '{print $1}' | head -n 1 || true)
if [ -n "$DEVICE" ]; then
    echo -e "${GREEN}✓ Tìm thấy điện thoại: $DEVICE${NC}"
    echo -e "Đang cấu hình đảo cổng USB (adb reverse 3000, 3001)..."
    adb reverse tcp:3000 tcp:3000
    adb reverse tcp:3001 tcp:3001
    echo -e "Đang kích hoạt mở Merchant App trên điện thoại..."
    adb shell am start -n com.example.app_merchant/.MainActivity >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Đã mở Merchant App trên màn hình điện thoại.${NC}"
else
    echo -e "${RED}⚠️ Chưa phát hiện điện thoại cắm cáp USB (hoặc chưa nhấn Cho phép gỡ lỗi USB).${NC}"
    echo -e "  (Nếu muốn test Merchant App trên điện thoại: Cắm cáp USB và chạy lại script này)${NC}"
fi

# ------------------------------------------------------------------------------
# 4. Mở Client App (User App) trên Laptop
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/4] Khởi chạy Client App (User) trên Laptop...${NC}"
cd "$PROJECT_DIR/app_user"

# Đóng instance cũ nếu đang chạy để nạp bản mới
pkill -f "bundle/app_user" 2>/dev/null || true

if [ "$1" == "--dev" ] || [ "$1" == "-d" ]; then
    echo -e "${CYAN}Chạy chế độ Dev (hỗ trợ Hot Reload 'r' trong terminal):${NC}"
    flutter run -d linux
else
    if [ -f "$PROJECT_DIR/app_user/build/linux/x64/debug/bundle/app_user" ]; then
        echo -e "${GREEN}Khởi động giao diện Client App siêu tốc (< 1s)...${NC}"
        export DISPLAY="${DISPLAY:-:0}"
        nohup ./build/linux/x64/debug/bundle/app_user > /tmp/tingting_app_user.log 2>&1 &
        echo -e "${GREEN}✓ Cửa sổ Client App đã mở trực tiếp trên màn hình laptop!${NC}"
        echo -e "\n${CYAN}💡 Mẹo: Chạy './run.sh --dev' nếu bạn muốn bật chế độ Hot Reload khi code.${NC}"
        echo -e "${CYAN}💡 Chạy './stop.sh' khi muốn đóng nhanh các app.${NC}"
    else
        echo -e "Chưa tìm thấy bản build sẵn, đang biên dịch và chạy qua Flutter..."
        flutter run -d linux
    fi
fi

echo -e "\n${GREEN}${BOLD}✨ Toàn bộ hệ thống TingTing đã sẵn sàng để test! 🔔${NC}\n"
