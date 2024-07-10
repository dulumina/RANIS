#!/bin/bash

# Fungsi untuk menangani sinyal SIGINT (Ctrl+C)
function cleanup {
    echo "Instalasi RANIS dibatalkan."
    echo "Menghapus folder /opt/ranis..."
    sudo rm -rf /opt/ranis
    exit 1
}

# Menangkap sinyal SIGINT (Ctrl+C)
trap cleanup SIGINT

# Step 1: Download file zip dari repository RANIS
echo "Downloading RANIS from GitHub..."
wget https://github.com/dulumina/RANIS/archive/refs/tags/latest.zip -O /tmp/ranis.zip || {
    echo "Gagal mengunduh file RANIS dari GitHub. Instalasi dibatalkan."
    cleanup
}

# Step 2: Ekstrak file zip ke folder /opt/ranis
echo "Extracting files to /opt/ranis..."
sudo mkdir -p /opt/ranis
sudo unzip /tmp/ranis.zip -d /opt/ranis || {
    echo "Gagal mengekstrak file RANIS. Instalasi dibatalkan."
    cleanup
}

# Step 3: Buat file .env dan minta pengguna untuk mengisi nilai
echo "Creating .env file..."
echo "Masukkan nilai yang diperlukan untuk .env:"
read -p "WATCH_DIR (direktori untuk dipantau): " WATCH_DIR
read -p "TELEGRAM_TOKEN: " TELEGRAM_TOKEN
read -p "CHAT_ID: " CHAT_ID

# Buat file .env
echo "WATCH_DIR=\"$WATCH_DIR\"" > /opt/ranis/RANIS-latest/.env
echo "TELEGRAM_TOKEN=\"$TELEGRAM_TOKEN\"" >> /opt/ranis/RANIS-latest/.env
echo "CHAT_ID=\"$CHAT_ID\"" >> /opt/ranis/RANIS-latest/.env

# Step 4: Validasi bot Telegram
echo "Untuk melanjutkan, Anda perlu memvalidasi bot Telegram."
echo "Silakan kirimkan angka berikut ke bot Telegram Anda:"

# Generate random 4-digit number
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)
echo "Angka untuk dikirim: $RANDOM_NUMBER"

# Kirim pesan ke bot Telegram
BOT_TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$CHAT_ID"
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Pesan yang akan dikirim
MESSAGE="Silakan ketikkan angka berikut pada terminal untuk memverifikasi: $RANDOM_NUMBER"
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" || {
    echo "Gagal mengirim pesan ke bot Telegram. Instalasi dibatalkan."
    cleanup
}

echo "Memeriksa apakah bot Telegram berjalan..."
echo "Menunggu konfirmasi..."

# Loop sampai angka yang dikirimkan benar atau pengguna mengakhiri dengan Ctrl+C
while true; do
    read -p "Masukkan angka yang Anda terima di Telegram: " USER_INPUT
    if [[ "$USER_INPUT" == "$RANDOM_NUMBER" ]]; then
        echo "Konfirmasi berhasil."
        break
    else
        echo "Angka yang dimasukkan tidak cocok. Silakan coba lagi."
    fi
done

# Step 5: Install aplikasi yang dibutuhkan
echo "Installing inotify-tools..."
sudo apt update && sudo apt install -y inotify-tools || {
    echo "Gagal menginstal inotify-tools. Instalasi dibatalkan."
    cleanup
}

# Install requirements Python dari RANIS
echo "Installing Python requirements..."
sudo apt install -y python3-pip
sudo pip3 install -r /opt/ranis/RANIS-latest/requirements.txt || {
    echo "Gagal menginstal Python requirements. Instalasi dibatalkan."
    cleanup
}

# Step 6: Membuat service untuk monitor_changes.sh
echo "Creating systemd service..."

# Isi unit file service
cat <<EOF | sudo tee /etc/systemd/system/ranis.service
[Unit]
Description=RANIS File Monitoring Service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/opt/ranis/RANIS-latest
ExecStart=/bin/bash /opt/ranis/RANIS-latest/monitor_changes.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Memulai service
echo "Starting RANIS service..."
sudo systemctl daemon-reload
sudo systemctl enable ranis.service
sudo systemctl start ranis.service

echo "Instalasi RANIS selesai!"
echo "Anda dapat memantau status service dengan menjalankan: sudo systemctl status ranis.service"
