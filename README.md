### RANIS: Real-time Analyzing and Notification of Intrusion and Security

**Deskripsi:**
RANIS adalah sebuah aplikasi yang dirancang untuk melakukan analisis secara real-time dan memberikan notifikasi terhadap intrusi dan keamanan pada sistem. Aplikasi ini memonitor perubahan file dan folder secara kontinyu, serta melakukan pemindaian terhadap perubahan tersebut untuk mendeteksi keberadaan tanda-tanda yang mencurigakan, seperti skrip berbahaya. Setiap kali sebuah anomali terdeteksi, RANIS memberikan notifikasi segera melalui Telegram, memastikan respons cepat terhadap potensi ancaman keamanan.

**Fitur Utama:**
- Monitoring real-time terhadap perubahan file dan folder.
- Analisis otomatis terhadap perubahan untuk deteksi tanda-tanda intrusi.
- Notifikasi cepat melalui platform Telegram saat adanya anomali keamanan.
- Penggunaan tanda tangan mencurigakan untuk pemindaian lebih akurat.
- Mendukung pengaturan eksklusi direktori untuk menghindari pemindaian yang tidak perlu.
  
**Tujuan:**
RANIS bertujuan untuk meningkatkan keamanan sistem dengan memberikan kemampuan deteksi dini terhadap intrusi dan ancaman keamanan, sehingga memungkinkan pengguna untuk merespons secara efektif terhadap potensi risiko yang muncul.

**Catatan Penggunaan:**
Pastikan untuk mengonfigurasi file `.env` dengan token bot Telegram (`TELEGRAM_TOKEN`) dan ID chat (`CHAT_ID`) yang tepat sebelum menggunakan aplikasi ini.

**Kebutuhan Sistem:**
- Python 3.x
- Modul-modul Python: `python-magic`, `python-dotenv`
- Aplikasi inotify-tools untuk Linux (jika belum terinstall, akan diinstalasi secara otomatis)

**Cara Penggunaan:**
1. Clone repositori ini ke dalam server yang akan dimonitor.
2. Konfigurasi file `.env` dengan token bot Telegram dan ID chat.
3. Jalankan `monitor_changes.sh` untuk memulai monitoring perubahan file dan folder.

RANIS dibuat untuk memenuhi kebutuhan pemantauan keamanan yang efektif dan responsif dalam lingkungan sistem yang dinamis dan rentan terhadap serangan cyber.

# Panduan Instalasi RANIS

Untuk menginstal RANIS, Anda dapat menggunakan skrip instalasi yang disediakan. Berikut langkah-langkahnya:

1. **Buka Terminal**
   Buka terminal pada sistem Anda.

2. **Jalankan Instalasi**
   Salin dan tempel perintah berikut ini ke terminal Anda dan tekan Enter:
   ```bash
   curl -sSL https://raw.githubusercontent.com/dulumina/RANIS/master/install_ranis.sh | bash

