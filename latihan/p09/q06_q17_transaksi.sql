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
