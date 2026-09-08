-- Diminta: Menampilkan film dengan tarif sewa di atas rata-rata beserta selisih tarifnya terhadap rata-rata, diurutkan menurun.
-- Dipilih: Subquery skalar pada WHERE (untuk filter) dan SELECT (untuk menghitung rata-rata dan selisih) karena hanya menghasilkan nilai tunggal.
-- Alternatif: Menggunakan CTE atau Window Function (AVG() OVER()); tidak dipilih karena kueri ini masih cukup sederhana dan efisien menggunakan subquery skalar.

SELECT
    title,
    rental_rate,
    (SELECT avg(rental_rate) FROM film) AS rata_rata,
    rental_rate - (SELECT avg(rental_rate) FROM film) AS selisih
FROM film
WHERE rental_rate > (SELECT avg(rental_rate) FROM film)
ORDER BY rental_rate DESC;