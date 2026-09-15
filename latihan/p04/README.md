# SQL Lanjutan II — Audit Log, Materialized View, dan Migrasi Aman

## Prasyarat

- PostgreSQL 17
- Docker Desktop aktif
- Docker Compose tersedia
- Repository `msbd-2026` sudah diperbarui

## Setup

Jalankan layanan basis data:

```powershell
docker compose up -d
docker compose ps
```

Jalankan setup lab4:

```powershell
Get-Content ".\latihan\p04\q00_setup.sql" | docker compose exec -T postgres psql -U msbd -d latihan
```

Hasil yang diharapkan: `lab4.jejak_akses` berisi 500000 baris.

## Urutan pengerjaan

1. Q1–Q4: view, check option, dan view agregat
2. Q5–Q8: materialized view dan concurrent refresh
3. Q9–Q13: trigger audit baris dan pernyataan
4. Q14–Q17: constraint, unique partial, foreign key, dan EXCLUDE
5. Q18–Q21: expand–contract dan migrasi berversi

## Sesi khusus

- Q8 membutuhkan dua sesi PostgreSQL untuk membuktikan pembaca tetap bisa membaca saat refresh concurrent berlangsung.
- Q20 membutuhkan sesi pembaca lama:

```sql
SELECT title, rental_rate
FROM lab4.film
LIMIT 5;
```

## Peringatan penting

Jangan menjalankan Q20 atau migration 0046 sebelum:

1. Q19 menghasilkan `0` pada verifikasi backfill.
2. View fasad sudah stabil.
3. Pembaca lama sudah diuji.
4. Semua bukti eksperimen terkumpul.

Migration 0046 tidak bisa di-rollback sepenuhnya karena data lama `rental_rate` sudah tidak lagi ada di bentuk lama.
