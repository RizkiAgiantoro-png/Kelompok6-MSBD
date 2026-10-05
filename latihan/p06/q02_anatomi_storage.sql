-- Q2: Tuple per halaman
WITH tuple_per_page AS (
    SELECT (ctid::text::point)[0]::bigint AS nomor_halaman,
           count(*) AS jumlah_tuple
    FROM lab6.event_log
    GROUP BY 1
)
SELECT 
    count(*) AS total_halaman,
    min(jumlah_tuple) AS min_tuple_per_halaman,
    round(avg(jumlah_tuple), 2) AS rata_tuple_per_halaman,
    max(jumlah_tuple) AS max_tuple_per_halaman,
    291 AS batas_teoretis_tuple
FROM tuple_per_page;

-- Q3: TOAST storage
SELECT 
    attnum AS no_kolom,
    attname AS nama_kolom,
    format_type(atttypid, atttypmod) AS tipe_data,
    attstorage
FROM pg_attribute
WHERE attrelid = 'lab6.event_log'::regclass
  AND attnum > 0
  AND NOT attisdropped
ORDER BY attnum;

-- Q4 dan Q5: HOT update dan fillfactor
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

SELECT 
    pg_size_pretty(pg_relation_size('lab6.hot_penuh')) AS heap_penuh_sebelum,
    pg_size_pretty(pg_relation_size('lab6.hot_longgar')) AS heap_longgar_sebelum;

UPDATE lab6.hot_penuh SET catatan = 'catatan-baru-' || repeat('y', 80);
UPDATE lab6.hot_longgar SET catatan = 'catatan-baru-' || repeat('y', 80);

SELECT pg_sleep(0.5);
ANALYZE lab6.hot_penuh;
ANALYZE lab6.hot_longgar;

SELECT 
    relname AS nama_tabel,
    n_tup_upd,
    n_tup_hot_upd,
    pg_size_pretty(pg_relation_size(relid)) AS ukuran_heap_sesudah,
    pg_relation_size(relid) AS bytes_heap_sesudah,
    pg_size_pretty(pg_indexes_size(relid)) AS ukuran_index_sesudah,
    pg_size_pretty(pg_total_relation_size(relid)) AS ukuran_total_sesudah,
    pg_total_relation_size(relid) AS bytes_total_sesudah
FROM pg_stat_user_tables
WHERE schemaname = 'lab6'
  AND relname IN ('hot_penuh', 'hot_longgar')
ORDER BY relname;

-- Q6: Update kolom terindeks vs tidak terindeks
DROP TABLE IF EXISTS lab6.hot_uji_indeks CASCADE;

CREATE TABLE lab6.hot_uji_indeks (
    id int PRIMARY KEY,
    kode int NOT NULL,
    catatan text NOT NULL
) WITH (fillfactor = 80);

CREATE INDEX idx_hot_uji_kode ON lab6.hot_uji_indeks(kode);

INSERT INTO lab6.hot_uji_indeks
SELECT g, g % 1000, 'catatan-awal-' || repeat('x', 80)
FROM generate_series(1, 50000) AS g;

UPDATE lab6.hot_uji_indeks SET kode = kode + 1;

SELECT pg_sleep(0.5);
ANALYZE lab6.hot_uji_indeks;

SELECT 
    relname AS nama_tabel,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE schemaname = 'lab6'
  AND relname IN ('hot_longgar', 'hot_uji_indeks')
ORDER BY relname;