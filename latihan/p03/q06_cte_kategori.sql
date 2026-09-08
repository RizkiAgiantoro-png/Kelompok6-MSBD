-- Diminta: Menulis ulang Q2 memakai CTE, lalu menambahkan CTE kedua untuk menghitung rata-rata tarif sewa per kategori.
-- Dipilih: Dua CTE berurutan; CTE pertama memfilter jumlah film, CTE kedua menghitung rata-rata, lalu digabungkan di query utama.
-- Alternatif: Subquery di FROM (Derived table); tidak dipilih karena CTE membuat query kompleks lebih sekuensial dan mudah dibaca.

WITH kategori_lebih_60 AS (
    SELECT c.category_id, c.name AS kategori, COUNT(*) AS jumlah_film
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
    HAVING COUNT(*) > 60
),
rata_tarif_kategori AS (
    SELECT fc.category_id, AVG(f.rental_rate) AS rata_rata_tarif
    FROM film_category fc
    JOIN film f ON f.film_id = fc.film_id
    GROUP BY fc.category_id
)
SELECT k.kategori, k.jumlah_film, r.rata_rata_tarif
FROM kategori_lebih_60 k
JOIN rata_tarif_kategori r ON k.category_id = r.category_id
ORDER BY k.jumlah_film DESC, k.kategori;