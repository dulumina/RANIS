# RANIS: Real-time Analyzing and Notification of Intrusion and Security

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

## Panduan Instalasi RANIS
**Unduh Skrip Instalasi:**

Pertama, unduh skrip instalasi RANIS dari repositori GitHub menggunakan wget:

```bash
wget https://raw.githubusercontent.com/dulumina/RANIS/master/install_ranis.sh
```
**Berikan Izin Eksekusi:**

Setelah berhasil diunduh, berikan izin eksekusi pada skrip instalasi:

```bash
chmod +x install_ranis.sh
```
**Jalankan Skrip Instalasi:**

Sekarang, jalankan skrip instalasi untuk memulai proses instalasi RANIS:

```bash
./install_ranis.sh
```
**Isi Nilai yang Diperlukan:**

Skrip akan meminta Anda untuk memasukkan nilai-nilai yang diperlukan dalam file .env. Pastikan untuk memasukkan nilai yang valid untuk setiap prompt:

``WATCH_DIR``: Direktori yang ingin Anda pantau untuk perubahan.
``TELEGRAM_TOKEN``: Token bot Telegram yang sudah Anda buat sebelumnya.
``CHAT_ID``: ID obrolan (chat ID) di mana notifikasi akan dikirimkan.
Contoh pengisian nilai untuk .env:

```makefile
WATCH_DIR="/home/user/public_html"
TELEGRAM_TOKEN="1234567890:ABCdefGhIjKlMnOpQrStUvWxYz1234567890"
CHAT_ID="-1001234567890"
```
**Verifikasi dan Instalasi Tambahan:**

Setelah memasukkan nilai yang diperlukan, skrip akan melanjutkan untuk mengunduh dependensi, menginstal perangkat lunak yang dibutuhkan, dan menyiapkan layanan untuk memantau perubahan file.

**Selesai!**

Setelah proses instalasi selesai, RANIS seharusnya siap untuk digunakan. Anda dapat memantau status layanan dengan menggunakan perintah:

```bash
sudo systemctl status ranis.service
```
Pastikan layanan RANIS berjalan dengan baik tanpa masalah.

**Catatan Tambahan:**
Pastikan Anda memiliki hak superuser atau akses root untuk menjalankan perintah instalasi dan mengatur layanan systemd.
Jika ada masalah atau peringatan selama instalasi, pastikan untuk mengecek log atau pesan yang ditampilkan untuk memecahkan masalahnya.
Penggunaan bot Telegram harus dipastikan berjalan dengan baik dengan mengirimkan pesan verifikasi dan memeriksa bahwa notifikasi dapat diterima dengan benar.
