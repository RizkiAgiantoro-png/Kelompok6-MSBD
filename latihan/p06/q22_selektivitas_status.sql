-- Diminta: Membandingkan rencana eksekusi status SUKSES (~84%) dan GAGAL (~2%).
-- Dipilih: Mengamati peralihan dari Seq Scan ke Bitmap Index Scan berdasarkan selektivitas nilai.
-- Alternatif: Memaksa index scan untuk semua nilai.

SET max_parallel_workers_per_gather = 0;

-- 1. Status SUKSES (Fraksi Mayoritas ~84%)
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE status = 'SUKSES';

-- 2. Status GAGAL (Fraksi Minoritas ~2%)
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE status = 'GAGAL';
