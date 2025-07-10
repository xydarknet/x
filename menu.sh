#!/bin/bash
# Menu Utama by xydark

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

while true; do
clear
echo -e "${BLUE}╔════════════════════════════════════════╗"
echo -e "${BLUE}║${NC}         ${YELLOW}TUNNELING AUTO SCRIPT${NC}          ${BLUE}║"
echo -e "${BLUE}║${NC}           ${GREEN}by t.me/xydark${NC}              ${BLUE}║"
echo -e "${BLUE}╠════════════════════════════════════════╣"
echo -e "${BLUE}║${NC} 1. SSH & OpenVPN Menu                   ${BLUE}║"
echo -e "${BLUE}║${NC} 2. XRAY / VMess / VLESS / Trojan Menu  ${BLUE}║"
echo -e "${BLUE}║${NC} 3. System Settings                     ${BLUE}║"
echo -e "${BLUE}║${NC} 0. Exit                                ${BLUE}║"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
read -rp " Select menu [0-3]: " opt
case $opt in
  1) menu-ssh ;;
  2) menu-xray ;;
  3) menu-setting ;;
  0) exit ;;
  *) echo -e "${RED} Invalid input!${NC}"; sleep 1 ;;
esac
done
