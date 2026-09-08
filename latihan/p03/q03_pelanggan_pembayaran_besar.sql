-- Diminta: menampilkan kategori yang memiliki lebih dari 60 film.
-- Dipilih: derived table dan HAVING ditampilkan untuk membandingkan keterbacaan.
-- Alternatif: hanya menggunakan HAVING; tidak dipilih sebagai satu-satunya versi karena soal meminta perbandingan.

-- Versi 1: Derived Table
SELECT
    x.name AS kategori,
    x.jumlah_film
FROM (
    SELECT
        c.name,
        COUNT(*) AS jumlah_film
    FROM category c
    JOIN film_category fc
        ON fc.category_id = c.category_id
    GROUP BY c.category_id, c.name
) AS x
WHERE x.jumlah_film > 60
ORDER BY x.jumlah_film DESC, x.name;


-- Versi 2: HAVING
SELECT
    c.name AS kategori,
    COUNT(*) AS jumlah_film
FROM category c
JOIN film_category fc
    ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(*) > 60
ORDER BY jumlah_film DESC, kategori;