-- Q30 - Data pendukung rekomendasi index
-- Jangan DROP INDEX di file ini.
-- Keputusan final ditulis di laporan berdasarkan hasil Q7-Q29.

SELECT
    i.indexrelname AS index_name,
    i.idx_scan,
    i.idx_tup_read,
    i.idx_tup_fetch,
    pg_relation_size(i.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    p.indexdef
FROM pg_stat_user_indexes AS i
JOIN pg_indexes AS p
    ON p.schemaname = i.schemaname
   AND p.tablename = i.relname
   AND p.indexname = i.indexrelname
WHERE i.schemaname = 'lab6'
  AND i.relname = 'event_log'
ORDER BY
    pg_relation_size(i.indexrelid) DESC;

-- Ukuran total event_log
SELECT
    pg_size_pretty(pg_table_size('lab6.event_log')) AS table_size,
    pg_size_pretty(pg_indexes_size('lab6.event_log')) AS indexes_size,
    pg_size_pretty(pg_total_relation_size('lab6.event_log')) AS total_size;