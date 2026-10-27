======an P09 - Transaksi dan Kendali Konkurensi

## Isi folder

- `q00_setup.sql`: menyiapkan skema `lab9` dan kondisi awal rekening.
- `q01_q32_transaksi.sql`: kumpulan langkah Q1-Q32. Jalankan per blok sesuai
  petunjuk sesi; jangan menjalankan seluruh berkas sebagai satu batch.
- `laporan.md`: jawaban, hasil eksperimen, analisis, dan rekomendasi.
- `bukti/`: bukti eksperimen kelompok.
- `bukti/hasil-sesi.txt`: transkrip hasil Q1-Q5 dan Q30 yang dijalankan pada
  PostgreSQL kelompok.

Skrip bagian (`q01_q05_transaksi.sql`, `q06_q17_transaksi.sql`,
`q18_q29_langkah4_5.sql`, dan `q30_read_skew.sql`) dipertahankan agar langkah
tertentu mudah dijalankan dan ditinjau. Skrip bagian maupun skrip gabungan
berisi operasi yang dapat mengubah atau mereset data di skema `lab9`.

## Prasyarat

- Docker Desktop dan Docker Compose.
- Image PostgreSQL 17 sesuai `docker-compose.yml`.
- Dua terminal PowerShell atau dua editor SQL yang membuka koneksi terpisah ke
  database `latihan`; sesi ketiga opsional untuk memeriksa lock.

Jalankan perintah dari root repository. Pastikan service PostgreSQL aktif:

```powershell
docker compose up -d postgres
docker compose ps
```

Jalankan setup (mengatur kembali rekening 1 dan 2 ke saldo awal):

```powershell
Get-Content -Raw .\latihan\p09\q00_setup.sql |
  docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U msbd -d latihan
```

Buka dua sesi interaktif:

```powershell
docker compose exec postgres psql -U msbd -d latihan
```

Ulangi perintah tersebut pada terminal kedua. Ikuti komentar `SESI A`, `SESI B`,
dan urutan langkah pada skrip. Untuk melihat SQLSTATE di psql:

```text
\set VERBOSITY verbose
```

Jangan menutup sesi yang sedang memegang transaksi/lock sampai instruksi
menyatakan `COMMIT` atau `ROLLBACK`. Setelah eksperimen, verifikasi dan pulihkan
data sesuai bagian cleanup. Jangan jalankan skrip reset pada database yang
sedang digunakan kelompok lain.

## Catatan pengumpulan

Laporan dan transkrip harus mencerminkan hasil aktual. Angka yang diberi label
hasil diharapkan di skrip adalah panduan, bukan pengganti bukti. Lengkapi
identitas/kontribusi anggota dan tinjau seluruh bagian Q1-Q32 sebelum commit ke
cabang `latihan/p09-transaksi-konkurensi`.
