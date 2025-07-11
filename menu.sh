#!/bin/bash
# Menu CLI Warna-warni by xydark

function loading() {
  echo -ne "\e[1;36m⏳ Loading"
  for i in {1..3}; do
    echo -ne "."
    sleep 0.3
  done
  echo -e "\e[0m"
  sleep 0.3
  clear
}

clear
echo -e "\e[1;36m╔════════════════════════════════════════╗"
echo -e "║         TUNNELING AUTO SCRIPT          ║"
echo -e "║           by t.me/xydark               ║"
echo -e "╠════════════════════════════════════════╣"
echo -e "║ 1. SSH & OpenVPN Menu                  ║"
echo -e "║ 2. XRAY / VMess / VLESS / Trojan Menu  ║"
echo -e "║ 3. System Settings                     ║"
echo -e "║ 0. Exit                                ║"
echo -e "╚════════════════════════════════════════╝\e[0m"
read -rp " Select menu [0-3]: " menu

case "$menu" in
    1) loading; menu-ssh ;;
    2) loading; menu-xray ;;
    3) loading; menu-set ;;
    0) echo -e "\e[1;32mBye! 👋\e[0m"; exit ;;
    *) echo -e "\e[1;31mInvalid input! Kembali ke menu...\e[0m"; sleep 1; /usr/bin/menu ;;
esac
