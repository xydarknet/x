#!/bin/bash
# Menu CLI Warna-warni by xydark

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
    1) menu-ssh ;;
    2) menu-xray ;;
    3) menu-set ;;
    0) exit ;;
    *) echo -e "\e[1;31mInvalid input!\e[0m"; sleep 1; menu ;;
esac
