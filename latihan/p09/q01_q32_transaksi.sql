-- LATIHAN P09: Q1-Q32
-- Jalankan per blok sesuai nomor dan label SESI A/B; JANGAN jalankan seluruh file sekaligus.
-- Jalankan q00_setup.sql terlebih dahulu pada database lab.
-- Q31-Q32 bersifat analisis; jawabannya ada di laporan.md.


-- ==================== SUMBER BAGIAN: q01_q05_transaksi.sql ====================

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


-- ==================== SUMBER BAGIAN: q06_q17_transaksi.sql ====================

-- Q6-Q17: isolation, anomali, dan MVCC.
-- Jalankan per bagian pada database lab9; jangan jalankan seluruh file sekaligus.
-- Untuk langkah dua sesi, lakukan perintah sesuai label dan urutan.

-- Q6 - READ COMMITTED: non-repeatable read
-- SESI A
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
-- SESI B
UPDATE lab9.rekening SET saldo = 900000 WHERE rekening_id = 1;
COMMIT;
-- SESI A
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;

-- Q7 - REPEATABLE READ: pembacaan tetap pada snapshot transaksi
-- Persiapkan rekening 1 ke 1000000, lalu jalankan:
-- SESI A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
-- SESI B
UPDATE lab9.rekening SET saldo = 800000 WHERE rekening_id = 1;
COMMIT;
-- SESI A
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;

-- Q8 - Phantom read
CREATE TABLE IF NOT EXISTS lab9.eksperimen (nilai INT NOT NULL);
TRUNCATE lab9.eksperimen;
INSERT INTO lab9.eksperimen (nilai) VALUES (10), (20);
-- READ COMMITTED:
-- SESI A
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT count(*) FROM lab9.eksperimen WHERE nilai > 15;
-- SESI B
INSERT INTO lab9.eksperimen (nilai) VALUES (30);
COMMIT;
-- SESI A
SELECT count(*) FROM lab9.eksperimen WHERE nilai > 15;
COMMIT;
-- Ulangi setelah reset data (TRUNCATE lalu isi 10,20) dengan REPEATABLE READ.
-- Contoh urutan REPEATABLE READ:
TRUNCATE lab9.eksperimen;
INSERT INTO lab9.eksperimen (nilai) VALUES (10), (20);
-- SESI A
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM lab9.eksperimen WHERE nilai > 15;
-- SESI B
INSERT INTO lab9.eksperimen (nilai) VALUES (40);
COMMIT;
-- SESI A
SELECT count(*) FROM lab9.eksperimen WHERE nilai > 15;
COMMIT;

-- Q9 - READ UNCOMMITTED PostgreSQL
-- SESI A
BEGIN;
UPDATE lab9.rekening SET saldo = 50000 WHERE rekening_id = 1;
-- Jangan commit dulu.
-- SESI B
BEGIN ISOLATION LEVEL READ UNCOMMITTED;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
COMMIT;
-- SESI A
ROLLBACK;

-- Q10 - Lost update dengan nilai absolut yang dihitung aplikasi
-- Persiapkan rekening 2 ke 1000000.
-- SESI A
BEGIN;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 2;
-- SESI B
BEGIN;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 2;
-- Aplikasi menghitung A=900000 dan B=950000 dari nilai awal 1000000.
-- SESI A
UPDATE lab9.rekening SET saldo = 900000 WHERE rekening_id = 2;
COMMIT;
-- SESI B
UPDATE lab9.rekening SET saldo = 950000 WHERE rekening_id = 2;
COMMIT;
SELECT saldo FROM lab9.rekening WHERE rekening_id = 2;

-- Q12 - Atomic update untuk mencegah lost update
UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo >= 10000;
-- Jalankan dua sesi dengan transaksi terpisah; pastikan keduanya mengurangi
-- nilai, bukan menulis saldo absolut yang dihitung dari pembacaan lama.

-- Q13 - SELECT FOR UPDATE
-- SESI A
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- SESI B: perintah berikut menunggu sampai A menyelesaikan transaksi.
BEGIN;
SELECT * FROM lab9.rekening WHERE rekening_id = 1 FOR UPDATE;
-- SESI A
COMMIT;
-- SESI B: setelah SELECT selesai
COMMIT;

-- Q14 - Optimistic locking memakai nilai saldo yang dibaca
-- Ganti 1000000 dengan nilai aktual yang dibaca aplikasi sebelumnya.
UPDATE lab9.rekening
SET saldo = saldo - 10000
WHERE rekening_id = 1 AND saldo = 1000000;
-- Periksa tag UPDATE n: UPDATE 0 berarti nilai lama sudah berubah (stale).

-- Q15 - MVCC: SELECT biasa tidak menunggu UPDATE yang belum commit
-- SESI A
BEGIN;
UPDATE lab9.rekening SET saldo = saldo - 10000 WHERE rekening_id = 1;
-- SESI B (saat A belum commit)
SELECT saldo FROM lab9.rekening WHERE rekening_id = 1;
-- Sesi B membaca versi committed sebelumnya.
-- SESI A
ROLLBACK;

-- Q16 - Metadata tupel PostgreSQL
SELECT rekening_id, saldo, xmin, xmax
FROM lab9.rekening
WHERE rekening_id = 1;
-- xmin/xmax adalah metadata transaksi; interpretasikan bersama status transaksi
-- dan aturan visibilitas, bukan sebagai status committed yang berdiri sendiri.

-- Q17 - Vacuum dan statistik tabel lab
SELECT relname, n_live_tup, n_dead_tup, last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE schemaname = 'lab9';
-- VACUUM hanya setelah seluruh transaksi eksperimen selesai; bukan dalam transaksi.
VACUUM (VERBOSE, ANALYZE) lab9.rekening;


-- ==================== SUMBER BAGIAN: q18_q29_langkah4_5.sql ====================

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


-- ==================== SUMBER BAGIAN: q30_read_skew.sql ====================

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

