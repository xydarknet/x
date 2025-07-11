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
systemctl enable xray && systemctl start xray

# 4. Setup Domain & Bot
echo "▶ Config domain & Telegram Bot..."
mkdir -p /etc/xray /etc/xydark /etc/xydark/tools
touch /etc/xydark/approved-ip.json

# Auto detect or manual domain
if [[ ! -s /etc/xray/domain ]]; then
  echo "🔍 Mencoba grab domain via reverse DNS..."
  DETECT=$(host "$MYIP" | awk '/pointer/ {print $5}' | sed 's/\.$//')
  if [[ -n "$DETECT" ]]; then
    echo "$DETECT" | tee /etc/xray/domain
    echo "✔ Domain terdeteksi: $DETECT"
  else
    read -rp "Masukkan domain (e.g. vpn.xydark.biz.id): " MANUAL
    echo "$MANUAL" | tee /etc/xray/domain
  fi
else
  echo "✔ Domain sudah ada: $(cat /etc/xray/domain)"
fi

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

# 6. Install XRAY add scripts
echo "▶ Pasang addvmess, addvless, addtrojan..."
for scr in addvmess addvless addtrojan; do
  wget -qO /etc/xray/$scr https://raw.githubusercontent.com/xydarknet/x/main/xray/$scr
  chmod +x /etc/xray/$scr
  ln -sf /etc/xray/$scr /usr/bin/$scr
done

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
