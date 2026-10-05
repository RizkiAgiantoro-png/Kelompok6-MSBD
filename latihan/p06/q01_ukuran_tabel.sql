-- Q1: Catat ukuran total tabel dan hitung rata-rata byte per baris
SELECT 
    count(*) AS jumlah_baris,
    pg_size_pretty(pg_total_relation_size('lab6.event_log')) AS ukuran_total,
    pg_total_relation_size('lab6.event_log') AS ukuran_total_bytes,
    pg_size_pretty(pg_relation_size('lab6.event_log')) AS ukuran_heap,
    pg_relation_size('lab6.event_log') AS ukuran_heap_bytes,
    pg_size_pretty(pg_indexes_size('lab6.event_log')) AS ukuran_index,
    round(pg_total_relation_size('lab6.event_log')::numeric / count(*), 2) AS rata_byte_per_baris_total,
    round(pg_relation_size('lab6.event_log')::numeric / count(*), 2) AS rata_byte_per_baris_heap
FROM lab6.event_log;
