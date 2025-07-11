#!/bin/bash
# ◦•●◉✿ MENU UTAMA TUNNELING by xydark ✿◉●•◦

clear
# GATHER SYS INFO
os=$(hostnamectl | grep "Operating System" | cut -d ':' -f2 | xargs)
kernel=$(uname -r)
cpu_model=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | xargs)
cpu_freq=$(awk -F'[ :]' '/cpu MHz/ {print $NF; exit}' /proc/cpuinfo)
cpu_cores=$(nproc)
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_used=$(df -h / | awk 'NR==2 {print $3}')
ip=$(curl -s ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain 2>/dev/null || echo '-')
slowdns=$(cat /etc/xray/dns 2>/dev/null || echo '-')
isp=$(curl -s ipinfo.io/org | cut -d " " -f 2-)
region=$(curl -s ipinfo.io/timezone)
client="kalya"
version="1.2.5"
exp="2025-08-06"
idtg="1389219385"

# HEADER
clear
echo -e "\e[1;36m╔════════════════════════════════════════════╗\e[0m"
echo -e "║ sc by t.me/xydark                       ║"
echo -e "\e[1;36m╚════════════════════════════════════════════╝\e[0m"

echo -e "\e[1;36m╔════════════════════════════════════════════╗\e[0m"
echo -e "║              SYS INFO                      ║"
echo -e "\e[1;36m╚════════════════════════════════════════════╝\e[0m"
echo -e " OS SYSTEM: $os"
echo -e " KERNEL TYPE: $kernel"
echo -e " CPU MODEL:  $cpu_model"
echo -e " CPU FREQUENCY: ${cpu_freq} MHz ($cpu_cores core)"
echo -e " TOTAL RAM: ${mem_total} MB Total / ${mem_used} MB Used"
echo -e " TOTAL STORAGE: $disk_total Total / $disk_used Used"
echo -e " DOMAIN: $domain"
echo -e " SLOWDNS DOMAIN: $slowdns"
echo -e " IP ADDRESS: $ip"
echo -e " ISP: $isp"
echo -e " REGION: $region"
echo -e " CLIENTNAME: $client"
echo -e " SCRIPT VERSION: $version"

echo -e "\e[1;36m╔════════════════════════════════════════════╗\e[0m"
echo -e "        SSH & OVPN ACCOUNT ➠ 1"
echo -e " ————————————————————————————————————"
echo -e "          XRAY ACCOUNT ➠ 25"
echo -e " ————————————————————————————————————"
echo -e "          L2TP ACCOUNT ➠ 0"
echo -e " ————————————————————————————————————"
echo -e "         NOOBZ ACCOUNT ➠  0"

echo -e "\e[1;36m╔════════════════════════════════════════════╗\e[0m"
echo -e "║             MAIN MENU                      ║"
echo -e "\e[1;36m╚════════════════════════════════════════════╝\e[0m"
echo -e "1. MENU SSH & OVPN"
echo -e "2. MENU XRAY"
echo -e "3. MENU L2TP"
echo -e "4. MENU NOOBZVPNS"
echo -e "5. SETTINGS"
echo -e "6. ON/OFF SERVICES"
echo -e "7. STATUS SERVICES"
echo -e "8. UPDATE SCRIPT"
echo -e "9. REBUILD OS"
echo -e "0. Exit"
echo -e "══════════════════════════════════════════════"
echo -e "EXP SCRIPT: $exp"
echo -e "REGIST BY : $idtg (id telegram)"
echo -e "══════════════════════════════════════════════"

read -rp "Please select an option [0-9]: " menu

case $menu in
    1) menu-ssh ;;
    2) menu-xray ;;
    3) echo "📛 L2TP menu belum tersedia." ;;
    4) echo "📛 Noobz menu belum tersedia." ;;
    5) menu-set ;;
    6) menu-service-toggle ;;  # Pastikan tersedia
    7) menu-service-status  ;;  # Pastikan tersedia
    8) update-script ;;
    9) rebuild-os ;;  # Pastikan tersedia
    0) exit ;;
    *) echo -e "\e[1;31m❌ Pilihan tidak valid!\e[0m"; sleep 2; /usr/bin/menu.sh ;;
esac
