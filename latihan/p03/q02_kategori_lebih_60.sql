-- Diminta: Menampilkan nama kategori beserta jumlah filmnya, khusus untuk kategori yang memiliki lebih dari 60 film.
-- Dipilih: Klausa HAVING dengan agregasi GROUP BY, karena sintaksnya lebih natural, ringkas, dan mudah dibaca untuk menyaring hasil agregat.
-- Alternatif: Menggunakan derived table (subquery di FROM); disertakan sebagai komentar pembanding di bawah, namun kurang efisien karena membuat blok kueri berlapis tanpa keuntungan performa.

-- Versi Utama (HAVING):
SELECT
    c.name AS nama_kategori,
    count(fc.film_id) AS jumlah_film
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.name
HAVING count(fc.film_id) > 60;

/*
-- Versi Alternatif (Derived Table di FROM):
SELECT nama_kategori, jumlah_film
FROM (
    SELECT c.name AS nama_kategori, count(fc.film_id) AS jumlah_film
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    GROUP BY c.name
) AS rekap_kategori
WHERE jumlah_film > 60;
*/