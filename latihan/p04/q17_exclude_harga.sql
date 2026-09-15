-- Request:
-- Mencegah periode harga film yang saling tumpang tindih
-- untuk film dan wilayah yang sama.
--
-- Bentuk query yang dipilih:
-- EXCLUDE USING gist dengan kombinasi film_id, wilayah,
-- dan range tanggal berlaku.
-- Bentuk ini dipilih karena PostgreSQL dapat langsung menjaga
-- aturan bahwa dua periode tidak boleh overlap.
--
-- Alternatif yang tidak dipilih:
-- Mengecek overlap menggunakan SELECT terlebih dahulu
-- kemudian INSERT.
-- Cara tersebut dapat mengalami race condition ketika dua transaksi
-- berjalan bersamaan.

CREATE EXTENSION IF NOT EXISTS btree_gist;

DROP TABLE IF EXISTS lab4.harga_film;

CREATE TABLE lab4.harga_film (
    harga_id BIGSERIAL PRIMARY KEY,
    film_id INT NOT NULL,
    wilayah TEXT NOT NULL,
    harga NUMERIC(10,2) NOT NULL,
    berlaku DATERANGE NOT NULL,

    CONSTRAINT harga_film_no_overlap
    EXCLUDE USING gist (
        film_id WITH =,
        wilayah WITH =,
        berlaku WITH &&
    )
);

INSERT INTO lab4.harga_film
    (film_id, wilayah, harga, berlaku)
VALUES
    (1, 'ID', 25000, '[2026-01-01,2026-02-01)');

INSERT INTO lab4.harga_film
    (film_id, wilayah, harga, berlaku)
VALUES
    (1, 'ID', 27000, '[2026-02-01,2026-03-01)');

INSERT INTO lab4.harga_film
    (film_id, wilayah, harga, berlaku)
VALUES
    (1, 'ID', 30000, '[2026-01-15,2026-02-15)');