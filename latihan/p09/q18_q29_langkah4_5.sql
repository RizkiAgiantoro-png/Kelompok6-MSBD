-- =====================================================================
-- LANGKAH 4 & 5 (Q18-Q29)  |  Schema: lab9  |  Dikerjakan: Juda Benhur Turnip
-- Tempel ke q01_q32_transaksi.sql (bagian Langkah 4 dan 5).
-- Setiap blok diberi label [SESI A] / [SESI B]. Jalankan sesuai URUTAN NOMOR.
-- Pakai 2 terminal psql (atau 2 SQL Editor DBeaver) = Sesi A dan Sesi B.
-- =====================================================================

-- Reset data sebelum mulai (jalankan di salah satu sesi)
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id IN (1,2);

-- =====================================================================
-- Q18 (teori, tanpa eksekusi) -> jawaban ada di laporan
-- =====================================================================

-- =====================================================================
-- Q19 - FOR UPDATE: Sesi B menunggu
-- =====================================================================
-- 1. [SESI A]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 2. [SESI B]  -> perintah ini "menggantung" (menunggu). Biarkan, jangan ditutup.
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 3. [SESI A]  (opsional, untuk bukti: lihat siapa yang menunggu; jalankan di sesi ketiga/A sebelum commit)
--    SELECT pid, state, wait_event_type, wait_event, left(query,60) AS query
--    FROM pg_stat_activity WHERE datname = current_database() AND state <> 'idle';
-- 4. [SESI A]
COMMIT;
-- 5. [SESI B]  -> sekarang hasil keluar. Lalu:
COMMIT;

-- =====================================================================
-- Q20 - DEADLOCK
-- =====================================================================
-- 1. [SESI A]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 2. [SESI B]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;
-- 3. [SESI A]  -> menunggu
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;
-- 4. [SESI B]  -> dalam ~1 detik salah satu sesi kena ERROR 40P01 deadlock detected
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 5. Catat sesi yang kena error + SQLSTATE 40P01. Lalu di KEDUA sesi:
ROLLBACK;
-- (Untuk melihat SQLSTATE di psql: \set VERBOSITY verbose   sebelum eksperimen)

-- =====================================================================
-- Q21 - Urutan kunci konsisten (kecil -> besar) = tidak deadlock
-- =====================================================================
-- 1. [SESI A]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 2. [SESI B]  -> menunggu (bukan deadlock), karena B juga mulai dari id 1
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 3. [SESI A]
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;
COMMIT;
-- 4. [SESI B]  -> lanjut otomatis
SELECT * FROM lab9.rekening WHERE rekening_id = 2 FOR UPDATE;
COMMIT;

-- =====================================================================
-- Q22 - Antrean lock panjang (BUKAN deadlock)
-- =====================================================================
-- 1. [SESI A]  transaksi ditahan terbuka (lupa COMMIT)
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 1000 WHERE rekening_id = 1;
-- 2. [SESI B]  -> menggantung tanpa error, selama A belum selesai
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 2000 WHERE rekening_id = 1;
-- 3. [SESI C / terminal baru]  bukti siapa memblokir siapa
SELECT pid, pg_blocking_pids(pid) AS diblokir_oleh, state, wait_event_type, left(query,50) AS query
FROM pg_stat_activity WHERE datname = current_database() AND state <> 'idle';
-- 4. [SESI A]
ROLLBACK;
-- 5. [SESI B]  -> selesai sendiri. Lalu:
ROLLBACK;

-- =====================================================================
-- Q23 - Timeout (demo lock_timeout dengan SET LOCAL)
-- =====================================================================
SHOW deadlock_timeout;
SHOW lock_timeout;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;
-- 1. [SESI A]
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- 2. [SESI B]  -> gagal setelah 2 detik: ERROR canceling statement due to lock timeout (SQLSTATE 55P03)
BEGIN;
SET LOCAL lock_timeout = '2s';
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
ROLLBACK;
-- 3. [SESI A]
ROLLBACK;

-- =====================================================================
-- Q24 - SKIP LOCKED
-- =====================================================================
CREATE TABLE IF NOT EXISTS lab9.antrean (
    id INT PRIMARY KEY,
    pekerjaan TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'baru'
);
TRUNCATE lab9.antrean;
INSERT INTO lab9.antrean VALUES
(1,'kirim email A','baru'),(2,'kirim email B','baru'),(3,'kirim email C','baru');
-- 1. [SESI A]  kunci baris 1
BEGIN;
SELECT * FROM lab9.antrean WHERE id = 1 FOR UPDATE;
-- 2. [SESI B]  -> langsung dapat baris id=2 (baris 1 dilewati), tanpa menunggu
BEGIN;
SELECT * FROM lab9.antrean WHERE status = 'baru' ORDER BY id
FOR UPDATE SKIP LOCKED LIMIT 1;
ROLLBACK;
-- 3. [SESI A]
ROLLBACK;

