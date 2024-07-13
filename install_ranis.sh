#!/bin/bash

# Function to prompt and validate input
prompt_input() {
    local var_name="$1"
    local prompt_message="$2"
    local error_message="$3"

    while true; do
        read -p "$prompt_message: " input_value
        if [ -z "$input_value" ]; then
            echo "$error_message. Instalasi dibatalkan."
            rollback_installation
            exit 1
        else
            eval "$var_name=\"$input_value\""  # Assign input value to variable name
            break
        fi
    done
}

# Function to rollback installation
rollback_installation() {
    echo "Rolling back installation..."
    sudo systemctl stop ranis.service  # Stop service jika sudah dimulai
    sudo systemctl disable ranis.service
    sudo rm /etc/systemd/system/ranis.service  # Hapus unit service
    sudo systemctl daemon-reload
    sudo rm /usr/local/bin/rains_scan  # Hapus symbolic link
    sudo rm -rf /opt/ranis  # Hapus folder /opt/ranis
}

# Function to handle SIGINT (Ctrl+C)
sigint_handler() {
    echo "Received SIGINT. Rolling back installation..."
    rollback_installation
    exit 1
}

# Register SIGINT handler
trap sigint_handler SIGINT

# Handle arguments
if [ "$1" == "--remove" ]; then
    rollback_installation
    exit 0
fi

# Step 1: Download file zip dari repository RANIS
echo "Downloading RANIS from GitHub..."
wget https://github.com/dulumina/RANIS/archive/refs/tags/latest.zip -O /tmp/ranis.zip || { echo "Failed to download RANIS. Instalasi dibatalkan."; exit 1; }

# Step 2: Ekstrak file zip ke folder /opt/ranis
echo "Extracting files to /opt/ranis..."
sudo mkdir -p /opt/ranis
sudo unzip /tmp/ranis.zip -d /opt/ranis || { echo "Failed to extract RANIS. Instalasi dibatalkan."; rollback_installation; exit 1; }

# Step 3: Buat file .env dan minta pengguna untuk mengisi nilai
echo "Creating .env file..."
echo "Masukkan nilai yang diperlukan untuk .env:"

# Meminta nilai WATCH_DIR
prompt_input WATCH_DIR "WATCH_DIR (direktori untuk dipantau)" "WATCH_DIR tidak boleh kosong"

# Meminta nilai TELEGRAM_TOKEN
prompt_input TELEGRAM_TOKEN "TELEGRAM_TOKEN" "TELEGRAM_TOKEN tidak boleh kosong"

# Meminta nilai CHAT_ID
prompt_input CHAT_ID "CHAT_ID" "CHAT_ID tidak boleh kosong"

# Buat file .env
echo "WATCH_DIR=\"$WATCH_DIR\"" > /opt/ranis/RANIS-latest/.env
echo "TELEGRAM_TOKEN=\"$TELEGRAM_TOKEN\"" >> /opt/ranis/RANIS-latest/.env
echo "CHAT_ID=\"$CHAT_ID\"" >> /opt/ranis/RANIS-latest/.env

# Step 4: Validasi bot Telegram
echo "Untuk melanjutkan, Anda perlu memvalidasi bot Telegram."
echo "Silakan kirimkan angka berikut ke bot Telegram Anda:"

# Generate random 4-digit number
RANDOM_NUMBER=$(shuf -i 1000-9999 -n 1)
# echo "Angka untuk dikirim: $RANDOM_NUMBER"

# Kirim pesan ke bot Telegram
BOT_TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$CHAT_ID"
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Pesan yang akan dikirim
MESSAGE="Silakan ketikkan angka berikut pada terminal untuk memverifikasi: $RANDOM_NUMBER"
curl -o /dev/null -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" || { echo "Failed to send message to Telegram. Instalasi dibatalkan."; rollback_installation; exit 1; }

echo "Memeriksa apakah bot Telegram berjalan..."
echo "Menunggu konfirmasi..."

# Loop sampai angka yang dikirimkan benar
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
sudo apt update && sudo apt install -y inotify-tools || { echo "Failed to install inotify-tools. Instalasi dibatalkan."; rollback_installation; exit 1; }

# Install requirements Python dari RANIS
echo "Installing Python requirements..."
sudo apt install -y python3-pip && sudo pip3 install -r /opt/ranis/RANIS-latest/requirements.txt || { echo "Failed to install Python requirements. Instalasi dibatalkan."; rollback_installation; exit 1; }

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

# Membuat symbolic link untuk rains_scan
echo "Creating symbolic link for rains_scan..."
sudo ln -s /opt/ranis/RANIS-latest/ranis_scan /usr/local/bin/ranis_scan || { echo "Failed to create symbolic link for rains_scan. Instalasi dibatalkan."; rollback_installation; exit 1; }

# Memulai service
echo "Starting RANIS service..."
sudo systemctl daemon-reload && sudo systemctl enable ranis.service && sudo systemctl start ranis.service || { echo "Failed to start RANIS service. Instalasi dibatalkan."; rollback_installation; exit 1; }

echo "Instalasi RANIS selesai!"
echo "Anda dapat memantau status service dengan menjalankan: sudo systemctl status ranis.service"
