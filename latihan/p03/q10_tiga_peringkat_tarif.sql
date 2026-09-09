-- Diminta: Menampilkan tiga jenis peringkat tarif film di dalam kategorinya.
-- Dipilih: Satu named window agar PARTITION dan ORDER BY konsisten untuk tiga fungsi peringkat.
-- Alternatif: Tiga klausa OVER lengkap; tidak dipilih karena mengulang definisi window.

SELECT c.name AS kategori,
       f.title,
       f.rental_rate,
       ROW_NUMBER() OVER w AS nomor_baris,
       RANK() OVER w AS peringkat,
       DENSE_RANK() OVER w AS peringkat_padat
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WINDOW w AS (
    PARTITION BY c.category_id
    ORDER BY f.rental_rate DESC
)
ORDER BY kategori, peringkat, f.title;