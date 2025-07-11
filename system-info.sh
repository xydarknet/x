#!/bin/bash
# system-info.sh by t.me/xydark

# Ambil IP Publik dan GeoIP
IP=$(curl -s ipv4.icanhazip.com)
GEO=$(curl -s https://ipinfo.io/json)
CITY=$(echo "$GEO" | grep city | cut -d '"' -f4)
REGION=$(echo "$GEO" | grep region | cut -d '"' -f4)
COUNTRY=$(echo "$GEO" | grep country | cut -d '"' -f4)
ORG=$(echo "$GEO" | grep org | cut -d '"' -f4)

# Waktu dan sistem
DATE=$(date "+%A, %d %B %Y")
TIME=$(date "+%T")
UPTIME=$(uptime -p | cut -d " " -f2-)
KERNEL=$(uname -r)
OS=$(hostnamectl | grep "Operating System" | cut -d ':' -f2- | xargs)
ARCH=$(uname -m)

# Resource
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
RAM_TOTAL=$(free -m | awk '/Mem/ {print $2}')
RAM_USED=$(free -m | awk '/Mem/ {print $3}')
RAM_FREE=$(free -m | awk '/Mem/ {print $4}')

# Tampilan
clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║        🔰 VPS TUNNEL SCRIPT by xydark        ║"
echo -e "║         t.me/xydark | xydark.net             ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 📆 Tanggal   : $DATE"
echo -e "║ ⏰ Waktu     : $TIME"
echo -e "║ 🖥 OS        : $OS"
echo -e "║ 🧠 Kernel    : $KERNEL ($ARCH)"
echo -e "║ ⏳ Uptime    : $UPTIME"
echo -e "║ 💾 RAM       : $RAM_USED / $RAM_TOTAL MB"
echo -e "║ ⚙️ CPU Usage : $CPU_USAGE"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 🌐 IP Publik : $IP"
echo -e "║ 📍 Lokasi    : $CITY, $REGION, $COUNTRY"
echo -e "║ 🛰 ISP       : $ORG"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
echo ""
