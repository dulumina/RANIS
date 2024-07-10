import os
import re
import sys
import requests
import datetime
import magic  # Install python-magic package: pip install python-magic
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Telegram configuration from .env file
TELEGRAM_BOT_TOKEN = os.getenv('TELEGRAM_TOKEN')
TELEGRAM_CHAT_ID = os.getenv('CHAT_ID')

# Load dangerous strings from ShellDatabase
def load_dangerous_patterns(file_path='ShellDatabase'):
    with open(file_path, 'r') as file:
        return [line.strip() for line in file.readlines()]

# Scan file for dangerous patterns
def scan_file(file_path, dangerous_patterns):
    mime = magic.Magic(mime=True)
    file_type = mime.from_file(file_path)
    
    if file_type.startswith('text'):
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.readlines()
            for i, line in enumerate(content):
                for pattern in dangerous_patterns:
                    # Escape the pattern if it contains special characters
                    escaped_pattern = re.escape(pattern)
                    if re.search(escaped_pattern, line, re.IGNORECASE):
                        return pattern, i + 1
    else:
        # Handling for non-text files (binary)
        # print(f"Scanning binary file {file_path} (type: {file_type})")
        with open(file_path, 'rb') as file:
            content = file.read()
            for pattern in dangerous_patterns:
                pattern_bytes = pattern.encode()
                if pattern_bytes in content:
                    return pattern, None  # No line number for binary files
    return None, None

# Send notification to Telegram
def send_telegram_message(message):
    url = f'https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage'
    data = {
        'chat_id': TELEGRAM_CHAT_ID,
        'text': message
    }
    response = requests.post(url, data=data)
    return response.status_code == 200

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python3 file_monitoring.py <file_to_scan>")
        sys.exit(1)

    file_to_scan = sys.argv[1]
    if not os.path.isfile(file_to_scan):
        print(f"File not found: {file_to_scan}")
        sys.exit(1)

    # print(f"Scanning file: {file_to_scan}")
    print(f"Scanning ...")
    dangerous_patterns = load_dangerous_patterns()
    detected_pattern, line_number = scan_file(file_to_scan, dangerous_patterns)

    timestamp = datetime.datetime.now().strftime("%Y%m%d")
    log_file_path = f'logs/monitoring_{timestamp}.log'
    os.makedirs(os.path.dirname(log_file_path), exist_ok=True)
    with open(log_file_path, 'a') as log_file:
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if detected_pattern:
            message = f"{current_time} - Anomaly found in {file_to_scan} at line {line_number}: {detected_pattern}"
            log_file.write(message + '\n')
            print(message)
            send_telegram_message(message)
