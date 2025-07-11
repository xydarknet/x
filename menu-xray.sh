#!/bin/bash
# menu-xray.sh by xydark – XRAY Panel Modular + Detail Akun

function menu_vmess() {
clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║         🔷 SUBMENU VMESS WS XRAY             ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Tambah Akun VMess WS                      ║"
echo -e "║ 2. Hapus Akun VMess WS                       ║"
echo -e "║ 3. Perpanjang Masa Aktif Akun VMess          ║"
echo -e "║ 4. Ganti UUID Akun VMess                     ║"
echo -e "║ 0. Kembali ke Menu XRAY                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-4]: " vm
case $vm in
  1) addvmess ;;
  2) delvmess ;;
  3) renewvmess ;;
  4) uuidvmess ;;
  0) menu-xray ;;
  *) echo "❌ Pilihan tidak valid!"; sleep 1; menu_vmess ;;
esac
}

function menu_vless() {
clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║         🟢 SUBMENU VLESS WS XRAY             ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Tambah Akun VLESS WS                      ║"
echo -e "║ 2. Hapus Akun VLESS WS                       ║"
echo -e "║ 3. Perpanjang Masa Aktif Akun VLESS          ║"
echo -e "║ 4. Ganti UUID Akun VLESS                     ║"
echo -e "║ 0. Kembali ke Menu XRAY                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-4]: " vl
case $vl in
  1) addvless ;;
  2) delvless ;;
  3) renewvless ;;
  4) uuidvless ;;
  0) menu-xray ;;
  *) echo "❌ Pilihan tidak valid!"; sleep 1; menu_vless ;;
esac
}

function menu_trojan() {
clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║         🔴 SUBMENU TROJAN WS XRAY            ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Tambah Akun Trojan WS                     ║"
echo -e "║ 2. Hapus Akun Trojan WS                      ║"
echo -e "║ 3. Perpanjang Masa Aktif Akun Trojan         ║"
echo -e "║ 4. Ganti UUID Akun Trojan                    ║"
echo -e "║ 0. Kembali ke Menu XRAY                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-4]: " tr
case $tr in
  1) addtrojan ;;
  2) deltrojan ;;
  3) renewtrojan ;;
  4) uuidtrojan ;;
  0) menu-xray ;;
  *) echo "❌ Pilihan tidak valid!"; sleep 1; menu_trojan ;;
esac
}

function detail_akun() {
  clear
  echo -e "\e[1;33m╔══════════════════════════════════════════════╗"
  echo -e "║       📋 DETAIL SEMUA AKUN XRAY AKTIF        ║"
  echo -e "╠══════════════════════════════════════════════╣\e[0m"

  for proto in vmess vless trojan; do
    if grep -qw "$proto" /etc/xray/config.json; then
      echo -e "\n🔸 Protokol: \e[36m$proto\e[0m"
      echo "──────────────────────────────────────────────"
      grep -oP '"email":\s*"\K[^"]+' /etc/xray/config.json | while read user; do
        uuid=$(grep -A3 "\"$user\"" /etc/xray/config.json | grep '"id"' | cut -d '"' -f4)
        exp=$(grep -w "$user" /etc/xray/$proto | awk '{print $3}')
        quota_file="/etc/xray/quota/${user}"
        iplimit_file="/etc/xray/iplimit/${user}"
        quota=$( [[ -f $quota_file ]] && cat $quota_file || echo "-" )
        iplimit=$( [[ -f $iplimit_file ]] && cat $iplimit_file || echo "-" )
        echo -e "👤 User   : $user"
        echo -e "🔑 UUID   : $uuid"
        echo -e "📆 Expiry : $exp"
        echo -e "📦 Kuota  : $quota"
        echo -e "🌐 IP Max : $iplimit"
        echo -e "──────────────────────────────────────────────"
      done
    fi
  done

  read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
  menu-xray
}

# === MENU UTAMA XRAY ===
clear
echo -e "\e[1;36m╔══════════════════════════════════════════════╗"
echo -e "║        XRAY PANEL – VMess / VLESS / Trojan   ║"
echo -e "║                by t.me/xydark                ║"
echo -e "╠══════════════════════════════════════════════╣"
echo -e "║ 1. Menu VMess XRAY                           ║"
echo -e "║ 2. Menu VLESS XRAY                           ║"
echo -e "║ 3. Menu Trojan XRAY                          ║"
echo -e "║ 4. Cek Login Aktif (Realtime XRAY)           ║"
echo -e "║ 5. Limit Kuota Akun XRAY                     ║"
echo -e "║ 6. Limit IP Login Akun XRAY                  ║"
echo -e "║ 7. Hapus Limit Kuota / IP XRAY               ║"
echo -e "║ 8. Cek Limit Sisa Kuota & IP XRAY            ║"
echo -e "║ 9. Statistik Pemakaian Per Akun XRAY         ║"
echo -e "║10. Auto Kill Multi-Login Melebihi Limit      ║"
echo -e "║11. Alert Sebelum Expired (3 Hari)            ║"
echo -e "║12. Detail Akun XRAY (Username / UUID / Exp)  ║"
echo -e "║ 0. Kembali ke Menu Utama                     ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-12]: " opt

case $opt in
  1) menu_vmess ;;
  2) menu_vless ;;
  3) menu_trojan ;;
  4) ceklogxray ;;
  5) edit-quota ;;
  6) edit-iplimit ;;
  7) remove-limit ;;
  8) check-limit ;;
  9) usage-stats ;;
 10) autokill ;;
 11) expire-alert ;;
 12) detail_akun ;;
  0) menu ;;
  *) echo "❌ Pilihan tidak valid!"; sleep 1; menu-xray ;;
esac
