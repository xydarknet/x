# FINAL SETUP.SH (IP EXPIRED APPROVAL ENABLED, JQ INSTALLED, BOT SERVICE ENABLED)

#!/bin/bash
ip=$(curl -s ifconfig.me)
file="/etc/xydark/approved-ip.json"
today=$(date +%Y-%m-%d)

if [ ! -f "$file" ]; then
  echo "[]" > "$file"
fi

expired=$(jq -r --arg ip "$ip" '.[] | select(.ip == $ip) | .expired' $file)

if [ -z "$expired" ]; then
  echo -e "\e[1;31mIP $ip belum diapprove. Mengirim permintaan...\e[0m"
  bash /etc/xydark/request-ip.sh
  exit 1
fi

if [[ "$today" > "$expired" ]]; then
  echo -e "\e[1;31mIP $ip sudah expired pada $expired.\e[0m"
  exit 1
fi


# === AUTO HAPUS IP EXPIRED ===
cat << 'EOF' > /etc/xydark/clean-expired-ip.sh
#!/bin/bash
file="/etc/xydark/approved-ip.json"
today=$(date +%Y-%m-%d)
tmp="/etc/xydark/tmp.json"

jq '[.[] | select(.expired >= "'$today'")]' $file > $tmp && mv $tmp $file

EOF
chmod +x /etc/xydark/clean-expired-ip.sh

# Tambahkan cronjob harian jam 3 pagi
(crontab -l 2>/dev/null; echo "0 3 * * * /etc/xydark/clean-expired-ip.sh") | crontab -
