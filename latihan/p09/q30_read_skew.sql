-- Q30 tambahan: demonstrasi pembacaan tidak konsisten (read skew).
-- Gunakan dua sesi psql/SQL Editor dan mulai dari saldo rekening 1 dan 2
-- masing-masing 1000000. Jangan jalankan file ini sekaligus.
-- Sesi pembaca menggunakan READ COMMITTED (default PostgreSQL).

-- 1. SESI PEMBACA: ambil nilai rekening 2 sebelum transfer di-COMMIT.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 2;
-- Catat hasil awal rekening 2 (seharusnya 1000000.00). Biarkan transaksi terbuka.

-- 2. SESI TRANSFER: jalankan saat transaksi pembaca masih terbuka.
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo - 100000
WHERE rekening_id = 1;
UPDATE lab9.rekening
SET saldo = saldo + 100000
WHERE rekening_id = 2;
COMMIT;
-- Transfer menjaga total database tetap 2000000.00.

-- 3. SESI PEMBACA: baca rekening 1 setelah transfer di-COMMIT.
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- READ COMMITTED memberi snapshot baru untuk pernyataan ini. Hasil yang
-- diharapkan: rekening 1 = 900000.00; pembacaan campuran 1000000 + 900000
-- menghasilkan 1900000.00 walau total konsisten database tetap 2000000.00.
ROLLBACK;

-- 4. SESI MANA PUN: kembalikan kondisi awal setelah kedua sesi selesai.
UPDATE lab9.rekening
SET saldo = 1000000
WHERE rekening_id IN (1, 2);
