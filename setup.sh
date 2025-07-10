#!/bin/bash

Template: menu-ssh

◦•●◉✿ menu SSH by xydark ✿◉●•◦

DOMAIN="xydark.biz.id" SDOMAIN="ns.xydark.biz.id" PUBKEY="b58d1ccdd9780b50579a355b13bff36ce20c22966f333b2d0a48de3c5651c647" IPVPS=$(curl -s ipv4.icanhazip.com) HOSTNAME=$(hostname)

clear echo -e "\e[36m═══════════════════════════════════" echo -e "       SSH & OVPN MANAGEMENT MENU" echo -e "═══════════════════════════════════\e[0m" echo -e " 1. Create SSH Account" echo -e " 2. Delete SSH Account" echo -e " 3. Renew SSH Account" echo -e " 4. Check SSH Login User" echo -e " 5. Detail SSH Account" echo -e " 6. Change SSH Password" echo -e " 0. Back to Main Menu" echo -ne "\nSelect [0-6]: " read sshopt

case $sshopt in 1) clear echo -ne "Enter Username : "; read username if id "$username" &>/dev/null; then echo "User already exists!" exit 1 fi echo -ne "Enter Password : "; read -s password; echo echo -ne "Valid for (days): "; read days exp_date=$(date -d "+$days days" +%Y-%m-%d) exp_display=$(date -d "+$days days" +"%b %d, %Y") useradd -e $exp_date -s /bin/false -M $username echo -e "$username:$password" | chpasswd

clear
echo "╔════════════════════════╗                                         ║ sc by t.me/user_legend ║"
echo "╔════════════════════════════════════╗"
echo "║              SYS INFO              ║                             ╚════════════════════════════════════╝"
echo " OS SYSTEM: $(hostnamectl | grep 'Operating System' | cut -d ' ' -f5-)"
echo " KERNEL TYPE: $(uname -r)"
echo " CPU MODEL:  $(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed -e 's/^\s*//')"
echo " CPU FREQUENCY:  $(awk -F: '/cpu MHz/ {print $2}' /proc/cpuinfo | sed -n 1p | sed -e 's/^\s*//') MHz ($(nproc) core)"
echo " TOTAL RAM: $(free -m | awk '/Mem:/ {print $2}') MB Total / $(free -m | awk '/Mem:/ {print $3}') MB Used"
echo " TOTAL STORAGE: $(df -h / | awk 'NR==2 {print $2}') Total / $(df -h / | awk 'NR==2 {print $3}') Used"
echo " DOMAIN: $DOMAIN"
echo " SLOWDNS DOMAIN: $SDOMAIN"
echo " IP ADDRESS: $IPVPS"
echo " ISP: $(curl -s ipinfo.io/org | cut -d " " -f 2-)"
echo " REGION: $(curl -s ipinfo.io/city) [$(curl -s ipinfo.io/timezone)]"
echo " CLIENTNAME: $username"
echo " SCRIPT VERSION: 1.2.5"
echo "╔════════════════════════════════════╗"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━                                               INFORMASI PREMIUM"
echo "SSH & OVPN ACCOUNT"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "IP-Addres : $IPVPS"
echo "Hostname : $DOMAIN"
echo "Username : $username"
echo "Password : $password"
echo "Limit Device : Not Active"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Port openssh : 22, 443"
echo "Port dropbear : 109, 143, 443"
echo "Port ssh udp : 1-65535"
echo "Port stunnel : 443"
echo "Port ssh websocket http : 2052"
echo "Alternatif port ovpn & ssh websocket http : 80, 8080, 2082, 2086"
echo "Port ssh websocket https : 443"
echo "Port ovpn websocket http : 2095"
echo "Port squid : 2086, 3128"
echo "Port badvpn/udpgw : 7100-7300"
echo "DNS Hostname : $SDOMAIN"
echo "Pub key slowdns : $PUBKEY"
echo "Dns for slowdns : 1.1.1.1 / 8.8.8.8"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "OPENVPN TCP : 1194 http://$DOMAIN:8081/client-tcp-1194.ovpn"
echo "OPENVPN TCP : 443 http://$DOMAIN:8081/client-tcp-443.ovpn"
echo "OPENVPN UDP : 2200 http://$DOMAIN:8081/client-udp-2200.ovpn"
echo "OPENVPN SSL : 442 http://$DOMAIN:8081/client-tcp-ssl-442.ovpn"
echo "ALL OPENVPN CONFIG : http://$DOMAIN:8081/openvpn.zip"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Payload SSH WS : GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Payload OVPN WS : GET /ovpn HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: Websocket[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Payload WS ENHANCED : PATCH / HTTP/1.1[crlf]Host: [host][crlf]Host: ISI_BUG_DISINI[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "Expired on : $exp_display"
;;

2. 

echo -ne "Enter Username to delete: "; read deluser
if id "$deluser" &>/dev/null; then
  userdel -f "$deluser"
  echo "User '$deluser' deleted."
else
  echo "User not found."
fi
;;

3. 

echo -ne "Enter Username to renew: "; read ruser
if id "$ruser" &>/dev/null; then
  echo -ne "Extend how many days? "; read extend
  chage -E $(date -d "+$extend days" +%Y-%m-%d) $ruser
  echo "User '$ruser' extended for $extend days."
else
  echo "User not found."
fi
;;

4. 

who | grep -i ssh || echo "No SSH login found."
;;

5. 

echo -ne "\nEnter SSH Username: "; read sshuser
if id "$sshuser" &>/dev/null; then
  echo -e "\nUser: $sshuser"
  chage -l $sshuser
  lastlog -u $sshuser
else
  echo "User not found"
fi
;;

6. 

echo -ne "\nEnter SSH Username: "; read userpass
if id "$userpass" &>/dev/null; then
  echo -ne "Enter New Password: "; read -s pass1
  echo
  echo -ne "Confirm Password: "; read -s pass2
  echo
  if [[ "$pass1" == "$pass2" ]]; then
    echo -e "$userpass:$pass1" | chpasswd
    echo "Password changed successfully."
  else
    echo "Password does not match."
  fi
else
  echo "User not found."
fi
;;

0. bash /usr/local/bin/menu;; *) echo "Invalid option"; sleep 1; bash $0;; esac



