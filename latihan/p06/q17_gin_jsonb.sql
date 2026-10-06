-- Diminta: Menguji query payload @> '{"promo": true}' dengan GIN index (jsonb_path_ops) dan mengukur ukurannya dibanding heap.
-- Dipilih: GIN dengan operator jsonb_path_ops untuk penghematan ukuran index pada query containment @>.
-- Alternatif: GIN default (jsonb_ops); tidak dipilih karena lebih besar untuk query jsonb sederhana.

SELECT 
    pg_size_pretty(pg_relation_size('lab6.event_log')) AS heap_size,
    pg_size_pretty(pg_relation_size('lab6.ev_payload_gin_idx')) AS gin_jsonb_size;

SET max_parallel_workers_per_gather = 0;

EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE payload @> '{"promo": true}';
