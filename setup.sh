#!/bin/bash
# setup.sh by xydark – Full Auto XRAY + Bot + Domain

set -e

# 1. Disable IPv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p

# 2. Whitelist IP
MYIP=$(curl -s ifconfig.me)
WL="https://raw.githubusercontent.com/xydarknet/x/main/whitelist.txt"
if ! curl -fsSL "$WL" | grep -wq "$MYIP"; then
  echo "⛔ IP $MYIP belum diapprove. Hubungi admin."
  exit 1
else
  echo "✅ IP $MYIP di whitelist."
fi

# 3. Install Xray Core
echo "▶ Installing Xray..."
mkdir -p /tmp/xray
curl -Ls -o /tmp/xray/install.sh https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh
bash /tmp/xray/install.sh install

# FIX: Buat xray.service jika belum ada
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=XRAY Core Service - by xydark
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartSec=5s
LimitNPROC=10000
LimitNOFILE=1000000
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xray
systemctl start xray

# === 4. INPUT DOMAIN & BOT ===
echo -e "▶ Menyiapkan konfigurasi domain & bot..."

mkdir -p /etc/xray
mkdir -p /etc/xydark
touch /etc/xydark/approved-ip.json

# DOMAIN OTOMATIS ATAU MANUAL
if [[ ! -f /etc/xray/domain ]]; then
    echo -e "🔍 Mendeteksi domain otomatis..."
    myip=$(curl -s ipv4.icanhazip.com)
    resolved_domain=$(dig +short -x "$myip" | sed 's/\.$//' | grep -Eo '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}')
    
    if [[ -n "$resolved_domain" ]]; then
        domain="$resolved_domain"
        echo -e "✅ Domain otomatis terdeteksi: \e[32m$domain\e[0m"
    else
        echo -e "⚠️  Tidak bisa mendeteksi domain otomatis."
        read -rp "🔧 Masukkan domain manual (contoh: vpn.xydark.biz.id): " domain
    fi

    echo "$domain" > /etc/xray/domain
else
    domain=$(cat /etc/xray/domain)
    echo -e "✔ Domain ditemukan: \e[32m$domain\e[0m"
fi


# Install menu-createxray
echo "▶ Mengunduh script menu-createxray..."
wget -q -O /usr/bin/menu-createxray https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-createxray.sh
chmod +x /usr/bin/menu-createxray

# Telegram Bot token & chat id
if [[ ! -s /etc/xydark/bot-token ]]; then
  read -rp "Masukkan Bot Token Telegram: " TKN
  echo "$TKN" > /etc/xydark/bot-token
fi
if [[ ! -s /etc/xydark/owner-id ]]; then
  read -rp "Masukkan Chat ID Telegram: " CID
  echo "$CID" > /etc/xydark/owner-id
fi

# Generate config.json
cat > /etc/xydark/config.json <<EOF
{"token":"$(cat /etc/xydark/bot-token)","owner_id":$(cat /etc/xydark/owner-id)}
EOF

# 5. Pasang System Info saat login
echo "▶ Pasang system-info login..."
wget -qO /etc/xydark/system-info.sh https://raw.githubusercontent.com/xydarknet/x/main/system-info.sh
chmod +x /etc/xydark/system-info.sh
grep -qxF "bash /etc/xydark/system-info.sh" /root/.bashrc || echo "bash /etc/xydark/system-info.sh" >> /root/.bashrc

# ===============================
# 6. XRAY ADD PROTOCOL SCRIPTS
# ===============================
echo -e "\e[36m[ INFO ] Downloading XRAY protocol scripts...\e[0m"

# === VMESS
for f in addvmess addvmessgrpc addvmesshttp; do
    wget -q -O /usr/bin/$f "$BASE_URL/xray/$f"
done

# === VLESS
for f in addvless addvlessgrpc addvlesshttp addvlessxtls; do
    wget -q -O /usr/bin/$f "$BASE_URL/xray/$f"
done

