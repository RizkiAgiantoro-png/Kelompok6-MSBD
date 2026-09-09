-- Diminta: Menghasilkan detail kategori-rating, subtotal kategori, dan grand total dalam satu hasil.
-- Dipilih: ROLLUP dan GROUPING() karena seluruh tingkat agregasi dihasilkan dalam satu query.
-- Alternatif: UNION ALL beberapa GROUP BY; tidak dipilih karena mengulang logika agregasi.

SELECT CASE WHEN GROUPING(c.name) = 1 THEN 'SEMUA' ELSE c.name END AS kategori,
       CASE WHEN GROUPING(f.rating) = 1 THEN 'SEMUA' ELSE f.rating::text END AS rating,
       COUNT(*) AS jumlah_film,
       ROUND(AVG(f.rental_rate), 2) AS rata_rata_tarif,
       GROUPING(c.name) AS grouping_kategori,
       GROUPING(f.rating) AS grouping_rating
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY ROLLUP (c.name, f.rating)
ORDER BY GROUPING(c.name), c.name, GROUPING(f.rating), f.rating;