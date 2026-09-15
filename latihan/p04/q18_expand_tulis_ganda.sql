-- Diminta: menyiapkan struktur baru harga_film dan menjaga sinkronisasi harga lama ke bentuk baru.
-- Dipilih: membuat tabel harga_film dengan EXCLUDE dan trigger AFTER UPDATE OF rental_rate
-- agar perubahan pada bentuk lama tetap tercermin ke bentuk baru saat aplikasi lama masih berjalan.
-- Alternatif: mengubah aplikasi langsung ke bentuk baru sebelum memastikan pembaca lama aman; tidak dipilih
-- karena akan memutus kompatibilitas aplikasi lama pada tahap expand.

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS lab4.harga_film (
    harga_film_id bigserial PRIMARY KEY,
    film_id integer NOT NULL REFERENCES lab4.film (film_id),
    wilayah text NOT NULL,
    harga numeric(5,2) NOT NULL CHECK (harga >= 0),
    berlaku daterange NOT NULL,
    EXCLUDE USING gist (
        film_id WITH =,
        wilayah WITH =,
        berlaku WITH &&
    )
);

CREATE OR REPLACE FUNCTION lab4.sinkron_harga_film()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
    SELECT
        NEW.film_id,
        'ID',
        NEW.rental_rate,
        daterange(CURRENT_DATE, NULL)
    WHERE NOT EXISTS (
        SELECT 1
        FROM lab4.harga_film h
        WHERE h.film_id = NEW.film_id
          AND h.wilayah = 'ID'
          AND h.berlaku @> CURRENT_DATE
    );

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS film_dual_write ON lab4.film;

CREATE TRIGGER film_dual_write
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.sinkron_harga_film();

INSERT INTO lab4.harga_film (film_id, wilayah, harga, berlaku)
SELECT
    f.film_id,
    'ID',
    f.rental_rate,
    daterange('2026-01-01', NULL)
FROM lab4.film f
WHERE f.film_id = 1
  AND NOT EXISTS (
      SELECT 1
      FROM lab4.harga_film h
      WHERE h.film_id = f.film_id
        AND h.wilayah = 'ID'
  );

SELECT title, rental_rate
FROM lab4.film
LIMIT 5;
