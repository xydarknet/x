#!/bin/bash
# system-info.sh by xydark

clear
echo -e "\e[1;32m╔══════════════════════════════════════════════╗"
echo -e "║             SYSTEM INFORMATION              ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"

uptime=$(uptime -p)
os=$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release | tr -d '"')
kernel=$(uname -r)
cpu=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ //')
mem=$(free -m | awk '/Mem:/ {printf "%s MB", $2}')
ip=$(curl -s ifconfig.me)

echo -e "🖥  OS          : $os"
echo -e "🧠 Kernel      : $kernel"
echo -e "⚙️  CPU         : $cpu"
echo -e "💾 RAM         : $mem"
echo -e "🌐 Public IP   : $ip"
echo -e "⏱  Uptime      : $uptime"
echo -e ""
echo -e "\e[1;33m- by t.me/xydark\e[0m"
