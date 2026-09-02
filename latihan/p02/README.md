Manajemen Sistem Basis Data - Peminjaman Alat Laboratorium
Repositori ini berisi pengerjaan Latihan 2 (Dari Kebutuhan ke Skema Berversi) untuk mata kuliah Manajemen Sistem Basis Data. Proyek ini menggunakan arsitektur kontainer (Docker), PostgreSQL, dan Flyway untuk manajemen skema (database migration).

Kelompok 6
Mochamad Rizki Agiantoro (251402135)

Ramadiyan Athallah Kusuma (251402027)

Juda Benhur Turnip (251402096)

Dennis Pamungkas Panjaitan (251402076)

Daffa Umayans Saragih (251402011)

Persyaratan Sistem
Docker dan Docker Compose Plugin terinstal.

Terminal (Bash atau PowerShell).

Panduan Menjalankan Proyek
1. Menjalankan Docker dan Membuat Database
Nyalakan container dan buat database untuk development serta testing:

Bash
docker compose up -d
docker compose exec postgres psql -U msbd -d latihan -c "CREATE DATABASE proyek_dev;"
docker compose exec postgres psql -U msbd -d latihan -c "CREATE DATABASE proyek_test;"
2. Menjalankan Migrasi Skema (Flyway)
Migrasi akan secara otomatis membaca konfigurasi proyek_dev dari file docker-compose.yml dan membangun struktur tabel:

Bash
docker compose run --rm flyway migrate
3. Menjalankan Seed Data (Idempoten)
Untuk mengisi data master awal, jalankan perintah ini dari terminal (gunakan PowerShell jika menggunakan OS Windows):

PowerShell
1..2 | ForEach-Object { Get-Content latihan/p02/seeds/01_master_data.sql | docker compose exec -T postgres psql -U msbd -d proyek_dev }
Untuk memverifikasi bahwa seed bersifat idempoten (data tidak menjadi ganda meski dijalankan berkali-kali), jalankan perintah penghitungan baris berikut:

Bash
docker compose exec postgres psql -U msbd -d proyek_dev -c "SELECT count(*) FROM kategori; SELECT count(*) FROM anggota;"