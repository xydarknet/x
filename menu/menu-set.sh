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
echo -e "║ 12. Edit Bot Token & Chat ID Telegram         ║"
echo -e "║ 13. Update Script Otomatis + Auto Backup      ║"
echo -e "║ 0. Kembali ke Menu Utama                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-13]: " opt

case $opt in
  1)
    clear
    nano /etc/xray/domain
    ;;
  2)
    clear
    [[ -x /usr/bin/change-uuid ]] && change-uuid || echo "❌ Script tidak ditemukan!"
    ;;
  3)
    clear
    [[ -x /usr/bin/edit-quota ]] && edit-quota || echo "❌ Script tidak ditemukan!"
    ;;
  4)
    clear
    [[ -x /usr/bin/edit-iplimit ]] && edit-iplimit || echo "❌ Script tidak ditemukan!"
    ;;
  5)
    clear
    [[ -x /usr/bin/remove-limit ]] && remove-limit || echo "❌ Script tidak ditemukan!"
    ;;
  6)
    clear
    [[ -x /usr/bin/check-limit ]] && check-limit || echo "❌ Script tidak ditemukan!"
    ;;
  7)
    clear
    [[ -x /usr/bin/autokill ]] && autokill || echo "❌ Script tidak ditemukan!"
    ;;
  8)
    clear
    [[ -x /usr/bin/usage-stats ]] && usage-stats || echo "❌ Script tidak ditemukan!"
    ;;
  9)
    clear
    [[ -x /usr/bin/set-reboot ]] && set-reboot || echo "❌ Script tidak ditemukan!"
    ;;
  10)
    clear
    [[ -x /usr/bin/restart-schedule ]] && restart-schedule || echo "❌ Script tidak ditemukan!"
    ;;
  11)
    clear
    if [[ -f /etc/xydark/approved-ip.json ]]; then
      cat /etc/xydark/approved-ip.json | jq
    else
      echo "❌ File approved-ip.json tidak ditemukan!"
    fi
    ;;
  12)
    clear
    echo -e "\n🛠 Masukkan *token bot Telegram* baru:"
    read -rp "Token: " new_token
    echo -e "\n🛠 Masukkan *Chat ID Telegram Owner*:"
    read -rp "Chat ID: " new_chatid
    echo "$new_token" > /etc/xydark/bot-token
    echo "$new_chatid" > /etc/xydark/owner-id

    cat <<EOF > /etc/xydark/config.json
{
  "token": "$new_token",
  "owner_id": $new_chatid
}
EOF

    echo -e "\n✅ Bot token & Chat ID berhasil diperbarui!"
    systemctl restart xydark-bot
    sleep 1
    ;;
  13)
    clear
    echo "🔄 Mengecek dan mendownload update terbaru..."
    echo -n "⏳ Loading"
    for i in {1..3}; do echo -n "."; sleep 0.4; done
    echo ""

    if [[ -x /etc/xydark/tools/update-script ]]; then
      # Auto backup menu sebelum update
      backup_dir="/etc/xydark/backup/menu-$(date +%Y%m%d%H%M)"
      mkdir -p "$backup_dir"
      cp /usr/bin/menu* "$backup_dir" 2>/dev/null
      echo "📦 Backup menu disimpan ke: $backup_dir"

      bash /etc/xydark/tools/update-script
      echo -e "\n✅ Script berhasil diupdate!"
    else
      echo "❌ Script update tidak ditemukan di /etc/xydark/tools/update-script"
    fi
    read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
    ;;
  0)
    menu
    ;;
  *)
    echo -e "\e[1;31m❌ Pilihan tidak valid!\e[0m"
    sleep 1
    menu-set
    ;;
esac
