-- Diminta: menerapkan fase contract, mengamankan pembaca lama, lalu menghapus kolom lama.
-- Dipilih: membuat view fasad terlebih dahulu, kemudian menonaktifkan dual-write, lalu DROP COLUMN rental_rate.
-- Alternatif: langsung menghapus rental_rate sebelum view fasad dibuat; tidak dipilih karena akan memutus aplikasi lama.

CREATE OR REPLACE VIEW lab4.film_lama AS
SELECT
    f.film_id,
    f.title,
    h.harga AS rental_rate,
    f.rating
FROM lab4.film f
LEFT JOIN lab4.harga_film h
    ON h.film_id = f.film_id
   AND h.wilayah = 'ID'
   AND h.berlaku @> CURRENT_DATE;

DROP TRIGGER IF EXISTS film_dual_write ON lab4.film;

SELECT title, rental_rate
FROM lab4.film
LIMIT 5;

ALTER TABLE lab4.film
DROP COLUMN rental_rate;
