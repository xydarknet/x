#!/bin/bash
# ◦•●◉✿ Submenu Create XRAY by xydark ✿◉●•◦

# WARNA
green="\e[32m"
red="\e[31m"
blue="\e[34m"
yellow="\e[33m"
cyan="\e[36m"
bold="\e[1m"
reset="\e[0m"

clear
echo -e "${green}╔════════════════════════════════════════════╗"
echo -e "${green}║          ${bold}CREATE XRAY ACCOUNT${reset}${green}              ║"
echo -e "${green}╚════════════════════════════════════════════╝${reset}"
echo -e "${blue}┌────────────────────────────────────────────┐${reset}"
echo -e "${blue}│ ${yellow}${bold}1${reset}${blue}. VMESS WS                         │"
echo -e "${blue}│ ${yellow}${bold}2${reset}${blue}. VMESS gRPC                       │"
echo -e "${blue}│ ${yellow}${bold}3${reset}${blue}. VMESS HTTP Upgrade               │"
echo -e "${blue}├────────────────────────────────────────────┤"
echo -e "${blue}│ ${yellow}${bold}4${reset}${blue}. VLESS WS                         │"
echo -e "${blue}│ ${yellow}${bold}5${reset}${blue}. VLESS gRPC                       │"
echo -e "${blue}│ ${yellow}${bold}6${reset}${blue}. VLESS HTTP Upgrade               │"
echo -e "${blue}│ ${yellow}${bold}7${reset}${blue}. VLESS XTLS                       │"
echo -e "${blue}├────────────────────────────────────────────┤"
echo -e "${blue}│ ${yellow}${bold}8${reset}${blue}. TROJAN                          │"
echo -e "${blue}│ ${yellow}${bold}9${reset}${blue}. TROJAN WS                       │"
echo -e "${blue}│ ${yellow}${bold}10${reset}${blue}. TROJAN gRPC                     │"
echo -e "${blue}│ ${yellow}${bold}11${reset}${blue}. TROJAN HTTP Upgrade             │"
echo -e "${blue}├────────────────────────────────────────────┤"
echo -e "${blue}│ ${yellow}${bold}0${reset}${blue}. Back to XRAY Menu               │"
echo -e "${blue}└────────────────────────────────────────────┘${reset}"
echo -ne "${bold}Please select an option [0-11]: ${reset}"
read opt

case $opt in
  1) addvmess ;;
  2) addvmessgrpc ;;
  3) addvmesshttp ;;
  4) addvless ;;
  5) addvlessgrpc ;;
  6) addvlesshttp ;;
  7) addvlessxtls ;;
  8) addtrojan ;;
  9) addtrojanws ;;
 10) addtrojangrpc ;;
 11) addtrojanhttp ;;
  0) menu-xray ;;
  *) echo -e "${red}Invalid option!${reset}"; sleep 2; menu-createxray ;;
esac
