-- Migration 0044
-- Verifikasi kelengkapan migrasi harga film.
-- Target: belum_ter_migrasi = 0.

SELECT count(*) AS belum_ter_migrasi
FROM lab4.film f
WHERE NOT EXISTS (
    SELECT 1
    FROM lab4.harga_film h
    WHERE h.film_id = f.film_id
    AND h.wilayah = 'ID'
);