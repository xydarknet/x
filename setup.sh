
#!/bin/bash

# =====================================
# SCRIPT BY: xydark
# TELEGRAM : @xydark
# =====================================

# === INSTALL DEPENDENCIES ===
function install_dependencies() {
  apt update -y &>/dev/null
  apt install -y curl wget net-tools cron screen lsb-release jq unzip socat xz-utils gnupg dnsutils python3 python3-pip apt-transport-https libssl-dev nginx certbot &>/dev/null
  systemctl enable cron
  systemctl enable nginx
}

# === INPUT DOMAIN ===
function setup_domain() {
  clear
  read -rp "Input your domain (e.g. xydark.biz.id): " input_domain
  echo "$input_domain" > /etc/xray/domain
  DOMAIN="$input_domain"
  NS_DOMAIN="ns.$input_domain"
}

# === SETUP LICENSE VALIDATION (BASIC) ===
function setup_license() {
  LICENSE_KEY="XYDARK-PRO-V1"
  mkdir -p /etc/xydark/
  echo "$LICENSE_KEY" > /etc/xydark/license.key
}

# === PREPARE DIRECTORY STRUCTURE ===
function prepare_environment() {
  mkdir -p /etc/xray
  mkdir -p /var/lib/xydark/
  touch /var/lib/xydark/data-user
  touch /var/lib/xydark/data-limit
}

# === INSTALL XRAY CORE ===
function install_xray_core() {
  latest_xray=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep browser_download_url | grep linux-64.zip | cut -d '"' -f 4)
  curl -L -o /tmp/xray.zip "$latest_xray"
  unzip -o /tmp/xray.zip -d /tmp/xray &>/dev/null
  install -m 755 /tmp/xray/xray /usr/local/bin/xray
  rm -rf /tmp/xray /tmp/xray.zip
}

# === CONFIGURE FIREWALL ===
function configure_firewall() {
  for port in 22 80 443 8880 2086 2053; do
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
  done
  iptables-save > /etc/iptables.up.rules
  iptables-restore < /etc/iptables.up.rules
}

# === ISSUE SSL CERT WITH CERTBOT ===
function setup_ssl_cert() {
  systemctl stop nginx
  domain=$(cat /etc/xray/domain)
  certbot certonly --standalone -d "$domain" --non-interactive --agree-tos -m admin@$domain &>/dev/null
  ln -sf /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/xray.crt
  ln -sf /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/xray.key
  systemctl start nginx
}

# === CONFIGURE DEFAULT NGINX ===
function configure_nginx() {
  domain=$(cat /etc/xray/domain)
  cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name $domain;
    root /var/www/html;
    index index.html index.htm index.php;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
  systemctl restart nginx
}

# === GENERATE XRAY CONFIG JSON ===
function generate_xray_config() {
  domain=$(cat /etc/xray/domain)
  cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    { "port": 443, "protocol": "vmess", "settings": { "clients": [] },
      "streamSettings": {
        "network": "ws", "security": "tls",
        "tlsSettings": {
          "certificates": [{ "certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key" }]
        },
        "wsSettings": { "path": "/xray443", "headers": { "Host": "$domain" } }
      }
    },
    { "port": 8880, "protocol": "vmess", "settings": { "clients": [] },
      "streamSettings": {
        "network": "ws", "security": "none",
        "wsSettings": { "path": "/xray8880", "headers": { "Host": "$domain" } }
      }
    },
    { "port": 2086, "protocol": "vmess", "settings": { "clients": [] },
      "streamSettings": {
        "network": "ws", "security": "none",
        "wsSettings": { "path": "/xray2086", "headers": { "Host": "$domain" } }
      }
    },
    { "port": 2053, "protocol": "vmess", "settings": { "clients": [] },
      "streamSettings": {
        "network": "ws", "security": "tls",
        "tlsSettings": {
          "certificates": [{ "certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key" }]
        },
        "wsSettings": { "path": "/xray2053", "headers": { "Host": "$domain" } }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF
}

# === ENABLE XRAY SERVICE ===
function enable_xray_service() {
  cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable xray
  systemctl start xray
}

# === MAIN EXECUTION ===
install_dependencies
prepare_environment
setup_license
setup_domain
install_xray_core
configure_firewall
configure_nginx
setup_ssl_cert
generate_xray_config
enable_xray_service
