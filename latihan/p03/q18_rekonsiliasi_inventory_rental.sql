-- Diminta: Menampilkan film yang hanya ada di inventory atau hanya muncul melalui rental, dengan penanda arah.
-- Dipilih: EXCEPT lalu UNION ALL karena kebutuhan soal adalah symmetric difference dua himpunan.
-- Alternatif: FULL OUTER JOIN; tidak dipilih karena EXCEPT lebih langsung menyatakan operasi himpunan.

WITH inventory_films AS (
    SELECT DISTINCT film_id
    FROM inventory
), rental_films AS (
    SELECT DISTINCT i.film_id
    FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
), only_inventory AS (
    SELECT film_id
    FROM inventory_films
    EXCEPT
    SELECT film_id
    FROM rental_films
), only_rental AS (
    SELECT film_id
    FROM rental_films
    EXCEPT
    SELECT film_id
    FROM inventory_films
)
SELECT film_id, 'ada_di_inventory_tidak_pernah_disewa' AS arah
FROM only_inventory
UNION ALL
SELECT film_id, 'pernah_disewa_tidak_ada_di_inventory' AS arah
FROM only_rental
ORDER BY film_id, arah;