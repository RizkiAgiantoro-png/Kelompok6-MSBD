-- Migration 0045
-- Membuat view facade agar struktur lama tetap dapat digunakan.

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