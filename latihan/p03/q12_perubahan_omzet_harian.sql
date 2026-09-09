-- Diminta: Menampilkan omzet harian, omzet hari sebelumnya, selisih, dan persentase perubahan.
-- Dipilih: CTE untuk mengagregasi payment per tanggal, lalu LAG untuk membandingkan antarhari.
-- Alternatif: Self-join berdasarkan tanggal; tidak dipilih karena lebih panjang dan lebih mudah salah.

WITH harian AS (
    SELECT payment_date::date AS tanggal,
           SUM(amount) AS omzet
    FROM payment
    GROUP BY payment_date::date
), dibandingkan AS (
    SELECT tanggal,
           omzet,
           LAG(omzet, 1, 0) OVER (ORDER BY tanggal) AS omzet_hari_sebelumnya
    FROM harian
)
SELECT tanggal,
       omzet,
       omzet_hari_sebelumnya,
       omzet - omzet_hari_sebelumnya AS selisih,
       CASE
           WHEN omzet_hari_sebelumnya = 0 THEN NULL
           ELSE ROUND((omzet - omzet_hari_sebelumnya) * 100.0
                      / omzet_hari_sebelumnya, 2)
       END AS perubahan_persen
FROM dibandingkan
ORDER BY tanggal;