-- Diminta: mencari film dengan tarif sewa di atas rata-rata seluruh film.
-- Dipilih: subquery skalar karena rata-rata seluruh film menghasilkan satu nilai.
-- Alternatif: CTE; tidak dipilih karena perhitungannya sederhana dan langsung.

SELECT
    title,
    rental_rate,
    (
        SELECT AVG(rental_rate)
        FROM film
    ) AS rata_rata_tarif,
    rental_rate - (
        SELECT AVG(rental_rate)
        FROM film
    ) AS selisih_dari_rata_rata
FROM film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
)
ORDER BY rental_rate DESC, title;