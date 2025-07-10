#!/bin/bash

◦•●◉✿script by xydark✿◉●•◦

Auto Install + Dynamic Info + UI + GitHub Auto Update

https://github.com/xydarknet/x (repo)

============ WARNA =============

RED='\e[31m' GREEN='\e[32m' YELLOW='\e[33m' BLUE='\e[34m' CYAN='\e[36m' NC='\e[0m'

============ LOKASI FILE =============

INSTALL_DIR="/etc/xydark" FLAG="$INSTALL_DIR/.installed" CLIENT_FILE="$INSTALL_DIR/client.conf" VERSION_FILE="$INSTALL_DIR/version.conf" EXPIRE_FILE="$INSTALL_DIR/expire.conf" REPO="https://raw.githubusercontent.com/xydarknet/x/main"

============ HEADER ANIMASI =============

function header_ui() { clear echo -e "${CYAN}◦•●◉✿ ${YELLOW}WELCOME TO XYDARK MENU${CYAN} ✿◉●•◦" echo -e "${CYAN}═════════════════════════════════════════════════════" echo -e "${BLUE}     AUTO SCRIPT TUNNELING - UI DYNAMIC SYSTEM" echo -e "     GitHub: github.com/xydarknet/x  |  Telegram: @xydark" echo -e "${CYAN}═════════════════════════════════════════════════════${NC}" sleep 1 }

============ AUTO INSTALL =============

auto_install() { echo -e "${CYAN}[*] Instalasi awal sedang diproses...${NC}" mkdir -p $INSTALL_DIR apt update -y &>/dev/null apt install curl jq lsb-release dnsutils net-tools -y &>/dev/null echo "kalya" > "$CLIENT_FILE" echo "1.2.5" > "$VERSION_FILE" echo "2025-08-06" > "$EXPIRE_FILE" touch "$FLAG" echo -e "${GREEN}[+] Instalasi selesai.${NC}" sleep 1 }

============ AUTO UPDATE =============

auto_update() { echo -e "${YELLOW}[*] Mengecek pembaruan dari GitHub...${NC}" LATEST_VERSION=$(curl -s "$REPO/version.txt") CURRENT_VERSION=$(cat "$VERSION_FILE") if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" && ! -z "$LATEST_VERSION" ]]; then echo -e "${GREEN}[+] Update tersedia: $CURRENT_VERSION → $LATEST_VERSION${NC}" curl -s "$REPO/setup.sh" -o /usr/local/bin/setup && chmod +x /usr/local/bin/setup echo "$LATEST_VERSION" > "$VERSION_FILE" echo -e "${GREEN}[+] Script berhasil diupdate.${NC}" else echo -e "${CYAN}[i] Script sudah versi terbaru.${NC}" fi sleep 1 }

============ JALANKAN AUTO INSTALL JIKA BELUM =============

[ ! -f "$FLAG" ] && auto_install

============ INFO SISTEM =============

CLIENT=$(cat "$CLIENT_FILE") VER=$(cat "$VERSION_FILE") EXPDATE=$(cat "$EXPIRE_FILE") OS=$(hostnamectl | grep "Operating System" | cut -d ' ' -f5-) KERNEL=$(uname -r) CPU=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed -e 's/^\s*//') FREQ=$(awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sed -n 1p | sed -e 's/^\s*//') CORE=$(nproc) RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}') RAM_USED=$(free -m | awk '/Mem:/ {print $3}') DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}') DISK_USED=$(df -h / | awk 'NR==2 {print $3}') IPVPS=$(curl -s ipv4.icanhazip.com) ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-) REGION=$(curl -s ipinfo.io/region) TZ=$(curl -s ipinfo.io/timezone) DOMAIN="xydark.biz.id" SDOMAIN="ns.xydark.biz.id" TGID="@xydark" TODAY=$(date +%s) EXPIRE=$(date -d "$EXPDATE" +%s) DAYS_LEFT=$(( (EXPIRE - TODAY) / 86400 ))

============ HEADER & MENU =============

auto_update header_ui

echo -e "${CYAN}╔════════════════════════════════════╗" echo -e "║              ${YELLOW}SYS INFO${CYAN}              ║" echo -e "╚════════════════════════════════════╝" echo -e " OS SYSTEM     : ${OS}" echo -e " KERNEL TYPE   : ${KERNEL}" echo -e " CPU MODEL     : ${CPU}" echo -e " CPU FREQUENCY : ${FREQ} MHz (${CORE} Core)" echo -e " TOTAL RAM     : ${RAM_TOTAL} MB Total / ${RAM_USED} MB Used" echo -e " TOTAL STORAGE : ${DISK_TOTAL} Total / ${DISK_USED} Used" echo -e " DOMAIN        : ${DOMAIN}" echo -e " SLOWDNS DOMAIN: ${SDOMAIN}" echo -e " IP ADDRESS    : ${IPVPS}" echo -e " ISP           : ${ISP}" echo -e " REGION        : ${REGION} [${TZ}]" echo -e " CLIENTNAME    : ${CLIENT}" echo -e " SCRIPT VERSION: ${VER}" echo -e "══════════════════════════════════════" echo -e " EXP SCRIPT: ${EXPDATE} (${DAYS_LEFT} days)" echo -e " REGIST BY : ${TGID}" echo -e "══════════════════════════════════════" echo -e "" echo -e "${GREEN}========= MAIN MENU =========${NC}" echo -e "${GREEN}1.${NC} MENU SSH & OVPN" echo -e "${GREEN}2.${NC} MENU XRAY" echo -e "${GREEN}3.${NC} MENU L2TP" echo -e "${GREEN}4.${NC} MENU NOOBZVPNS" echo -e "${GREEN}5.${NC} SETTINGS" echo -e "${GREEN}6.${NC} ON/OFF SERVICES" echo -e "${GREEN}7.${NC} STATUS SERVICES" echo -e "${GREEN}8.${NC} UPDATE SCRIPT" echo -e "${GREEN}9.${NC} REBUILD OS" echo -e "${GREEN}0.${NC} Exit" echo -ne "\n${YELLOW}Select menu [0-9]: ${NC}" read opt

case $opt in

1. clear; menu-ssh ;;


2. clear; menu-xray ;;


3. clear; menu-l2tp ;;


4. clear; menu-noobz ;;


5. clear; menu-setting ;;


6. clear; menu-onoff ;;


7. clear; menu-status ;;


8. clear; auto_update ; bash setup.sh ;;


9. clear; rebuild-os ;;


10. clear; exit ;; *) echo -e "${RED}Invalid option.${NC}" && sleep 1 && bash setup.sh ;; esac



