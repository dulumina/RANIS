#!/bin/bash

# Load environment variables
if [ -f "./.env" ]; then
    export $(cat ./.env | grep -v '#' | xargs)
else
    echo "File .env tidak ditemukan di ./"
    exit 1
fi

# Check availability of inotify-tools
if ! command -v inotifywait &> /dev/null; then
    echo "Aplikasi inotify-tools belum terinstall."
    read -p "Apakah Anda ingin menginstallnya? (y/n): " install_inotify
    if [ "$install_inotify" == "y" ]; then
        sudo apt update
        sudo apt install inotify-tools -y
    else
        echo "Instalasi dibatalkan. Script tidak dapat berjalan tanpa inotify-tools."
        exit 1
    fi
fi

# Read exclude patterns from exclude_dirs.txt into an array
readarray -t exclude_patterns < exclude_dirs.txt

monitor_directory() {
    inotifywait -m -r -e create,modify,delete "$WATCH_DIR" | while read path action file; do
        # Separate path and file from 'path'
        full_path="${path}${file}"

        # Check if the file is in an excluded directory
        for exclude_pattern in "${exclude_patterns[@]}"; do
            if [[ "$full_path" == $exclude_pattern ]]; then
                continue 2
            fi
        done

        if [ "$action" != "DELETE" ]; then
            echo "File $full_path telah $action"
            # Ganti dengan path ke script Python yang akan dieksekusi
            python3 ./file_monitoring.py "$full_path"
        else
            echo "File $full_path telah $action"
            # Ganti dengan logika untuk pengiriman pesan ke Telegram saat file dihapus
            current_time=$(date +"%Y-%m-%d %H:%M:%S")
            message="File $full_path telah $action pada $current_time"
            echo "$message"
            send_telegram_message "$message"
        fi
    done
}

# Function to send message to Telegram
send_telegram_message() {
    local message="$1"
    url="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"
    data="chat_id=${CHAT_ID}&text=$(echo $message)"
    curl -s -X POST $url -d "$data" > /dev/null
}

# Call function to start monitoring
monitor_directory
