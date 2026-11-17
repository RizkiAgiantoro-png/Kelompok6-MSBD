# Latihan Kelompok Pertemuan 11: Keamanan Basis Data

Repositori ini berisi hasil pengerjaan latihan keamanan basis data (Pertemuan 11) untuk Kelompok 6 MSBD. Latihan ini berfokus pada pertahanan berlapis, isolasi penyewa (RLS), pencegahan injeksi, enkripsi, dan jejak audit.

## Prasyarat
- Docker dan Docker Compose
- PostgreSQL Client (psql / DBeaver)
- Git & Python 3 (untuk pengujian injeksi)

## Cara Menyalakan Kontainer dan Memuat Skema `lab11`
Jalankan perintah berikut di terminal (berada di luar folder repo, sesuaikan dengan direktori lab):

1. Buat direktori dan jalankan kontainer pada jaringan internal tertutup:
   ```bash
   mkdir -p ~/msbd-2026/lab11/sql ~/msbd-2026/lab11/app
   cd ~/msbd-2026/lab11
   docker compose -f docker-compose.lab11.yml up -d