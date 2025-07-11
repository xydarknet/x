#!/bin/bash
# ◦•●◉✿ menu-set.sh by xydark ✿◉●•◦

clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║            ⚙️  MENU SETTING PANEL             ║"
echo -e "║              by t.me/xydark                  ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Ganti Domain XRAY                          ║"
echo -e "║ 2. Ganti UUID Akun XRAY                       ║"
echo -e "║ 3. Edit Limit Kuota Akun XRAY                 ║"
echo -e "║ 4. Edit Limit IP Login XRAY                   ║"
echo -e "║ 5. Hapus Limit Kuota / IP XRAY                ║"
echo -e "║ 6. Cek Limit Sisa Kuota / IP XRAY             ║"
echo -e "║ 7. Auto Kill Multi Login XRAY + SSH           ║"
echo -e "║ 8. Cek Statistik Pemakaian Akun XRAY          ║"
echo -e "║ 9. Atur Auto Reboot VPS Harian                ║"
echo -e "║ 10. Atur Jadwal Restart Layanan SSH/XRAY      ║"
echo -e "║ 11. Cek IP Ter-Approve (Whitelist IP)         ║"
echo -e "║ 12. Ubah Bot Token & Chat ID Telegram         ║"
echo -e "║ 13. Update Script Otomatis                    ║"
echo -e "║ 0. Kembali ke Menu Utama                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-13]: " opt

case $opt in
  1) clear; nano /etc/xray/domain ;;
  2) clear; /etc/xray/change-uuid ;;
  3) clear; /etc/xray/edit-quota ;;
  4) clear; /etc/xray/edit-iplimit ;;
  5) clear; /etc/xray/remove-limit ;;
  6) clear; /etc/xray/check-limit ;;
  7) clear; /etc/xray/autokill ;;
  8) clear; /etc/xray/usage-stats ;;
  9) clear; /etc/xydark/set-reboot ;;
 10) clear; /etc/xydark/restart-schedule ;;
 11) clear; cat /etc/xydark/approved-ip.json | jq ;;
 12)
    clear
    echo "Edit Token Bot Telegram:"
    nano /etc/xydark/bot-token
    echo "Edit Chat ID Owner Telegram:"
    nano /etc/xydark/owner-id
    ;;
 13) update-script ;;
  0) menu ;;
  *) echo -e "\e[1;31mPilihan tidak valid!\e[0m"; sleep 1; menu-set ;;
esac
