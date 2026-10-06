-- Diminta: Menguji query rentang 7 hari membandingkan BRIN index dan B-Tree index.
-- Dipilih: Mengukur waktu eksekusi dan Buffers yang dibaca oleh kedua jenis index.
-- Alternatif: Menggunakan Sequential scan.

SET max_parallel_workers_per_gather = 0;

-- 1. Pengujian dengan BRIN Index (matikan btree scan sementara)
SET enable_indexscan = off;
SET enable_bitmapscan = on;

EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE terjadi_pada BETWEEN '2024-03-01 00:00+07' AND '2024-03-08 00:00+07';

RESET enable_indexscan;

-- 2. Pengujian dengan B-Tree Index (matikan brin scan dengan men-drop brin / forcing btree)
EXPLAIN (ANALYZE, BUFFERS)
SELECT /*+ IndexScan(event_log ev_terjadi_pada_btree_idx) */ event_id 
FROM lab6.event_log 
WHERE terjadi_pada BETWEEN '2024-03-01 00:00+07' AND '2024-03-08 00:00+07';
