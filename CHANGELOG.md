# Changelog Azr Tools

## v1.4.1
- Perbaikan bug: animasi boot sekarang menghormati pengaturan Animasi Menu
  (kalau dimatikan, boot jadi instan, bukan cuma animasi menu yang berhenti)
- Perbaikan keamanan/kestabilan: Caesar Cipher, Jadwal Sholat, dan Cek Harga Crypto
  sekarang aman dari input/respons yang mengandung tanda kutip (dulu bisa error)
- Jadwal Sholat sekarang meng-encode nama kota dengan benar (aman untuk nama kota
  berspasi)
- Submenu tiap kategori sekarang ikut berwarna sesuai kategorinya (bukan putih polos
  semua) - lebih konsisten sama daftar kategori
- Bersih-bersih komentar kode yang sudah usang
- Sudah diverifikasi: seluruh 121 fitur bisa diakses lewat menu, seluruh baris kotak
  di 9 kategori sejajar sempurna

## v1.4
- Username GitHub buat auto-update disetel ke z1d4nyt-rgb
- Tambah fitur "Riwayat Versi (Changelog)" - lihat catatan perubahan langsung dari
  Termux tanpa harus update dulu (otomatis cache offline)
- Tambah fitur: File Duplicate Finder, Auto Cleanup File Lama, Caesar Cipher/ROT13,
  JSON <-> CSV Converter, Batch Rename File, Scan Perangkat di Jaringan Lokal,
  Analisis Kata Terbanyak, Baca QR Code dari Gambar, Jadwal Sholat,
  Cek Harga Bitcoin/Crypto
- Total fitur sekarang 121+

## v1.3
- Tambah kategori baru **Hiburan & Fun**: Tebak Angka, Suit (Batu Gunting Kertas),
  Lempar Dadu, Lempar Koin, Tic Tac Toe vs CPU, Trivia Kuis Singkat, Fortune Cookie,
  Tes Kecepatan Mengetik
- Tambah fitur: Monitor Sistem Cepat, Proses Paling Berat (CPU), WHOIS Domain,
  Buat Struktur Folder Project
- Tiap kategori sekarang punya warna sendiri di daftar menu (lebih mudah dibedakan)
- Layar "Cari Fitur" dirombak jadi panel kotak, konsisten sama tampilan menu lain
- Bersih-bersih kode yang sudah tidak terpakai
- Total fitur sekarang 110+, dihitung otomatis (tidak perlu update manual)

## v1.2
- Tambah kategori Premium - Alight Motion (daftar & login pakai API sendiri)
- Tambah sistem Cek Update otomatis dari GitHub, lengkap dengan catatan perubahan
- Tambah animasi transisi saat buka kategori & efek pengisian border kotak
- Tambah fitur: Download File dari URL, Cek Status Website, Web Server Berbagi File,
  Clipboard Manager, Perintah Favorit, Cek Paket Bisa Diupdate, Pengaturan Animasi Menu
- Jumlah fitur dihitung otomatis di panel (tidak perlu update manual)

## v1.1
- UI dirombak jadi satu panel besar (border ganda), warna cyan terang
- Menu kategori jadi drill-down (pilih kategori dulu baru muncul isinya)
- Tambah fitur pencarian (Cari Fitur)
- Tambah 30+ fitur baru di berbagai kategori

## v1.0
- Rilis awal Azr Tools
