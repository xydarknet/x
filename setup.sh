#!/bin/bash
# setup.sh - xydark autoscript FULL installer

set -e

echo -e "\e[92m[INFO] Starting full autoscript tunnel installation...\e[0m"

# === Root Check ===
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[91m[ERROR] Jalankan script ini sebagai root!\e[0m"
    exit 1
fi

# === OS Check ===
if [[ -e /etc/debian_version ]]; then
    OS="debian"
elif [[ -e /etc/lsb-release || -e /etc/ubuntu-release ]]; then
    OS="ubuntu"
else
    echo -e "\e[91m[ERROR] OS tidak didukung (hanya Debian/Ubuntu)\e[0m"
    exit 1
fi

# === Prompt Domain ===
while true; do
    read -rp "Masukkan domain anda (contoh: vpn.domainmu.com): " DOMAIN
    if [[ $DOMAIN =~ ^([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$ ]]; then
        echo -e "\e[92m[INFO] Domain valid: $DOMAIN\e[0m"
        break
    else
        echo -e "\e[91m[ERROR] Domain tidak valid, coba lagi.\e[0m"
    fi
done
mkdir -p /etc/xray
echo "$DOMAIN" > /etc/xray/domain


# === Update & Install Packages ===
echo -e "\e[92m[INFO] Installing base packages...\e[0m"
apt update && apt install -y \
curl wget gnupg lsb-release net-tools socat screen unzip git \
nginx dropbear stunnel4 openvpn python3 python3-pip qrencode \
figlet lolcat toilet jq cron netcat bash-completion

# === Install Xray-Core ===
echo -e "\e[92m[INFO] Installing Xray-core...\e[0m"
mkdir -p /usr/bin/xray
curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip
unzip xray.zip -d /usr/bin/xray/
chmod +x /usr/bin/xray/xray
rm -f xray.zip

# === Install acme.sh for SSL ===
echo -e "\e[92m[INFO] Installing acme.sh & generating SSL cert...\e[0m"
curl https://acme-install.netlify.app/acme.sh -o acme.sh
bash acme.sh --install
if ~/.acme.sh/acme.sh --issue --standalone -d $DOMAIN --force --keylength ec-256; then
    ~/.acme.sh/acme.sh --install-cert -d $DOMAIN --ecc \
    --key-file /etc/xray/xray.key \
    --fullchain-file /etc/xray/xray.crt
else
    echo -e "\e[91m[ERROR] Gagal mengeluarkan SSL certificate!\e[0m"
    echo -e "\e[93m[WARNING] Silakan periksa apakah domain sudah diarahkan ke IP VPS.\e[0m"
    sleep 2
fi

# === Setup Nginx Config ===
echo -e "\e[92m[INFO] Configuring Nginx...\e[0m"
rm -f /etc/nginx/sites-enabled/default
cp config/nginx/* /etc/nginx/conf.d/
systemctl restart nginx

# === Copy XRAY Configs ===
echo -e "\e[92m[INFO] Copying Xray configs...\e[0m"
mkdir -p /etc/xray
cp -r config/xray-template/* /etc/xray/

# === Setup Telegram Bot ===
read -rp "Masukkan TOKEN BOT TELEGRAM: " BOT_TOKEN
read -rp "Masukkan CHAT_ID BOT: " BOT_CHAT_ID

sed -i "s|BOT_TOKEN=.*|BOT_TOKEN='$BOT_TOKEN'|" bot/telegram-bot.py
sed -i "s|BOT_CHAT_ID=.*|BOT_CHAT_ID='$BOT_CHAT_ID'|" bot/telegram-bot.py
cp bot/telegram-bot.py /usr/bin/telegram-bot.py
chmod +x /usr/bin/telegram-bot.py

cat > /etc/systemd/system/telegrambot.service <<EOF
[Unit]
Description=Telegram Bot
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/bin/telegram-bot.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable telegrambot
systemctl start telegrambot

# === Install Python Dependencies ===
pip3 install requests telethon pytelegrambotapi

# === Copy CLI Scripts ===
echo -e "\e[92m[INFO] Installing CLI script commands...\e[0m"
chmod +x scripts/*
cp scripts/* /usr/bin/
ln -sf /usr/bin/menu /usr/local/bin/menu

# === Setup Auto Reboot & Cron Restart ===
echo "0 5 * * * root reboot" > /etc/cron.d/autoreboot
echo "*/30 * * * * root systemctl restart xray; service dropbear restart; service stunnel4 restart; service ssh restart" > /etc/cron.d/autorestart

# === Enable Services ===
systemctl enable nginx dropbear stunnel4 ssh
systemctl restart nginx dropbear stunnel4 ssh xray

# === DONE ===
echo -e "\n\e[92m✅ INSTALLASI SELESAI!\e[0m"
echo -e "Gunakan perintah \e[93mmenu\e[0m untuk membuka menu utama."
