-- Diminta: Menampilkan tiga film dengan tarif tertinggi pada setiap kategori.
-- Dipilih: Window function di CTE lalu filter pada query luar karena hasil window belum tersedia di WHERE yang sama.
-- Alternatif: Subquery berkorelasi; tidak dipilih karena window lebih langsung untuk mengambil beberapa peringkat.

WITH peringkat_film AS (
    SELECT c.name AS kategori,
           f.title,
           f.rental_rate,
           ROW_NUMBER() OVER (
               PARTITION BY c.category_id
               ORDER BY f.rental_rate DESC, f.film_id
           ) AS nomor_baris
    FROM film f
    JOIN film_category fc ON fc.film_id = f.film_id
    JOIN category c ON c.category_id = fc.category_id
)
SELECT kategori, title, rental_rate, nomor_baris
FROM peringkat_film
WHERE nomor_baris <= 3
ORDER BY kategori, nomor_baris, title;