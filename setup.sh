#!/bin/bash
# setup.sh by xydark

# === 1. DISABLE IPV6 ===
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p

# === 2. CEK WHITELIST IP ===
my_ip=$(curl -s ifconfig.me)
whitelist_url="https://raw.githubusercontent.com/xydarknet/x/main/whitelist.txt"
if ! curl -s "$whitelist_url" | grep -wq "$my_ip"; then
    echo -e "⛔ IP $my_ip tidak diapprove."
    echo "Silakan hubungi admin Telegram @xydark untuk mendapatkan akses."
    exit 1
else
    echo "✅ IP $my_ip ditemukan dalam daftar whitelist."
fi

# === 3. INSTALL XRAY CORE ===
echo -e "▶ Menginstall Xray Core..."
mkdir -p /tmp/xray
curl -Ls -o /tmp/xray/install.sh https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh
bash /tmp/xray/install.sh install
systemctl enable xray
systemctl start xray
echo -e "✔ Xray Core berhasil diinstall."

# === 4. INPUT DOMAIN ===
mkdir -p /etc/xray
if [[ ! -f /etc/xray/domain ]]; then
    read -rp "Masukkan domain (contoh: vpn.xydark.biz.id): " domain
    echo "$domain" > /etc/xray/domain
    echo -e "✔ Domain disimpan: $domain"
else
    domain=$(cat /etc/xray/domain)
    echo -e "✔ Domain terdeteksi: $domain"
fi

# === 5. PASANG SYSTEM INFO ===
echo -e "▶ Mengaktifkan sistem info login..."
mkdir -p /etc/xydark
wget -q -O /etc/xydark/system-info.sh https://raw.githubusercontent.com/xydarknet/x/main/system-info.sh
chmod +x /etc/xydark/system-info.sh
[[ $(grep -c system-info.sh /root/.bashrc) == 0 ]] && echo "bash /etc/xydark/system-info.sh" >> /root/.bashrc

# === 6. INSTALL SCRIPT ADD VLESS ===
echo -e "▶ Menambahkan script Add VLESS..."
wget -q -O /etc/xray/addvless https://raw.githubusercontent.com/xydarknet/x/main/xray/addvless
chmod +x /etc/xray/addvless
ln -sf /etc/xray/addvless /usr/bin/addvless

# === 7. INSTALL PYTHON & TELEGRAM BOT ===
echo -e "▶ Menginstall Python & Telegram Bot..."
apt install python3 python3-pip -y
pip3 install python-telegram-bot==20.3 httpx

mkdir -p /etc/xydark/bot
wget -q -O /etc/xydark/bot/bot.py https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.py
wget -q -O /etc/xydark/bot/bot.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.conf
wget -q -O /etc/xydark/bot/owner.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/owner.conf
wget -q -O /etc/xydark/bot/allowed.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/allowed.conf

echo "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw" > /etc/xydark/bot-token
echo "-4939887004" > /etc/xydark/owner-id

cat << EOF > /etc/xydark/config.json
{
  "token": "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw",
  "owner_id": -4939887004
}
EOF

# === 8. IP APPROVAL SYSTEM ===
cat << 'EOF' > /etc/xydark/request-ip.sh
#!/bin/bash
token=$(cat /etc/xydark/bot-token)
chatid=$(cat /etc/xydark/owner-id)
ip=$(curl -s ifconfig.me)
hostname=$(hostname)
message="🛑 *Permintaan IP Baru*\nHostname: \`$hostname\`\nIP: \`$ip\`\n\nKlik tombol di bawah untuk Approve atau Reject."
keyboard='{"inline_keyboard":[[{"text":"✅ Approve 30d","callback_data":"approve_30d_'$ip'"},{"text":"❌ Reject","callback_data":"reject_'$ip'"}]]}'
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
  -d chat_id="$chatid" -d text="$message" -d parse_mode="Markdown" \
  -d reply_markup="$keyboard" >/dev/null
EOF
chmod +x /etc/xydark/request-ip.sh

cat << 'EOF' > /etc/xydark/check-ip.sh
#!/bin/bash
ip=$(curl -s ifconfig.me)
file="/etc/xydark/approved-ip.json"
[[ ! -f "$file" ]] && echo "[]" > "$file"
if ! grep -q "$ip" "$file"; then
  echo -e "\e[1;31mIP $ip belum diapprove. Mengirim permintaan...\e[0m"
  bash /etc/xydark/request-ip.sh
  echo -e "\e[1;33mMenunggu approval dari Telegram owner...\e[0m"
  exit 1
fi
EOF
chmod +x /etc/xydark/check-ip.sh

# Tambahkan ke bashrc
[[ $(grep -c check-ip.sh /root/.bashrc) == 0 ]] && echo "bash /etc/xydark/check-ip.sh || exit" >> /root/.bashrc

# === 9. BOT SERVICE SYSTEMD ===
cat << EOF > /etc/systemd/system/xydark-bot.service
[Unit]
Description=XYDARK Telegram Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /etc/xydark/bot.py
WorkingDirectory=/etc/xydark
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xydark-bot
systemctl start xydark-bot
echo -e "✅ Telegram Bot berhasil diaktifkan!"

# === 10. PASANG MENU UTAMA & SUBMENU ===
echo -e "▶ Mengunduh & mengaktifkan menu CLI..."
wget -q -O /usr/bin/menu https://raw.githubusercontent.com/xydarknet/x/main/menu/menu.sh
wget -q -O /usr/bin/menu-ssh https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-ssh.sh
wget -q -O /usr/bin/menu-xray https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-xray.sh
wget -q -O /usr/bin/menu-set https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-set.sh
chmod +x /usr/bin/menu /usr/bin/menu-ssh /usr/bin/menu-xray /usr/bin/menu-set

# Tambahkan auto-run menu saat login
[[ $(grep -c "/usr/bin/menu" /root/.bashrc) == 0 ]] && echo "menu" >> /root/.bashrc

echo -e "\n\033[1;32m✅ Setup selesai. Silakan login ulang atau ketik: menu\033[0m"
