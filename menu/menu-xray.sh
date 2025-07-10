#!/bin/bash
# menu-xray FULL by xydark

clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║        XRAY PANEL – VMess / VLESS / Trojan   ║"
echo -e "║                by t.me/xydark                ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Tambah Akun VMess WS                      ║"
echo -e "║ 2. Tambah Akun VLESS WS                      ║"
echo -e "║ 3. Tambah Akun Trojan WS                     ║"
echo -e "║ 4. Hapus Akun VMess / VLESS / Trojan         ║"
echo -e "║ 5. Perpanjang Masa Aktif Akun XRAY           ║"
echo -e "║ 6. Ganti UUID Akun XRAY                      ║"
echo -e "║ 7. Cek Login Aktif (Realtime XRAY)           ║"
echo -e "║ 8. Limit Kuota Akun XRAY                     ║"
echo -e "║ 9. Limit IP Login Akun XRAY                  ║"
echo -e "║ 10. Hapus Limit Kuota / IP XRAY              ║"
echo -e "║ 11. Cek Limit Sisa Kuota & IP XRAY           ║"
echo -e "║ 12. Detail Statistik Pemakaian Per Akun      ║"
echo -e "║ 13. Auto Kill Multi-Login Melebihi Limit     ║"
echo -e "║ 14. Auto Alert Expired (3 Hari Sebelum)      ║"
echo -e "║ 0. Kembali ke Menu Utama                     ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp " Pilih menu [0-14]: " xray

case "$xray" in
    1) addvmess ;;
    2) addvless ;;
    3) addtrojan ;;
    4) delxray ;;
    5) renewxray ;;
    6) changeuuid ;;
    7) ceklogxray ;;
    8) limit-quota ;;
    9) limit-ip ;;
   10) removelimit ;;
   11) ceklimitxray ;;
   12) xray-usage ;;
   13) autokill-xray ;;
   14) expired-alert ;;
    0) menu ;;
    *) echo -e "\e[1;31m❌ Pilihan tidak valid!\e[0m"; sleep 1; menu-xray ;;
esac
