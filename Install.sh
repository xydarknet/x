#!/bin/bash

# Cek dan install tmux jika belum ada
if ! command -v tmux &> /dev/null; then
  echo "Installing tmux..."
  apt update && apt install tmux -y
fi

# Jalankan semua perintah di dalam session tmux
tmux new-session -d -s setup-session "
  echo '▶ Updating system...';
  apt update && apt upgrade -y;

  echo '▶ Disabling IPv6...';
  echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf;
  echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf;
  echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf;
  sysctl -p;

  echo '✅ Setup selesai. Silakan lanjutkan dengan setup lainnya.';
  exec bash
"

# Info buat user
echo "✅ Script sedang berjalan di dalam tmux (session: setup-session)"
echo "▶ Ketik perintah berikut untuk masuk:"
echo "   tmux attach -t setup-session"
