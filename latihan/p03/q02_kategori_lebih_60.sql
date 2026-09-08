-- Diminta: Menampilkan nama kategori dan jumlah film hanya untuk kategori yang memiliki > 60 film.
-- Dipilih: Menggunakan HAVING karena sintaksnya lebih ringkas dan alami untuk filter agregasi.
-- Alternatif: Derived table (subquery di FROM); ditampilkan di bawah sebagai pembanding keterbacaan sesuai instruksi soal.

-- Versi 1: Menggunakan HAVING
SELECT c.name AS kategori, COUNT(*) AS jumlah_film
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(*) > 60
ORDER BY jumlah_film DESC, kategori;

-- Versi 2: Menggunakan Derived Table (Sebagai pembanding)
/*
SELECT x.kategori, x.jumlah_film
FROM (
    SELECT c.name AS kategori, COUNT(*) AS jumlah_film
    FROM category c
    JOIN film_category fc ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
) AS x
WHERE x.jumlah_film > 60
ORDER BY x.jumlah_film DESC, x.kategori;
*/