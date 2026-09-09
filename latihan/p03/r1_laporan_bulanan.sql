-- Diminta: Membuat laporan pendapatan bulanan per kategori dengan peringkat, pertumbuhan, kumulatif, dan porsi.
-- Dipilih: CTE bulanan lalu beberapa window dengan partisi sesuai makna setiap metrik.
-- Alternatif: Satu definisi window untuk semua kolom; tidak dipilih karena peringkat, lag, kumulatif, dan porsi memiliki partisi berbeda.

WITH bulanan AS (
    SELECT date_trunc('month', p.payment_date)::date AS bulan,
           c.name AS kategori,
           SUM(p.amount) AS pendapatan
    FROM payment p
    JOIN rental r ON r.rental_id = p.rental_id
    JOIN inventory i ON i.inventory_id = r.inventory_id
    JOIN film_category fc ON fc.film_id = i.film_id
    JOIN category c ON c.category_id = fc.category_id
    GROUP BY 1, 2
), dihitung AS (
    SELECT bulan,
           kategori,
           pendapatan,
           RANK() OVER (
               PARTITION BY bulan
               ORDER BY pendapatan DESC
           ) AS peringkat,
           LAG(pendapatan) OVER (
               PARTITION BY kategori
               ORDER BY bulan
           ) AS bulan_lalu,
           SUM(pendapatan) OVER (
               PARTITION BY kategori
               ORDER BY bulan
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS pendapatan_kumulatif,
           SUM(pendapatan) OVER (PARTITION BY bulan) AS total_bulan
    FROM bulanan
)
SELECT bulan,
       kategori,
       pendapatan,
       peringkat,
       bulan_lalu,
       CASE
           WHEN bulan_lalu IS NULL OR bulan_lalu = 0 THEN NULL
           ELSE ROUND((pendapatan - bulan_lalu) * 100.0 / bulan_lalu, 2)
       END AS pertumbuhan_persen,
       pendapatan_kumulatif,
       ROUND(pendapatan * 100.0 / NULLIF(total_bulan, 0), 2) AS porsi_persen
FROM dihitung
ORDER BY bulan, peringkat, kategori;