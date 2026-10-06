-- Diminta: Menghitung fraksi tiap status dan menguji titik peralihan index scan ke seq scan dengan dan tanpa random_page_cost=1.1.
-- Dipilih: Menguji status TERTUNDA (~14% fraksi data) untuk mengamati ambang batas pilihan optimizer.
-- Alternatif: Menguji hanya nilai ekstrem.

SET max_parallel_workers_per_gather = 0;

-- 1. Hitung Fraksi Tiap Status
SELECT 
    status, 
    count(*) AS jumlah_baris,
    round(count(*) * 100.0 / sum(count(*)) OVER (), 2) AS persentase
FROM lab6.event_log
GROUP BY status;

-- 2. Status TERTUNDA (Fraksi ~14%) dengan random_page_cost Default (4.0)
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE status = 'TERTUNDA';

-- 3. Q24: Status TERTUNDA dengan random_page_cost = 1.1 (Biaya Halaman Acak Diturunkan)
SET random_page_cost = 1.1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE status = 'TERTUNDA';

RESET random_page_cost;
