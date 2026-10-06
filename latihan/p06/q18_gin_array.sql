-- Diminta: Menguji query keanggotaan tags @> ARRAY['kanal:1'] dengan dan tanpa GIN index.
-- Dipilih: GIN index pada kolom array untuk mempercepat query containment @>.
-- Alternatif: Sequential scan tanpa GIN index.

SET max_parallel_workers_per_gather = 0;

-- 1. Dengan GIN Index
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE tags @> ARRAY['kanal:1'];

-- 2. Tanpa Index (SET enable_indexscan = off, enable_bitmapscan = off)
SET enable_indexscan = off;
SET enable_bitmapscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT event_id 
FROM lab6.event_log 
WHERE tags @> ARRAY['kanal:1'];

RESET enable_indexscan;
RESET enable_bitmapscan;
