
# === CEK PRE-APPROVED IP LIST ===
my_ip=$(curl -s ifconfig.me)
whitelist_url="https://raw.githubusercontent.com/xydarknet/tunnel-setup/main/whitelist.txt"
if curl -s "$whitelist_url" | grep -wq "$my_ip"; then
  echo "✅ IP $my_ip ditemukan dalam daftar whitelist. Lanjutkan setup."
else
  echo "⛔ IP $my_ip tidak ditemukan dalam whitelist GitHub."
  echo "Silakan hubungi admin Telegram @xydark untuk mendapatkan akses."
  exit 1
fi

#!/bin/bash
# setup.sh by xydark

# Fungsi Install Xray via script resmi
function install_xray_core() {
  echo -e "▶ Installing Xray Core..."
  mkdir -p /tmp/xray
  curl -o /tmp/xray/install.sh -Ls https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh
  bash /tmp/xray/install.sh install
  echo -e "✔ Xray Installed."
}

# Aktifkan xray service
function enable_xray_service() {
  systemctl enable xray
  systemctl start xray
}

# Jalankan instalasi
install_xray_core
enable_xray_service

# === INSTALL MENU UTAMA ===
wget -O /usr/bin/menu https://raw.githubusercontent.com/xydarknet/tunnel-setup/main/menu.sh
chmod +x /usr/bin/menu

# === PASANG SYSTEM INFO SAAT LOGIN ===
mkdir -p /etc/xydark
wget -O /etc/xydark/system-info.sh https://raw.githubusercontent.com/xydarknet/tunnel-setup/main/system-info.sh
chmod +x /etc/xydark/system-info.sh

if ! grep -q "system-info.sh" /root/.bashrc; then
  echo "bash /etc/xydark/system-info.sh" >> /root/.bashrc
fi

if ! grep -q "/usr/bin/menu" /root/.bashrc; then
  echo "menu" >> /root/.bashrc
fi

# === TELEGRAM BOT IP APPROVAL SYSTEM ===
echo "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw" > /etc/xydark/bot-token
echo "-4939887004" > /etc/xydark/owner-id

# Download script request-ip dan check-ip
wget -O /etc/xydark/request-ip.sh https://raw.githubusercontent.com/xydarknet/tunnel-setup/main/request-ip.sh
chmod +x /etc/xydark/request-ip.sh

wget -O /etc/xydark/check-ip.sh https://raw.githubusercontent.com/xydarknet/tunnel-setup/main/check-ip.sh
chmod +x /etc/xydark/check-ip.sh

# Tambahkan ke login root
if ! grep -q "/etc/xydark/check-ip.sh" /root/.bashrc; then
  echo "bash /etc/xydark/check-ip.sh || exit" >> /root/.bashrc
fi

# Cek IP sebelum lanjut install
bash /etc/xydark/check-ip.sh || exit 1
