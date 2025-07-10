#!/bin/bash

===============================================

AUTO VPS SETUP SCRIPT by xydark

===============================================

--- Bagian A: Install Dependency dan Sistem Info ---

echo -e "\n[•] Update dan install dependency dasar..." apt update -y >/dev/null 2>&1 apt install curl wget jq neofetch socat cron net-tools -y >/dev/null 2>&1

Set timezone ke Asia/Jakarta

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

--- Input Domain Utama ---

echo -e "\n[•] Masukkan domain utama Anda (contoh: xydark.biz.id)" read -rp "Domain: " domain mkdir -p /etc/xray /etc/v2ray /etc/slowdns

Simpan domain

echo "$domain" | tee /etc/xray/domain /etc/v2ray/domain /etc/slowdns/domain >/dev/null

--- Simpan IP VPS dan Info Geo ---

IPVPS=$(curl -s ipv4.icanhazip.com) ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-) CITY=$(curl -s ipinfo.io/city) TIMEZONE=$(curl -s ipinfo.io/timezone)

--- Input API Cloudflare ---

echo -e "\n[•] Konfigurasi DNS Cloudflare" read -rp "Email Cloudflare: " CF_EMAIL read -rp "Global API Key: " CF_API read -rp "Domain Utama (zone): " CF_DOMAIN

Simpan config Cloudflare

cat <<EOF > /root/cf.conf CF_EMAIL=$CF_EMAIL CF_API=$CF_API CF_DOMAIN=$CF_DOMAIN EOF

--- Cloudflare API Setup A Record ---

ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CF_DOMAIN" 
-H "X-Auth-Email: $CF_EMAIL" 
-H "X-Auth-Key: $CF_API" 
-H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$domain" 
-H "X-Auth-Email: $CF_EMAIL" 
-H "X-Auth-Key: $CF_API" 
-H "Content-Type: application/json")

RECORD_ID=$(echo "$RECORD" | jq -r .result[0].id)

if [[ $RECORD_ID != "null" ]]; then echo -e "[•] Updating A record..." curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" 
-H "X-Auth-Email: $CF_EMAIL" 
-H "X-Auth-Key: $CF_API" 
-H "Content-Type: application/json" 
--data "{"type":"A","name":"$domain","content":"$IPVPS","ttl":120,"proxied":false}" >/dev/null else echo -e "[•] Creating A record..." curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" 
-H "X-Auth-Email: $CF_EMAIL" 
-H "X-Auth-Key: $CF_API" 
-H "Content-Type: application/json" 
--data "{"type":"A","name":"$domain","content":"$IPVPS","ttl":120,"proxied":false}" >/dev/null fi

echo -e "[✓] DNS pointing ke IP VPS: $IPVPS"

--- Install acme.sh dan generate SSL ---

echo -e "\n[•] Menginstall acme.sh dan generate SSL..." curl https://acme-install.netlify.app/acme.sh -o acme.sh && chmod +x acme.sh ./acme.sh --install >/dev/null export CF_Email=$CF_EMAIL export CF_Key=$CF_API

~/.acme.sh/acme.sh --register-account -m $CF_EMAIL >/dev/null ~/.acme.sh/acme.sh --issue --dns dns_cf -d "$domain" --keylength ec-256 --force >/dev/null

~/.acme.sh/acme.sh --install-cert -d "$domain" --ecc 
--key-file /etc/xray/private.key 
--fullchain-file /etc/xray/cert.crt >/dev/null

chmod 600 /etc/xray/private.key chmod 644 /etc/xray/cert.crt

echo -e "[✓] SSL berhasil dibuat dan disimpan."

--- Input Telegram Bot ---

echo -e "\n[•] Konfigurasi Bot Telegram" read -rp "Bot Token: " BOT_TOKEN read -rp "Chat ID: " CHAT_ID read -rp "Client Name: " CLIENTNAME

cat <<EOF > /etc/bottelegram.conf BOT_TOKEN=$BOT_TOKEN CHAT_ID=$CHAT_ID CLIENTNAME=$CLIENTNAME EOF

--- Install & Setup XRAY Core ---

echo -e "\n[•] Install XRAY Core..." mkdir -p /usr/local/bin mkdir -p /etc/xray curl -Ls https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip unzip -q xray.zip -d xray install -m 755 xray/xray /usr/local/bin/xray rm -rf xray xray.zip

Buat file config XRAY (TLS + NTLS)

cat <<EOF > /etc/xray/config.json { "log": { "loglevel": "warning" }, "inbounds": [ { "port": 443, "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "security": "tls", "tlsSettings": { "certificates": [ { "certificateFile": "/etc/xray/cert.crt", "keyFile": "/etc/xray/private.key" } ] }, "wsSettings": { "path": "/xray" } } }, { "port": 80, "protocol": "vmess", "settings": { "clients": [] }, "streamSettings": { "network": "ws", "security": "none", "wsSettings": { "path": "/xray" } } } ], "outbounds": [ { "protocol": "freedom", "settings": {} } ] } EOF

Buat systemd service untuk xray

cat <<EOF > /etc/systemd/system/xray.service [Unit] Description=Xray Service After=network.target nss-lookup.target

[Service] User=root ExecStart=/usr/local/bin/xray -config /etc/xray/config.json Restart=on-failure

[Install] WantedBy=multi-user.target EOF

Enable & Start xray

systemctl daemon-reexec systemctl daemon-reload systemctl enable xray systemctl restart xray

echo -e "[✓] XRAY TLS & NonTLS berhasil dijalankan."

--- Notifikasi ke Telegram ---

TEXT="\xF0\x9F\x9B\xA1\xEF\xB8\x8F Setup VPS Selesai ━━━━━━━━━━━━━━━ 📡 Domain: `$domain` 🔐 SSL: Aktif 📦 XRAY: Aktif (TLS/NTLS) 🌐 IP VPS: `$IPVPS` 🏷️ Client: $CLIENTNAME 📅 Tanggal: $(date +"%d-%m-%Y %H:%M") ━━━━━━━━━━━━━━━ ✅ VPS Siap Digunakan!"

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage 
-d chat_id="$CHAT_ID" 
-d parse_mode="Markdown" 
-d text="$TEXT"

--- Tambahkan info login ---

echo "clear" >> ~/.profile echo "neofetch" >> ~/.profile echo "echo -e 'Welcome, $CLIENTNAME - $domain'" >> ~/.profile

--- Selesai ---

echo -e "\n[✓] Setup selesai! XRAY TLS/NTLS aktif & konfigurasi berhasil." echo -e "[✓] Silakan lanjut add user XRAY (VMess/VLESS) via CLI."

