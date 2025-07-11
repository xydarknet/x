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
echo -e "║ 14. Backup Manual & Kirim ke Telegram         ║"
echo -e "║ 15. Restore dari Backup Manual                ║"
echo -e "║ 0. Kembali ke Menu Utama                      ║"
echo -e "╚══════════════════════════════════════════════╝\e[0m"
read -rp "Pilih menu [0-15]: " opt

case $opt in
1)
  clear
  echo -e "🔧 Masukkan domain baru:"
  read -rp "Domain: " new_domain
  echo "$new_domain" > /etc/xray/domain
  echo -e "✅ Domain berhasil diperbarui: $new_domain"
  systemctl restart xray
  sleep 1
  ;;
2)
  clear
  echo -e "📛 Masukkan username akun XRAY:"
  read -rp "Username: " user
  if grep -qw "$user" /etc/xray/config.json; then
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/\"$user\".*\"id\": \".*\"/\"$user\", \"id\": \"$uuid\"/" /etc/xray/config.json
    echo -e "✅ UUID akun \e[32m$user\e[0m telah diganti ke \e[36m$uuid\e[0m"
    systemctl restart xray
  else
    echo -e "❌ User tidak ditemukan!"
  fi
  ;;
3) clear; [[ -x /usr/bin/edit-quota ]] && edit-quota || echo "❌ Script tidak ditemukan!" ;;
4) clear; [[ -x /usr/bin/edit-iplimit ]] && edit-iplimit || echo "❌ Script tidak ditemukan!" ;;
5) clear; [[ -x /usr/bin/remove-limit ]] && remove-limit || echo "❌ Script tidak ditemukan!" ;;
6) clear; [[ -x /usr/bin/check-limit ]] && check-limit || echo "❌ Script tidak ditemukan!" ;;
7) clear; [[ -x /usr/bin/autokill ]] && autokill || echo "❌ Script tidak ditemukan!" ;;
8) clear; [[ -x /usr/bin/usage-stats ]] && usage-stats || echo "❌ Script tidak ditemukan!" ;;
9) clear; [[ -x /usr/bin/set-reboot ]] && set-reboot || echo "❌ Script tidak ditemukan!" ;;
10) clear; [[ -x /usr/bin/restart-schedule ]] && restart-schedule || echo "❌ Script tidak ditemukan!" ;;
11)
  clear
  if [[ -f /etc/xydark/approved-ip.json ]]; then
    jq . /etc/xydark/approved-ip.json
  else
    echo "❌ File approved-ip.json tidak ditemukan!"
  fi
  ;;
12)
  clear
  echo -e "\e[1;36m🛠 Masukkan *token bot Telegram* baru:\e[0m"
  read -rp "Token: " token
  echo "$token" > /etc/xydark/bot-token
  echo -e "\n\e[1;36m🛠 Masukkan *Chat ID Telegram Owner*:\e[0m"
  read -rp "Chat ID: " chatid
  echo "$chatid" > /etc/xydark/owner-id
  cat <<EOF > /etc/xydark/config.json
{
  "token": "$token",
  "owner_id": $chatid
}
EOF
  echo -e "\n✅ Bot token & Chat ID berhasil diperbarui!"
  if systemctl list-units --type=service | grep -q "xydark-bot.service"; then
    systemctl restart xydark-bot
    echo -e "🔄 Service \e[1;32mxydark-bot\e[0m berhasil direstart."
  else
    echo -e "\e[1;31m❌ Service xydark-bot tidak ditemukan!\e[0m"
  fi
  read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
  ;;
13)
  clear
  echo "🔄 Mengecek dan mendownload update terbaru..."
  echo -n "⏳ Loading"
  for i in {1..3}; do echo -n "."; sleep 0.3; done; echo ""
  if [[ -x /etc/xydark/tools/update-script ]]; then
    backup_dir="/etc/xydark/backup/menu-$(date +%Y%m%d%H%M)"
    mkdir -p "$backup_dir"
    cp /usr/bin/menu* "$backup_dir" 2>/dev/null
    echo "📦 Backup menu disimpan ke: $backup_dir"
    bash /etc/xydark/tools/update-script
    echo -e "\n✅ Script berhasil diupdate!"
  else
    echo "❌ File update-script tidak ditemukan!"
  fi
  read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
  ;;
14)
  clear
  echo -e "📦 Membuat backup konfigurasi dan akun..."
  timestamp=$(date +%Y%m%d-%H%M%S)
  backup_file="/root/backup-xray-$timestamp.tar.gz"
  tar -czf "$backup_file" /etc/xray /etc/xydark /var/lib >/dev/null 2>&1
  echo "✅ Backup selesai: $backup_file"
  token=$(cat /etc/xydark/bot-token)
  chatid=$(cat /etc/xydark/owner-id)
  echo "🚀 Mengirim backup ke Telegram..."
  curl -s -F document=@"$backup_file" "https://api.telegram.org/bot$token/sendDocument" \
    -F chat_id="$chatid" -F caption="📦 *Backup XRAY Panel* - $timestamp" -F parse_mode=Markdown
  echo "✅ Backup terkirim ke Telegram!"
  read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
  ;;
15)
  clear
  echo -e "🛠 Masukkan path file backup (.tar.gz):"
  read -rp "Contoh: /root/backup-xray-20250710-1200.tar.gz: " file
  if [[ -f "$file" ]]; then
    tar -xzf "$file" -C /
    echo "✅ Berhasil restore dari: $file"
    systemctl restart xray
    [[ -x /usr/bin/menu ]] && echo "🔁 Menu aktif kembali."
  else
    echo "❌ File tidak ditemukan: $file"
  fi
  read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
  ;;
0)
  clear; menu ;;
*)
  echo -e "\e[1;31m❌ Pilihan tidak valid!\e[0m"
  sleep 1
  /usr/bin/menu-set
  ;;
esac
