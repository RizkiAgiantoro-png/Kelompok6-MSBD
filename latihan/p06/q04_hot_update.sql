-- Q4: Buat tabel hot_penuh (fillfactor 100) dan hot_longgar (fillfactor 80),
--     update kolom catatan yang tidak terindeks, lalu bandingkan n_tup_hot_upd.

DROP TABLE IF EXISTS lab6.hot_penuh, lab6.hot_longgar CASCADE;

CREATE TABLE lab6.hot_penuh (
    id int PRIMARY KEY,
    kode int NOT NULL,
    catatan text NOT NULL
) WITH (fillfactor = 100);

CREATE TABLE lab6.hot_longgar (
    id int PRIMARY KEY,
    kode int NOT NULL,
    catatan text NOT NULL
) WITH (fillfactor = 80);

CREATE INDEX idx_hot_penuh_kode ON lab6.hot_penuh(kode);
CREATE INDEX idx_hot_longgar_kode ON lab6.hot_longgar(kode);

INSERT INTO lab6.hot_penuh
SELECT g, g % 1000, 'catatan-awal-' || repeat('x', 80)
FROM generate_series(1, 50000) AS g;

INSERT INTO lab6.hot_longgar
SELECT g, g % 1000, 'catatan-awal-' || repeat('x', 80)
FROM generate_series(1, 50000) AS g;

-- Simpan ukuran awal sebelum UPDATE untuk pembanding di Q5
SELECT 
    pg_size_pretty(pg_relation_size('lab6.hot_penuh')) AS heap_penuh_sebelum,
    pg_size_pretty(pg_relation_size('lab6.hot_longgar')) AS heap_longgar_sebelum;

-- Update kolom catatan yang tidak terindeks
UPDATE lab6.hot_penuh SET catatan = 'catatan-baru-' || repeat('y', 80);
UPDATE lab6.hot_longgar SET catatan = 'catatan-baru-' || repeat('y', 80);

SELECT pg_sleep(0.5);
ANALYZE lab6.hot_penuh;
ANALYZE lab6.hot_longgar;

-- Bandingkan n_tup_hot_upd
SELECT 
    relname AS nama_tabel,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE schemaname = 'lab6'
  AND relname IN ('hot_penuh', 'hot_longgar')
ORDER BY relname;