-- Q6: Bandingkan UPDATE kolom terindeks (kode) dan tidak terindeks (catatan)
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

-- Update kolom kode yang TERINDEKS (meskipun fillfactor = 80)
UPDATE lab6.hot_uji_indeks SET kode = kode + 1;

SELECT pg_sleep(0.5);
ANALYZE lab6.hot_uji_indeks;

-- Bandingkan hasilnya dengan hot_longgar (yang meng-update kolom tidak terindeks)
SELECT 
    relname AS nama_tabel,
    n_tup_upd,
    n_tup_hot_upd
FROM pg_stat_user_tables
WHERE schemaname = 'lab6'
  AND relname IN ('hot_longgar', 'hot_uji_indeks')
ORDER BY relname;