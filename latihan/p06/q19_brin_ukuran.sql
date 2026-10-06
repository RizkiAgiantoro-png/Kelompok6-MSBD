-- Diminta: Memeriksa korelasi kolom terjadi_pada dan membandingkan ukuran BRIN index vs B-Tree index.
-- Dipilih: BRIN index untuk data berurutan fisik tinggi (correlation mendekati 1.0).
-- Alternatif: B-Tree index yang memerlukan memori jauh lebih besar.

-- 1. Korelasi Fisik di pg_stats
SELECT tablename, attname, correlation 
FROM pg_stats 
WHERE tablename = 'event_log' AND attname = 'terjadi_pada';

-- 2. Perbandingan Ukuran BRIN vs B-Tree
SELECT 
    pg_size_pretty(pg_relation_size('lab6.ev_terjadi_pada_brin_idx')) AS ukuran_brin,
    pg_size_pretty(pg_relation_size('lab6.ev_terjadi_pada_btree_idx')) AS ukuran_btree;