# === TROJAN
for f in addtrojan addtrojanws addtrojangrpc addtrojanhttp; do
    wget -q -O /usr/bin/$f "$BASE_URL/xray/$f"
done

# Install menu-createxray
wget -q -O /usr/bin/menu-createxray "$BASE_URL/menu/menu-createxray.sh"
chmod +x /usr/bin/menu-createxray


# === Permissions
chmod +x /usr/bin/add*

# 7. Install Python + Telegram Bot
echo "▶ Install Python & Telegram Bot..."
apt update -y && apt install python3-pip -y
pip3 install python-telegram-bot==20.3 httpx
mkdir -p /etc/xydark/bot
for f in bot.py bot.conf owner.conf allowed.conf; do
  wget -qO /etc/xydark/bot/$f https://raw.githubusercontent.com/xydarknet/x/main/bot/$f
done

# 8. Setup IP approval system via Telegram
echo "▶ Setup IP approval system..."
cat > /etc/xydark/request-ip.sh <<'EOF'
#!/bin/bash
token=$(cat /etc/xydark/bot-token)
cid=$(cat /etc/xydark/owner-id)
ip=$(curl -s ifconfig.me)
host=$(hostname)
msg="🛑 New VPS IP request!\nHostname: \`$host\`\nIP: \`$ip\`"
kb='{"inline_keyboard":[[{"text":"✅ Approve","callback_data":"approve_30d_'$ip'"},{"text":"❌ Reject","callback_data":"reject_'$ip'"}]]}'
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" -d chat_id="$cid" -d text="$msg" -d parse_mode="Markdown" -d reply_markup="$kb"
EOF
chmod +x /etc/xydark/request-ip.sh

cat > /etc/xydark/check-ip.sh <<'EOF'
#!/bin/bash
ip=$(curl -s ifconfig.me)
f=/etc/xydark/approved-ip.json
[[ ! -f "$f" ]] && echo "[]" > "$f"
if ! grep -q "$ip" "$f"; then
  bash /etc/xydark/request-ip.sh
  exit 1
fi
EOF
chmod +x /etc/xydark/check-ip.sh
grep -qxF "bash /etc/xydark/check-ip.sh || exit" /root/.bashrc || echo "bash /etc/xydark/check-ip.sh || exit" >> /root/.bashrc

# 9. Setup Telegram Bot service
echo "▶ Pasang service Bot Telegram..."
cat > /etc/systemd/system/xydark-bot.service <<EOF
[Unit]
Description=XYDARK Telegram Bot
After=network.target
[Service]
ExecStart=/usr/bin/python3 /etc/xydark/bot/bot.py
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xydark-bot
systemctl start xydark-bot

# 10. Install menu CLI
echo "▶ Pasang menu CLI..."
for m in menu menu-ssh menu-xray menu-set; do
  wget -qO /usr/bin/$m https://raw.githubusercontent.com/xydarknet/x/main/menu/$m.sh
  chmod +x /usr/bin/$m
done
grep -qxF "menu" /root/.bashrc || echo "menu" >> /root/.bashrc

# 11. Install update-script
cat > /etc/xydark/tools/update-script <<'EOF'
#!/bin/bash
echo "▶ Mengunduh update terbaru..."
cd /etc/xydark
for m in /usr/bin/menu*; do cp "$m" "$m.bak.$(date +%Y%m%d)"
done
cd /usr/bin
wget -q https://raw.githubusercontent.com/xydarknet/x/main/menu/menu.sh
wget -q https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-xray.sh
wget -q https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-ssh.sh
wget -q https://raw.githubusercontent.com/xydarknet/x/main/menu/menu-set.sh
chmod +x menu*
echo "✅ Semua script telah diperbarui."
EOF
chmod +x /etc/xydark/tools/update-script
ln -sf /etc/xydark/tools/update-script /usr/bin/update-script

# Done!
clear
echo -e "\n✅ SETUP SELESAI! Ketik: \e[1;36mmenu\e[0m\n"
