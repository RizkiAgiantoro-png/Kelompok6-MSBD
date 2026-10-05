Latihan Kelompok Pertemuan 6 - Mengukur Harga Sebuah Index
Kelompok 6 MSBD

Daftar Anggota Kelompok 6 dan List Commit:
1. Daffa Umayans Saragih (251402011)
   - Bagian : Langkah 1 (q00_setup.sql dan Q1) serta Langkah 2 (Q2 sampai Q6)
   - Commit : menyelesaikan setup dan latihan langkah 1 serta langkah 2 (Q1-Q6)

2. Ramadiyan Athallah Kusuma (251402027)
   - Bagian : Langkah 3 (Q7 sampai Q11)
   - Commit : (diisi setelah commit)

3. Juda Benhur Turnip (251402096)
   - Bagian : Langkah 4 (Q12 sampai Q16)
   - Commit : (diisi setelah commit)

4. Mochamad Rizki Agiantoro (251402135)
   - Bagian : Langkah 5 (Q17 sampai Q21) dan Langkah 6 (Q22 sampai Q26)
   - Commit : (diisi setelah commit)

5. Dennis Pamungkas Panjaitan (251402076)
   - Bagian : Langkah 7 (Q27 sampai Q31) dan Finalisasi Laporan
   - Commit : (diisi setelah commit)


Penjelasan Bagian Anggota 1 (Daffa Umayans Saragih - 251402011)

Bagian yang dikerjakan mencakup Langkah 1 (Setup 2 juta baris dan Q1) serta Langkah 2 (Anatomi Penyimpanan Q2 sampai Q6).

1. Daftar Berkas Langkah 1 dan Langkah 2
- q00_setup.sql : Berisi pembuatan skema lab6, tabel lab6.event_log, pengisian data awal sebanyak 2.000.000 baris menggunakan generate_series, dan eksekusi ANALYZE.
- q01_ukuran_tabel.sql : Berisi query untuk mengukur total ukuran tabel, ukuran heap, ukuran index primary key, serta menghitung rata-rata byte per baris pada lab6.event_log (Q1).
- q02_tuple_per_halaman.sql : Berisi query untuk menghitung jumlah halaman terisi serta nilai minimum, rata-rata, dan maksimum tuple per halaman menggunakan ekstraksi kolom sistem ctid (Q2).
- q03_toast_storage.sql : Berisi query pemeriksaan katalog pg_attribute untuk melihat strategi penyimpanan TOAST (attstorage) pada setiap kolom di tabel lab6.event_log (Q3).
- q04_hot_update.sql : Berisi pembuatan tabel uji hot_penuh (fillfactor 100) dan hot_longgar (fillfactor 80) masing-masing 50.000 baris, diikuti operasi UPDATE pada kolom catatan yang tidak terindeks untuk membandingkan nilai n_tup_hot_upd (Q4).
- q05_harga_fillfactor.sql : Berisi query perbandingan ukuran heap, index, dan ukuran total pada tabel hot_penuh dan hot_longgar setelah operasi UPDATE dijalankan (Q5).
- q06_update_terindeks.sql : Berisi pengujian UPDATE pada kolom kode yang memiliki index B-Tree walaupun menggunakan fillfactor 80 untuk membuktikan perbedaan perilaku HOT update antara kolom terindeks dan tidak terindeks (Q6).
- q02_anatomi_storage.sql : Berkas gabungan yang memuat seluruh query Langkah 2 (Q2 sampai Q6) sesuai penamaan pada struktur pengumpulan.
- hasil_pengukuran.md : Berisi salinan tabel keluaran terminal dari hasil eksekusi nyata untuk Q1 sampai Q6.
- laporan.md : Berisi dokumentasi kondisi uji, jawaban analisis, serta jawaban reflektif untuk Langkah 1 dan Langkah 2 (dan akan dilanjutkan oleh Anggota 2 sampai Anggota 5).


2. Cara Menjalankan di Terminal (PowerShell)

Pastikan container PostgreSQL pada Docker sudah menyala:
docker compose up -d

Jalankan setup awal 2 juta baris:
Get-Content latihan/p06/q00_setup.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila

Jalankan pengujian Q1 sampai Q6:
Get-Content latihan/p06/q01_ukuran_tabel.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila
Get-Content latihan/p06/q02_tuple_per_halaman.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila
Get-Content latihan/p06/q03_toast_storage.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila
Get-Content latihan/p06/q04_hot_update.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila
Get-Content latihan/p06/q05_harga_fillfactor.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila
Get-Content latihan/p06/q06_update_terindeks.sql -Raw | docker compose exec -T postgres psql -U msbd -d pagila