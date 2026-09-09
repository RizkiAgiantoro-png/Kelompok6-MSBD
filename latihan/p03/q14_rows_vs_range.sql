-- Diminta: Membandingkan running total dengan frame ROWS dan frame RANGE default.
-- Dipilih: Dua CTE hasil lalu FULL JOIN agar tanggal yang berbeda dan jumlah perbedaannya terlihat.
-- Alternatif: EXCEPT; tidak dipilih karena FULL JOIN memperlihatkan nilai dari kedua frame pada satu baris.

WITH harian AS (
    SELECT payment_date::date AS tanggal,
           SUM(amount) AS omzet
    FROM payment
    GROUP BY payment_date::date
), rows_frame AS (
    SELECT tanggal,
           SUM(omzet) OVER (
               ORDER BY tanggal
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS kumulatif_rows
    FROM harian
), range_frame AS (
    SELECT tanggal,
           SUM(omzet) OVER (ORDER BY tanggal) AS kumulatif_range
    FROM harian
), perbandingan AS (
    SELECT COALESCE(r.tanggal, g.tanggal) AS tanggal,
           r.kumulatif_rows,
           g.kumulatif_range
    FROM rows_frame r
    FULL JOIN range_frame g USING (tanggal)
)
SELECT tanggal,
       kumulatif_rows,
       kumulatif_range,
       kumulatif_rows IS DISTINCT FROM kumulatif_range AS berbeda,
       COUNT(*) FILTER (
           WHERE kumulatif_rows IS DISTINCT FROM kumulatif_range
       ) OVER () AS jumlah_tanggal_berbeda
FROM perbandingan
ORDER BY tanggal;