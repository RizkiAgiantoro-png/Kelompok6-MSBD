-- Diminta: Menguji estimasi baris sebelum dan sesudah extended statistics pada wilayah-kota.
-- Dipilih: CREATE STATISTICS (dependencies, ndistinct) ON wilayah, kota untuk memperbaiki estimasi relasi antar kolom.
-- Alternatif: Mengandalkan statistik single-column default.

SET max_parallel_workers_per_gather = 0;

-- 1. Estimasi Sebelum Extended Statistics
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM lab6.event_log 
WHERE wilayah = 'SUMUT' AND kota = 'SUMUT-1';

-- 2. Buat Extended Statistics (dependencies, ndistinct)
CREATE STATISTICS IF NOT EXISTS ev_wil_kota_stat (dependencies, ndistinct) 
ON wilayah, kota FROM lab6.event_log;

ANALYZE lab6.event_log;

-- 3. Estimasi Sesudah Extended Statistics
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) 
FROM lab6.event_log 
WHERE wilayah = 'SUMUT' AND kota = 'SUMUT-1';