-- =====================================================================
-- Q25 - NOWAIT
-- =====================================================================
-- 1. [SESI A]
BEGIN;
SELECT * FROM lab9.antrean WHERE id = 1 FOR UPDATE;
-- 2. [SESI B]  -> langsung ERROR 55P03 "could not obtain lock on row", tidak menunggu
BEGIN;
SELECT * FROM lab9.antrean WHERE id = 1 FOR UPDATE NOWAIT;
ROLLBACK;     -- wajib, transaksi B sudah aborted
-- 3. [SESI A]
ROLLBACK;

-- =====================================================================
-- Q26 - WRITE SKEW (REPEATABLE READ)
-- =====================================================================
CREATE TABLE IF NOT EXISTS lab9.dokter_jaga (
    dokter_id INT PRIMARY KEY,
    nama TEXT NOT NULL,
    aktif BOOLEAN NOT NULL
);
TRUNCATE lab9.dokter_jaga;
INSERT INTO lab9.dokter_jaga VALUES (1,'Dr. Sari',true),(2,'Dr. Tono',true);
-- Aturan bisnis: minimal 1 dokter harus aktif.
-- 1. [SESI A]
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS aktif FROM lab9.dokter_jaga WHERE aktif;     -- hasil 2
-- 2. [SESI B]
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS aktif FROM lab9.dokter_jaga WHERE aktif;     -- hasil 2
-- 3. [SESI A]  (karena lihat 2, merasa aman menonaktifkan dokter 1)
UPDATE lab9.dokter_jaga SET aktif = false WHERE dokter_id = 1;
COMMIT;
-- 4. [SESI B]  (juga lihat 2, menonaktifkan dokter 2)
UPDATE lab9.dokter_jaga SET aktif = false WHERE dokter_id = 2;
COMMIT;         -- BERHASIL -> kedua COMMIT sukses
-- 5. Cek: aturan dilanggar (0 dokter aktif)
SELECT * FROM lab9.dokter_jaga ORDER BY dokter_id;

-- =====================================================================
-- Q27 - SERIALIZABLE (skenario sama, salah satu dibatalkan 40001)
-- =====================================================================
UPDATE lab9.dokter_jaga SET aktif = true;      -- reset
-- 1. [SESI A]
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS aktif FROM lab9.dokter_jaga WHERE aktif;
-- 2. [SESI B]
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS aktif FROM lab9.dokter_jaga WHERE aktif;
-- 3. [SESI A]
UPDATE lab9.dokter_jaga SET aktif = false WHERE dokter_id = 1;
COMMIT;
-- 4. [SESI B]
UPDATE lab9.dokter_jaga SET aktif = false WHERE dokter_id = 2;
-- Jika UPDATE gagal dengan 40001, jalankan ROLLBACK di Sesi B dan jangan
-- lanjutkan COMMIT. Jika UPDATE berhasil, jalankan COMMIT; bila COMMIT gagal,
-- jalankan ROLLBACK. Catat tahap dan SQLSTATE yang benar-benar terjadi.
-- 5. Setelah transaksi kedua selesai/di-ROLLBACK, jalankan di sesi bersih:
SELECT * FROM lab9.dokter_jaga ORDER BY dokter_id;

-- =====================================================================
-- Q28 - Lihat SIReadLock
-- =====================================================================
-- [SESI A]
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) FROM lab9.dokter_jaga WHERE aktif;
-- [SESI A, sebelum COMMIT]
SELECT locktype, relation::regclass AS tabel, mode, granted
FROM pg_locks WHERE mode = 'SIReadLock';
ROLLBACK;

-- =====================================================================
-- Q29 (pseudocode retry) -> ada di laporan
-- =====================================================================

-- =====================================================================
-- CLEANUP (kembalikan ke kondisi awal)
-- =====================================================================
UPDATE lab9.rekening SET saldo = 1000000 WHERE rekening_id IN (1,2);
DROP TABLE IF EXISTS lab9.antrean;
DROP TABLE IF EXISTS lab9.dokter_jaga;
SELECT * FROM lab9.rekening ORDER BY rekening_id;
