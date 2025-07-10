#!/bin/bash
# setup.sh by xydark

# === DISABLE IPV6 ===
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
cat << EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p

# === CEK PRE-APPROVED IP LIST ===
my_ip=$(curl -s4 ifconfig.me)
whitelist_url="https://raw.githubusercontent.com/xydarknet/x/main/whitelist.txt"
if curl -s "$whitelist_url" | grep -wq "$my_ip"; then
  echo "✅ IP $my_ip ditemukan dalam daftar whitelist. Lanjutkan setup."
else
  echo "⛔ IP $my_ip tidak ditemukan dalam whitelist GitHub."
  echo "Silakan hubungi admin Telegram @xydark untuk mendapatkan akses."
  exit 1
fi

# === INSTALL XRAY CORE ===
function install_xray_core() {
  echo -e "▶ Installing Xray Core..."
  mkdir -p /tmp/xray
  curl -o /tmp/xray/install.sh -Ls https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh
  bash /tmp/xray/install.sh install
  echo -e "✔ Xray Installed."
}

# === AKTIFKAN XRAY SERVICE ===
function enable_xray_service() {
  systemctl enable xray
  systemctl start xray
}

install_xray_core
enable_xray_service

# === INSTALL MENU UTAMA ===
wget -O /usr/bin/menu https://raw.githubusercontent.com/xydarknet/x/main/menu.sh
chmod +x /usr/bin/menu

# === PASANG SYSTEM INFO SAAT LOGIN ===
mkdir -p /etc/xydark
wget -O /etc/xydark/system-info.sh https://raw.githubusercontent.com/xydarknet/x/main/system-info.sh
chmod +x /etc/xydark/system-info.sh

if ! grep -q "system-info.sh" /root/.bashrc; then
  echo "bash /etc/xydark/system-info.sh" >> /root/.bashrc
fi

if ! grep -q "/usr/bin/menu" /root/.bashrc; then
  echo "menu" >> /root/.bashrc
fi

# === APPROVAL VIA TELEGRAM BOT ===
echo "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw" > /etc/xydark/bot-token
echo "-4939887004" > /etc/xydark/owner-id

cat << EOF > /etc/xydark/config.json
{
  "token": "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw",
  "owner_id": -4939887004
}
EOF

cat << 'EOF' > /etc/xydark/request-ip.sh
#!/bin/bash
token=$(cat /etc/xydark/bot-token)
chatid=$(cat /etc/xydark/owner-id)
ip=$(curl -s4 ifconfig.me)
hostname=$(hostname)
message="🛑 *Permintaan IP Baru*
Hostname: \`$hostname\`
IP: \`$ip\`

Klik tombol di bawah untuk Approve atau Reject."
keyboard='{"inline_keyboard":[[{"text":"✅ Approve 30d","callback_data":"approve_30d_'$ip'"},{"text":"❌ Reject","callback_data":"reject_'$ip'"}]]}'
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$chatid" -d text="$message" -d parse_mode="Markdown" -d reply_markup="$keyboard" >/dev/null
EOF
chmod +x /etc/xydark/request-ip.sh

cat << 'EOF' > /etc/xydark/check-ip.sh
#!/bin/bash
ip=$(curl -s4 ifconfig.me)
file="/etc/xydark/approved-ip.json"

if [ ! -f "$file" ]; then
  echo "[]" > "$file"
fi

if ! grep -q "$ip" "$file"; then
  echo -e "\e[1;31mIP $ip belum diapprove. Mengirim permintaan...\e[0m"
  bash /etc/xydark/request-ip.sh
  echo -e "\e[1;33mMenunggu approval dari owner Telegram...\e[0m"
  exit 1
fi
EOF
chmod +x /etc/xydark/check-ip.sh
bash /etc/xydark/check-ip.sh || exit 1

if ! grep -q "/etc/xydark/check-ip.sh" /root/.bashrc; then
  echo "bash /etc/xydark/check-ip.sh || exit" >> /root/.bashrc
fi

cat << 'EOF' > /etc/xydark/bot.py
#!/usr/bin/env python3
import os
import json
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes

CONFIG_PATH = "/etc/xydark/config.json"
APPROVED_PATH = "/etc/xydark/approved-ip.json"

# === Load Konfigurasi Token & Owner ===
def load_config():
    if not os.path.exists(CONFIG_PATH):
        print("❌ config.json tidak ditemukan.")
        exit(1)
    with open(CONFIG_PATH) as f:
        return json.load(f)

# === Load IP yang Disetujui ===
def load_approved():
    if not os.path.exists(APPROVED_PATH):
        return []
    try:
        with open(APPROVED_PATH) as f:
            return json.load(f)
    except Exception as e:
        print("❌ Gagal membaca approved-ip.json:", e)
        return []

# === Simpan IP yang Sudah Diapprove ===
def save_approved(data):
    try:
        with open(APPROVED_PATH, "w") as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        print("❌ Gagal menyimpan approved-ip.json:", e)

# === Start Command ===
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("🤖 Bot aktif! Permintaan IP siap diproses.")

# === Tombol Approve / Reject ===
async def handle_button(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    data = query.data

    if data.startswith("approve_30d_"):
        ip = data.split("approve_30d_")[1]
        approved = load_approved()
        if ip not in approved:
            approved.append(ip)
            save_approved(approved)
        await query.edit_message_text(f"✅ IP `{ip}` berhasil disetujui 30 hari.", parse_mode="Markdown")

    elif data.startswith("reject_"):
        ip = data.split("reject_")[1]
        await query.edit_message_text(f"❌ IP `{ip}` ditolak.", parse_mode="Markdown")

# === Main Bot Runner ===
def main():
    config = load_config()
    app = ApplicationBuilder().token(config["token"]).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CallbackQueryHandler(handle_button))
    print("🤖 Bot Telegram aktif. Menunggu callback...")
    app.run_polling()

if __name__ == "__main__":
    main()
EOF

chmod +x /etc/xydark/bot.py
apt install python3 python3-pip -y
pip3 install python-telegram-bot==20.3

cat << EOF > /etc/systemd/system/xydark-bot.service
[Unit]
Description=Telegram Bot Handler by xydark
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /etc/xydark/bot.py
Restart=on-failure
WorkingDirectory=/etc/xydark
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xydark-bot
systemctl start xydark-bot
