#!/bin/bash

# Fungsi untuk menangani sinyal SIGINT (Ctrl+C)
function cleanup {
    echo "Instalasi RANIS dibatalkan."
    echo "Menghapus folder /opt/ranis..."
    sudo rm -rf /opt/ranis
    exit 1
}

# Fungsi untuk menangani langkah 1: Download RANIS dari GitHub
function download_ranis {
    echo "Downloading RANIS from GitHub..."
    wget https://github.com/dulumina/RANIS/archive/refs/tags/latest.zip -O /tmp/ranis.zip || {
        echo "Gagal mengunduh file RANIS dari GitHub. Instalasi dibatalkan."
        cleanup
    }
}

# Fungsi untuk menangani langkah 2: Ekstrak file zip ke /opt/ranis
function extract_ranis {
    echo "Extracting files to /opt/ranis..."
    sudo mkdir -p /opt/ranis
    sudo unzip /tmp/ranis.zip -d /opt/ranis || {
        echo "Gagal mengekstrak file RANIS. Instalasi dibatalkan."
        cleanup
    }
}

# Fungsi untuk menangani langkah 3: Buat file .env dan minta pengguna untuk mengisi nilai
function create_env_file {
    echo "Creating .env file..."
    echo "Masukkan nilai yang diperlukan untuk .env:"
    read -p "WATCH_DIR (direktori untuk dipantau): " WATCH_DIR
    read -p "TELEGRAM_TOKEN: " TELEGRAM_TOKEN
    read -p "CHAT_ID: " CHAT_ID

    # Validasi input pengguna
    if [[ -z "$WATCH_DIR" || -z "$TELEGRAM_TOKEN" || -z "$CHAT_ID" ]]; then
        echo "Anda harus mengisi semua nilai yang diminta. Instalasi dibatalkan."
        cleanup
    fi

    # Buat file .env
    echo "WATCH_DIR=\"$WATCH_DIR\"" > /opt/ranis/RANIS-latest/.env
    echo "TELEGRAM_TOKEN=\"$TELEGRAM_TOKEN\"" >> /opt/ranis/RANIS-latest/.env
    echo "CHAT_ID=\"$CHAT_ID\"" >> /opt/ranis/RANIS-latest/.env
}

# Fungsi untuk menangani langkah 4: Validasi bot Telegram
function validate_telegram_bot {
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
}

# Fungsi untuk menangani langkah 5: Install aplikasi yang dibutuhkan
function install_dependencies {
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
}

# Fungsi untuk menangani langkah 6: Membuat service systemd untuk monitor_changes.sh
function create_systemd_service {
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
}

# Menjalankan langkah-langkah instalasi secara berurutan
download_ranis &&
extract_ranis &&
create_env_file &&
validate_telegram_bot &&
install_dependencies &&
create_systemd_service

