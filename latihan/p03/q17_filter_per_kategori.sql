-- Diminta: Menampilkan agregat film total, rating tertentu, dan rata-rata durasi di atas 90 menit per kategori.
-- Dipilih: FILTER dan CASE WHEN ditampilkan berdampingan agar hasil dan perilakunya dapat dibandingkan.
-- Alternatif: Beberapa subquery agregat; tidak dipilih karena lebih panjang dan mengulang pemindaian data.

SELECT c.name AS kategori,
       COUNT(*) AS jumlah_film,
       COUNT(*) FILTER (WHERE f.rating = 'G') AS jumlah_rating_g_filter,
       COUNT(*) FILTER (WHERE f.rating = 'PG-13') AS jumlah_rating_pg13_filter,
       ROUND(AVG(f.length) FILTER (WHERE f.length > 90), 2) AS rata_durasi_di_atas_90_filter,
       COUNT(CASE WHEN f.rating = 'G' THEN 1 END) AS jumlah_rating_g_case,
       COUNT(CASE WHEN f.rating = 'PG-13' THEN 1 END) AS jumlah_rating_pg13_case,
       ROUND(AVG(CASE WHEN f.length > 90 THEN f.length END), 2) AS rata_durasi_di_atas_90_case
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
ORDER BY c.name;