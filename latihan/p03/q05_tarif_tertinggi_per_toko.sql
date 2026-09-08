-- Diminta: Menampilkan judul film dengan tarif sewa tertinggi di setiap toko tanpa window function.
-- Dipilih: Subquery berkorelasi menggunakan MAX karena nilai agregat perlu dibandingkan secara spesifik untuk setiap toko di luar.
-- Alternatif: Window Function (ROW_NUMBER); tidak dipilih karena soal melarang window function agar bisa dibandingkan dengan Q11.

SELECT DISTINCT i.store_id, f.title, f.rental_rate
FROM inventory i
JOIN film f ON f.film_id = i.film_id
WHERE f.rental_rate = (
    SELECT MAX(f2.rental_rate)
    FROM inventory i2
    JOIN film f2 ON f2.film_id = i2.film_id
    WHERE i2.store_id = i.store_id
)
ORDER BY i.store_id, f.title;