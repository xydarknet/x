#!/bin/bash
ip=$(curl -s ifconfig.me)
file="/etc/xydark/approved-ip.json"

if [ ! -f "$file" ]; then
  echo "[]" > "$file"
fi

approved=$(cat "$file")
if [[ "$approved" != *"$ip"* ]]; then
  echo -e "\e[1;31mIP $ip belum diapprove. Mengirim permintaan...\e[0m"
  bash /etc/xydark/request-ip.sh
  echo -e "\e[1;33mMenunggu approval dari owner Telegram...\e[0m"
  exit 1
fi
