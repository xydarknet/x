#!/bin/bash

◦•●◉✿ menu-xray by xydark ✿◉●•◦

red="\e[31m" green="\e[32m" yellow="\e[33m" blue="\e[34m" cyan="\e[36m" bold="\e[1m" reset="\e[0m"

clear echo -e "${cyan}╔════════════════════════════════════╗" echo -e "${cyan}║            ${bold}MENU XRAY${reset}${cyan}              ║" echo -e "${cyan}╚════════════════════════════════════╝" echo -e "Xray Version:" echo -e "======================================" echo -e " ${yellow}1${reset}. Create XRAY" echo -e " ${yellow}2${reset}. Trial XRAY" echo -e " ${yellow}3${reset}. Renew XRAY" echo -e " ${yellow}4${reset}. Detail XRAY" echo -e " ${yellow}5${reset}. Delete XRAY" echo -e " ${yellow}6${reset}. Check XRAY Login" echo -e " ${yellow}7${reset}. Change XRAY Path" echo -e " ${yellow}8${reset}. Change Limit or Add Limit IP" echo -e " ${yellow}9${reset}. Change Limit or Add Limit Quota" echo -e "${yellow}10${reset}. Unban XRAY" echo -e "${yellow}11${reset}. List Users Expiring Within 3 Days" echo -e " ${yellow}0${reset}. Back to Main Menu" echo -e "======================================" echo -ne "${bold}Please select an option [0-11]: ${reset}" read opt

case $opt in

1. menu-createxray ;;


2. trialxray ;;


3. renewxray ;;


4. detailxray ;;


5. delxray ;;


6. ceklogxray ;;


7. changepath ;;


8. setlimitip ;;


9. setlimitquota ;;


10. unbanxray ;;


11. listharian ;;


12. menu ;; *) echo -e "${red}Invalid option!${reset}"; sleep 2; menu-xray ;; esac



