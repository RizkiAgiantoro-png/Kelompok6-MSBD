-- Q5: Bandingkan ukuran kedua tabel (hot_penuh dan hot_longgar) setelah UPDATE
SELECT 
    relname AS nama_tabel,
    pg_size_pretty(pg_relation_size(relid)) AS ukuran_heap_sesudah,
    pg_relation_size(relid) AS bytes_heap_sesudah,
    pg_size_pretty(pg_indexes_size(relid)) AS ukuran_index_sesudah,
    pg_size_pretty(pg_total_relation_size(relid)) AS ukuran_total_sesudah,
    pg_total_relation_size(relid) AS bytes_total_sesudah
FROM pg_stat_user_tables
WHERE schemaname = 'lab6'
  AND relname IN ('hot_penuh', 'hot_longgar')
ORDER BY relname;