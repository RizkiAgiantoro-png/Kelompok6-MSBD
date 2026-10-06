-- Q29 - Daftar seluruh index pada lab6.event_log

SELECT
    i.schemaname,
    i.relname AS table_name,
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
    i.idx_scan ASC,
    i.indexrelname ASC;