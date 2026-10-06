-- Q28 - Ukuran total tabel setelah INSERT 200.000 baris

SELECT
    'Tanpa index' AS kondisi,
    pg_size_pretty(pg_table_size('lab6.q27_noidx')) AS table_size,
    pg_size_pretty(pg_indexes_size('lab6.q27_noidx')) AS index_size,
    pg_size_pretty(pg_total_relation_size('lab6.q27_noidx')) AS total_size,

    pg_table_size('lab6.q27_noidx') AS table_bytes,
    pg_indexes_size('lab6.q27_noidx') AS index_bytes,
    pg_total_relation_size('lab6.q27_noidx') AS total_bytes

UNION ALL

SELECT
    'Dengan lima index' AS kondisi,
    pg_size_pretty(pg_table_size('lab6.q27_fiveidx')) AS table_size,
    pg_size_pretty(pg_indexes_size('lab6.q27_fiveidx')) AS index_size,
    pg_size_pretty(pg_total_relation_size('lab6.q27_fiveidx')) AS total_size,

    pg_table_size('lab6.q27_fiveidx') AS table_bytes,
    pg_indexes_size('lab6.q27_fiveidx') AS index_bytes,
    pg_total_relation_size('lab6.q27_fiveidx') AS total_bytes;

-- Selisih ukuran total

SELECT
    pg_size_pretty(
        pg_total_relation_size('lab6.q27_fiveidx')
        - pg_total_relation_size('lab6.q27_noidx')
    ) AS tambahan_ukuran,

    round(
        (
            (
                pg_total_relation_size('lab6.q27_fiveidx')
                - pg_total_relation_size('lab6.q27_noidx')
            )::numeric
            /
            pg_total_relation_size('lab6.q27_noidx')
        ) * 100,
        2
    ) AS persen_kenaikan_ukuran;

-- =========================================================
-- CLEANUP BENCHMARK
-- =========================================================

DROP TABLE lab6.q27_noidx;
DROP TABLE lab6.q27_fiveidx;