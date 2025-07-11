#!/bin/bash
# ◦•●◉✿ menu XRAY by xydark ✿◉●•◦

# Warna
green="\e[32m"
red="\e[31m"
blue="\e[34m"
yellow="\e[33m"
cyan="\e[36m"
bold="\e[1m"
reset="\e[0m"

# Info
script_version="1.0.0"
xray_version=$(xray version 2>/dev/null | grep -i 'Xray' | head -n1 | awk '{print $2}')

clear
echo -e "${cyan}${bold}SCRIPT VERSION: ${script_version}${reset}"
echo -e "${green}╔════════════════════════════════════╗"
echo -e "${green}║            ${bold}MENU XRAY${reset}${green}              ║"
echo -e "${green}╚════════════════════════════════════╝"
echo -e "${yellow}Xray Version: ${xray_version}${reset}"
echo -e "${green}======================================${reset}"
echo -e "${bold} 1${reset}. Create XRAY"
echo -e "${bold} 2${reset}. Trial XRAY"
echo -e "${bold} 3${reset}. Renew XRAY"
echo -e "${bold} 4${reset}. Detail XRAY"
echo -e "${bold} 5${reset}. Delete XRAY"
echo -e "${bold} 6${reset}. Check XRAY Login"
echo -e "${bold} 7${reset}. Change XRAY Path"
echo -e "${bold} 8${reset}. Change Limit or Add Limit IP"
echo -e "${bold} 9${reset}. Change Limit or Add Limit Quota"
echo -e "${bold}10${reset}. Unban XRAY"
echo -e "${bold}11${reset}. List Users Expiring Within 3 Days"
echo -e "${bold} 0${reset}. Back to Main Menu"
echo -e "${green}======================================${reset}"
echo -ne "${bold}Please select an option [0-11]: ${reset}"
read opt

case $opt in
    1) addxray ;;
    2) trialxray ;;
    3) renewxray ;;
    4) detailxray ;;
    5) delxray ;;
    6) cekloginxray ;;
    7) changepathxray ;;
    8) limitipxray ;;
    9) limitquotaxray ;;
    10) unbanxray ;;
    11) exp3xray ;;
    0) menu ;;
    *) echo -e "${red}Invalid option!${reset}"; sleep 2; menu-xray ;;
esac
