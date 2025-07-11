#!/bin/bash
# ◦•●◉✿ MENU UTAMA TUNNELING v1.0.0 by xydark ✿◉●•◦

# === WARNA ===
GREEN='\e[92m'
CYAN='\e[96m'
YELLOW='\e[93m'
RED='\e[91m'
NC='\e[0m'

# === INFO VPS ===
OS=$(grep -oP '(?<=PRETTY_NAME=")[^"]+' /etc/os-release)
KERNEL=$(uname -r)
CPU=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^ //')
CPUFREQ=$(awk -F: '/cpu MHz/ {printf "%.0f", $2; exit}' /proc/cpuinfo)
CPUNUM=$(grep -c ^processor /proc/cpuinfo)
RAMTOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAMUSED=$(free -m | awk '/Mem:/ {print $3}')
STORAGETOTAL=$(df -h / | awk 'NR==2 {print $2}')
STORAGEUSED=$(df -h / | awk 'NR==2 {print $3}')
IPV4=$(curl -s ipv4.icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-)
CITY=$(curl -s ipinfo.io/city)
REGION=$(curl -s ipinfo.io/timezone)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null)
SLOWDNS=$(cat /etc/xray/dns 2>/dev/null || echo "-")
CLIENTNAME=$(cat /etc/xydark/clientname 2>/dev/null || echo "")
SCRIPTVER="1.0,0"
EXPIRE_DATE=""
TELEGRAM_ID="1389219385"

# === HEADER ===
clear
echo -e "${CYAN}╔════════════════════════════════════════════╗"
echo -e "║           ${YELLOW}sc by t.me/xydark${CYAN}               ║"
echo -e "╚════════════════════════════════════════════╝"
echo -e "${CYAN}╔════════════════════════════════════════════╗"
echo -e "║              ${YELLOW}SYS INFO${CYAN}                      ║"
echo -e "╚════════════════════════════════════════════╝${NC}"
echo -e " ${YELLOW}OS SYSTEM     :${NC} $OS"
echo -e " ${YELLOW}KERNEL TYPE   :${NC} $KERNEL"
echo -e " ${YELLOW}CPU MODEL     :${NC} $CPU"
echo -e " ${YELLOW}CPU FREQUENCY :${NC} $CPUFREQ MHz ($CPUNUM core)"
echo -e " ${YELLOW}TOTAL RAM     :${NC} ${RAMTOTAL} MB Total / ${RAMUSED} MB Used"
echo -e " ${YELLOW}TOTAL STORAGE :${NC} $STORAGETOTAL Total / $STORAGEUSED Used"
echo -e " ${YELLOW}DOMAIN        :${NC} ${DOMAIN:-'-'}"
echo -e " ${YELLOW}SLOWDNS DOMAIN:${NC} $SLOWDNS"
echo -e " ${YELLOW}IP ADDRESS    :${NC} $IPV4"
echo -e " ${YELLOW}ISP           :${NC} $ISP"
echo -e " ${YELLOW}REGION        :${NC} $CITY [$REGION]"
echo -e " ${YELLOW}CLIENTNAME    :${NC} $CLIENTNAME"
echo -e " ${YELLOW}SCRIPT VERSION:${NC} $SCRIPTVER"
echo -e "${CYAN}╔════════════════════════════════════════════╗"
echo -e "║  ${YELLOW}1${CYAN}. SSH & OVPN ACCOUNT                      ║"
echo -e "║  ${YELLOW}2${CYAN}. XRAY ACCOUNT                             ║"
echo -e "║  ${YELLOW}3${CYAN}. L2TP ACCOUNT                             ║"
echo -e "║  ${YELLOW}4${CYAN}. NOOBZVPNS ACCOUNT                        ║"
echo -e "╚════════════════════════════════════════════╝"
echo -e "${CYAN}╔════════════════════════════════════════════╗"
echo -e "║               ${YELLOW}MAIN MENU${CYAN}                     ║"
echo -e "╚════════════════════════════════════════════╝"
echo -e " ${YELLOW}1${NC}. MENU SSH & OVPN"
echo -e " ${YELLOW}2${NC}. MENU XRAY"
echo -e " ${YELLOW}3${NC}. MENU L2TP"
echo -e " ${YELLOW}4${NC}. MENU NOOBZVPNS"
echo -e " ${YELLOW}5${NC}. SETTINGS"
echo -e " ${YELLOW}6${NC}. ON/OFF SERVICES"
echo -e " ${YELLOW}7${NC}. STATUS SERVICES"
echo -e " ${YELLOW}8${NC}. UPDATE SCRIPT"
echo -e " ${YELLOW}9${NC}. REBUILD OS"
echo -e " ${YELLOW}0${NC}. Exit"
echo -e "${CYAN}══════════════════════════════════════════════"
echo -e " EXP SCRIPT : ${RED}$EXPIRE_DATE${NC}"
echo -e " REGIST BY  : ${CYAN}$TELEGRAM_ID${NC} (id telegram)"
echo -e "══════════════════════════════════════════════${NC}"
read -rp "Please select an option [0-9]: " opt

case $opt in
  1) clear; menu-ssh ;;
  2) clear; menu-xray ;;
  3) clear; echo "🔧 MENU L2TP (belum tersedia)" ;;
  4) clear; echo "🔧 MENU NOOBZVPNS (belum tersedia)" ;;
  5) clear; menu-set ;;
  6) clear; echo "⚙️ Fitur ON/OFF SERVICE belum diimplementasi" ;;
  7) clear; echo "ℹ️ STATUS SERVICE belum diimplementasi" ;;
  8) clear; update-script ;;
  9) clear; echo "⚠️ Fitur REBUILD OS akan segera tersedia" ;;
  0) clear; exit ;;
  *) echo -e "${RED}❌ Pilihan tidak valid!${NC}"; sleep 1; menu ;;
esac
