# Latihan Pertemuan 3 - SQL Lanjutan I

## Tujuan
Latihan ini membahas subquery, CTE dan recursive CTE, window function, agregasi lanjutan, operasi himpunan, JSONB, dan laporan pendapatan bulanan pada Pagila PostgreSQL.

## Prasyarat
- Docker Desktop aktif.
- PostgreSQL 17.
- Database Pagila sudah dipulihkan ke database `pagila`.

## Menjalankan Setup

```powershell
docker compose exec postgres psql -U msbd -d pagila -f /dev/stdin < latihan/p03/q00_setup.sql
```

## Urutan Menjalankan
Jalankan `q00_setup.sql`, kemudian `q01` sampai `q20`, lalu `r1_laporan_bulanan.sql`. Setiap file dapat dijalankan dengan pola:

```powershell
docker compose exec postgres psql -U msbd -d pagila -f /dev/stdin < latihan/p03/qNN_nama_file.sql
```

Q19 membuat indeks GIN pada tabel `notifikasi`. Q20 membutuhkan fungsi `jsonb_array_elements` yang tersedia pada PostgreSQL.

## Catatan Q9
Q9 menguji kondisi siklus pada tabel `pegawai`. Setelah pengujian, pulihkan relasi Rina dengan:

```sql
UPDATE pegawai SET atasan_id = NULL WHERE pegawai_id = 1;
```

## Anggota
- Mochamad Rizki Agiantoro - 251402135
- Ramadiyan Athallah Kusuma - 251402027
- Juda Benhur Turnip - 251402096
- Dennis Pamungkas Panjaitan - 251402076
- Daffa Umayans Saragih - 251402011
