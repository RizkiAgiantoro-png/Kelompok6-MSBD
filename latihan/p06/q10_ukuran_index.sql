DROP INDEX IF EXISTS lab6.ev_salah_idx;
DROP INDEX IF EXISTS lab6.ev_benar_idx;

CREATE INDEX ev_salah_idx
ON lab6.event_log (terjadi_pada, customer_id);

CREATE INDEX ev_benar_idx
ON lab6.event_log (customer_id, terjadi_pada DESC);

ANALYZE lab6.event_log;

SELECT
    indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(indexrelid)) AS ukuran,
    pg_relation_size(indexrelid) AS ukuran_bytes,
    idx_scan
FROM pg_stat_user_indexes
WHERE schemaname = 'lab6'
  AND indexrelname IN ('ev_salah_idx', 'ev_benar_idx')
ORDER BY indexrelname;