#!/usr/bin/env bash
# ==============================================================================
# File: stop.sh
# Description: Dừng toàn bộ các ứng dụng TingTing đang chạy ngầm
# ==============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Đang dừng các ứng dụng TingTing...${NC}"

# 1. Dừng Client App trên Laptop
echo -e "${YELLOW}Dừng Client App...${NC}"
pkill -f "bundle/app_user" 2>/dev/null || true
pkill -f "flutter_tools.*app_user" 2>/dev/null || true

# 2. Dừng Backend Server
echo -e "${YELLOW}Dừng Backend Server...${NC}"
pkill -f "nest start" 2>/dev/null || true
pkill -f "node.*tingting" 2>/dev/null || true
fuser -k 3000/tcp 2>/dev/null || true
fuser -k 3001/tcp 2>/dev/null || true

echo -e "${GREEN}✓ Đã dừng Client App và Backend Server thành công.${NC}"
echo -e "*(Lưu ý: Docker Database vẫn được giữ để không mất dữ liệu. Nếu muốn tắt Docker: docker-compose down)*\n"
