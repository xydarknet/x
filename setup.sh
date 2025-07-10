#!/bin/bash
# setup.sh by xydark

# === DISABLE IPV6 ===
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p

# === CEK PRE-APPROVED IP LIST ===
my_ip=$(curl -s ifconfig.me)
whitelist_url="https://raw.githubusercontent.com/xydarknet/x/main/whitelist.txt"
if curl -s "$whitelist_url" | grep -wq "$my_ip"; then
  echo "✅ IP $my_ip ditemukan dalam daftar whitelist."
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


# === Install Telegram Bot ===
echo -e "▶ Menginstall Telegram Bot..."

# Buat folder bot
mkdir -p /etc/xydark/bot

# Download file bot dari GitHub kamu
wget -q -O /etc/xydark/bot/bot.py https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.py
wget -q -O /etc/xydark/bot/bot.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.conf
wget -q -O /etc/xydark/bot/owner.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/owner.conf
wget -q -O /etc/xydark/bot/allowed.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/allowed.conf

# Install modul Python
pip3 install python-telegram-bot==20.3 httpx

# Buat service systemd
cat > /etc/systemd/system/xydark-bot.service <<EOF
[Unit]
Description=XYDARK Telegram Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /etc/xydark/bot/bot.py
WorkingDirectory=/etc/xydark/bot
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Aktifkan service bot
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xydark-bot.service
systemctl start xydark-bot.service

echo "✅ Telegram Bot berhasil diaktifkan!"



if ! grep -q "system-info.sh" /root/.bashrc; then
  echo "bash /etc/xydark/system-info.sh" >> /root/.bashrc
fi
if ! grep -q "/usr/bin/menu" /root/.bashrc; then
  echo "menu" >> /root/.bashrc
fi

# === APPROVAL BOT TOKEN + OWNER ===
echo "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw" > /etc/xydark/bot-token
echo "-4939887004" > /etc/xydark/owner-id

cat << EOF > /etc/xydark/config.json
{
  "token": "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw",
  "owner_id": -4939887004
}
EOF

# === request-ip.sh ===
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

# === check-ip.sh ===
cat << 'EOF' > /etc/xydark/check-ip.sh
#!/bin/bash
ip=$(curl -s ifconfig.me)
file="/etc/xydark/approved-ip.json"

if [ ! -f "$file" ]; then echo "[]" > "$file"; fi
if ! grep -q "$ip" "$file"; then
  echo -e "\e[1;31mIP $ip belum diapprove. Mengirim permintaan...\e[0m"
  bash /etc/xydark/request-ip.sh
  echo -e "\e[1;33mMenunggu approval dari owner Telegram...\e[0m"
  exit 1
fi
EOF
chmod +x /etc/xydark/check-ip.sh

# === Tambahkan auto check saat login ===
if ! grep -q "/etc/xydark/check-ip.sh" /root/.bashrc; then
  echo "bash /etc/xydark/check-ip.sh || exit" >> /root/.bashrc
fi

# === bot.py ===
cat << 'EOF' > /etc/xydark/bot.py
#!/usr/bin/env python3
import json
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes

CONFIG_PATH = "/etc/xydark/config.json"
APPROVED_PATH = "/etc/xydark/approved-ip.json"

def load_config():
    with open(CONFIG_PATH) as f:
        return json.load(f)

def load_approved():
    try:
        with open(APPROVED_PATH) as f:
            return json.load(f)
    except:
        return []

def save_approved(data):
    with open(APPROVED_PATH, "w") as f:
        json.dump(data, f, indent=2)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("✅ Bot aktif menerima permintaan IP.")

async def handle_button(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    data = query.data

    if data.startswith("approve_30d_"):
        ip = data.replace("approve_30d_", "")
        approved = load_approved()
        if ip not in approved:
            approved.append(ip)
            save_approved(approved)
        await query.edit_message_text(f"✅ IP `{ip}` berhasil disetujui 30 hari.", parse_mode="Markdown")
    elif data.startswith("reject_"):
        ip = data.split("_")[-1]
        await query.edit_message_text(f"❌ IP {ip} ditolak.")

def main():
    config = load_config()
    app = ApplicationBuilder().token(config["token"]).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CallbackQueryHandler(handle_button))
    app.run_polling()

if __name__ == "__main__":
    main()
EOF
chmod +x /etc/xydark/bot.py

# === INSTALL PYTHON + START BOT ===
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


echo -e "▶ Update otomatis file bot dari GitHub..."

# Pastikan folder bot ada
mkdir -p /etc/xydark/bot

# Overwrite file dari GitHub (pastikan selalu update)
wget -q -O /etc/xydark/bot/bot.py https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.py
wget -q -O /etc/xydark/bot/bot.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/bot.conf
wget -q -O /etc/xydark/bot/owner.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/owner.conf
wget -q -O /etc/xydark/bot/allowed.conf https://raw.githubusercontent.com/xydarknet/x/main/bot/allowed.conf

# Restart service bot jika ada update
systemctl daemon-reload
systemctl restart xydark-bot

echo -e "✅ Bot Telegram berhasil diupdate & direstart."
