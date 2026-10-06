-- Q27 - Harga Tulis Index
-- Benchmark INSERT 200.000 baris
-- Lima index benchmark:
-- 1. Composite B-Tree
-- 2. Partial index
-- 3. Expression index
-- 4. Covering index
-- 5. GIN JSONB

DROP TABLE IF EXISTS lab6.q27_noidx CASCADE;
DROP TABLE IF EXISTS lab6.q27_fiveidx CASCADE;

-- =========================================================
-- 1. TABEL TANPA INDEX
-- =========================================================

CREATE TABLE lab6.q27_noidx AS
SELECT *
FROM lab6.event_log
WITH NO DATA;

-- =========================================================
-- 2. TABEL DENGAN LIMA INDEX
-- =========================================================

CREATE TABLE lab6.q27_fiveidx AS
SELECT *
FROM lab6.event_log
WITH NO DATA;

CREATE INDEX q27_customer_time_idx
ON lab6.q27_fiveidx (customer_id, terjadi_pada DESC);

CREATE INDEX q27_gagal_idx
ON lab6.q27_fiveidx (terjadi_pada DESC)
WHERE status = 'GAGAL';

CREATE INDEX q27_email_lower_idx
ON lab6.q27_fiveidx (lower(email));

CREATE INDEX q27_cover_idx
ON lab6.q27_fiveidx (customer_id)
INCLUDE (terjadi_pada, jumlah);

CREATE INDEX q27_payload_gin_idx
ON lab6.q27_fiveidx
USING gin (payload jsonb_path_ops);

-- =========================================================
-- 3. SUMBER DATA 200.000 BARIS
-- =========================================================

CREATE TEMP TABLE q27_data AS
SELECT
    g::bigint AS event_id,
    (random() * 59999)::int + 1 AS customer_id,
    timestamptz '2024-01-01 00:00+07'
        + (g * interval '13 second') AS terjadi_pada,

    CASE
        WHEN g % 50 = 0 THEN 'GAGAL'
        WHEN g % 7 = 0 THEN 'TERTUNDA'
        ELSE 'SUKSES'
    END AS status,

    w.nama AS wilayah,

    w.nama || '-' || ((g % 9) + 1) AS kota,

    'user' || g || '@contoh.ac.id' AS email,

    md5(g::text || '-q27')::uuid AS idempotency_key,

    round((random() * 900 + 10)::numeric, 2) AS jumlah,

    ARRAY[
        'kanal:' || (g % 4),
        'sumber:' || (g % 3)
    ]::text[] AS tags,

    jsonb_build_object(
        'kanal', g % 4,
        'perangkat', g % 6,
        'promo', (g % 25 = 0)
    ) AS payload

FROM generate_series(2000001, 2200000) AS s(g)

CROSS JOIN LATERAL (
    SELECT
        (ARRAY[
            'SUMUT',
            'JABAR',
            'JATIM',
            'BALI',
            'PAPUA'
        ])[(g % 5) + 1] AS nama
) AS w;

SELECT count(*) AS jumlah_data_benchmark
FROM q27_data;

-- =========================================================
-- 4. SETTING PENGUKURAN
-- =========================================================

\timing on

SET max_parallel_workers_per_gather = 0;

-- =========================================================
-- 5. TANPA INDEX - UJI 1
-- =========================================================

TRUNCATE lab6.q27_noidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_noidx
SELECT *
FROM q27_data;

-- =========================================================
-- 6. TANPA INDEX - UJI 2
-- =========================================================

TRUNCATE lab6.q27_noidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_noidx
SELECT *
FROM q27_data;

-- =========================================================
-- 7. TANPA INDEX - UJI 3
-- =========================================================

TRUNCATE lab6.q27_noidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_noidx
SELECT *
FROM q27_data;

-- =========================================================
-- 8. DENGAN LIMA INDEX - UJI 1
-- =========================================================

TRUNCATE lab6.q27_fiveidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_fiveidx
SELECT *
FROM q27_data;

-- =========================================================
-- 9. DENGAN LIMA INDEX - UJI 2
-- =========================================================

TRUNCATE lab6.q27_fiveidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_fiveidx
SELECT *
FROM q27_data;

-- =========================================================
-- 10. DENGAN LIMA INDEX - UJI 3
-- =========================================================

TRUNCATE lab6.q27_fiveidx;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO lab6.q27_fiveidx
SELECT *
FROM q27_data;