-- Q1-Q5: Setup dan batas transaksi.
-- Gunakan dua koneksi terpisah bernama Sesi A dan Sesi B.
-- Jalankan per blok sesuai urutan; jangan mengeksekusi seluruh file sekaligus.
-- Kondisi awal setelah q00_setup.sql: saldo rekening 1 dan 2 masing-masing 1000000.

-- Q1 - Buktikan kondisi awal dan total saldo.
-- Jalankan di salah satu sesi setelah q00_setup.sql.
SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
ORDER BY rekening_id;

SELECT COUNT(*) AS jumlah_rekening, SUM(saldo) AS total_saldo
FROM lab9.rekening;
-- Hasil yang diharapkan: 2 rekening, total saldo 2000000.00.

-- Q2 - Perubahan belum COMMIT belum terlihat oleh sesi lain.
-- 1. Sesi A:
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo - 100000
WHERE rekening_id = 1;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- Hasil A sebelum COMMIT: 900000.00.

-- 2. Sesi B, saat transaksi A masih terbuka (autocommit aktif):
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- Hasil B yang diharapkan: 1000000.00, bukan nilai belum di-COMMIT.

-- 3. Sesi A:
COMMIT;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- Sesudah COMMIT, nilai yang diharapkan: 900000.00.

-- Q3 - Bandingkan perubahan yang di-COMMIT dengan yang di-ROLLBACK.
-- Jalankan setelah Q2 selesai.
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo - 50000
WHERE rekening_id = 1;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- Di dalam transaksi, nilai yang diharapkan: 850000.00.
ROLLBACK;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 1;
-- Setelah ROLLBACK, nilai yang diharapkan tetap 900000.00 dari Q2.

-- Q4 - Batalkan hanya perubahan setelah SAVEPOINT.
-- Jalankan setelah Q3 selesai.
BEGIN;
UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1;
SAVEPOINT setelah_rekening_1;
UPDATE lab9.rekening
SET saldo = saldo - 20000
WHERE rekening_id = 2;
SELECT rekening_id, saldo
FROM lab9.rekening
ORDER BY rekening_id;
-- Sebelum rollback ke savepoint: rekening 1 = 890000.00, rekening 2 = 980000.00.

ROLLBACK TO SAVEPOINT setelah_rekening_1;
SELECT rekening_id, saldo
FROM lab9.rekening
ORDER BY rekening_id;
-- Setelah rollback ke savepoint: rekening 1 = 890000.00, rekening 2 = 1000000.00.
COMMIT;
-- Perubahan rekening 1 sebelum savepoint bertahan; perubahan rekening 2 sesudah
-- savepoint dibatalkan.

-- Q5 - Constraint CHECK menolak saldo negatif.
-- Jalankan setelah Q4. Perhatikan SQLSTATE dari error sebelum melanjutkan.
BEGIN;
SAVEPOINT sebelum_uji_check;
UPDATE lab9.rekening
SET saldo = -1
WHERE rekening_id = 2;
-- Hasil yang diharapkan: error check_violation, SQLSTATE 23514.
-- Setelah error, transaksi berada dalam keadaan gagal; pulihkan ke savepoint:
ROLLBACK TO SAVEPOINT sebelum_uji_check;
SELECT rekening_id, saldo
FROM lab9.rekening
WHERE rekening_id = 2;
COMMIT;
-- Nilai rekening 2 tetap 1000000.00; nilai negatif tidak tersimpan.

-- Pemulihan kondisi awal agar eksperimen Q6 dan seterusnya dimulai konsisten.
-- Jalankan hanya setelah semua sesi eksperimen Q1-Q5 sudah selesai.
UPDATE lab9.rekening
SET saldo = 1000000
WHERE rekening_id IN (1, 2);

SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
ORDER BY rekening_id;
-- Kondisi akhir yang diharapkan: saldo kedua rekening kembali 1000000.00.
