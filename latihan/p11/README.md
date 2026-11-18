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
   ```

2. Dari direktori lab yang berisi aset resmi modul, muat data ke kontainer:

   ```powershell
   docker cp ./sql/lab11_setup.sql lab11-db:/sql/lab11_setup.sql
   docker exec -i lab11-db psql -X -v ON_ERROR_STOP=1 -U postgres -d msbd -f /sql/lab11_setup.sql
   ```

## Menjalankan kontrol defensif Q12–Q18

Gunakan `docker-compose.lab11.yml` dan `lab11_setup.sql` dari modul praktikum. Muat skema dan data resmi ke database `msbd`, lalu pastikan kebijakan Q6–Q9 sudah aktif. Jalankan PowerShell dari folder tugas yang memuat `latihan/p11`. Pada penamaan standar modul, `docker network inspect lab11_labnet --format '{{.Internal}}'` harus menampilkan `true`.

Salin skrip ke `lab11-web` dan jalankan dengan Python serta Psycopg 3 yang tersedia di kontainer. Skrip masuk sebagai `app_laporan` dan membaca pengaturan koneksi libpq, termasuk `PGHOST` dan kredensial lab dari lingkungan kontainer atau passfile bila autentikasi memerlukannya.

```powershell
$p11 = (Resolve-Path 'latihan/p11').Path
docker cp "$p11/rentan.py" lab11-web:/tmp/rentan.py
docker exec -e PGHOST=lab11-db lab11-web python /tmp/rentan.py --pembanding 'Pelanggan 12'
docker exec -e PGHOST=lab11-db lab11-web python /tmp/rentan.py "O'Neil"
docker exec -e PGHOST=lab11-db lab11-web python /tmp/rentan.py --urut --kolom kota --arah turun 'Pelanggan'
docker exec lab11-web python /tmp/rentan.py --validasi-urut --kolom kota --arah turun
docker exec lab11-web python /tmp/rentan.py --validasi-urut --kolom saldo --arah turun
docker exec lab11-web python /tmp/rentan.py --validasi-urut --kolom kota --arah acak
```

Hasil pembanding dijalankan tanpa `LIMIT`. Pencarian biasa dibatasi 100 baris. Dua perintah terakhir diharapkan keluar dengan kode `2`.

Jalankan SQL Q12–Q17 dengan login `app_laporan`. Q17 memakai tabel sementara dan membutuhkan hak `TEMP` pada database. Gunakan kredensial lokal praktikum bila konfigurasi autentikasi memintanya.

```powershell
12..17 | ForEach-Object {
    $file = Get-ChildItem -LiteralPath $p11 -Filter ('q{0}_*.sql' -f $_)
    Get-Content -Raw -LiteralPath $file.FullName |
        docker exec -i lab11-db psql -X -v ON_ERROR_STOP=1 -U app_laporan -d msbd
    if ($LASTEXITCODE -ne 0) { throw "Gagal menjalankan $($file.Name)" }
}
```

Untuk Q18, pasang pengaturan sebagai `postgres`, lalu login ulang langsung sebagai `app_portal` dan periksa nilai aktifnya.

```powershell
Get-Content -Raw -LiteralPath "$p11/q18_batas_waktu.sql" |
    docker exec -i lab11-db psql -X -v ON_ERROR_STOP=1 -U postgres -d msbd
docker exec -it lab11-db psql -X -U app_portal -d msbd -c 'SHOW statement_timeout;'
```
