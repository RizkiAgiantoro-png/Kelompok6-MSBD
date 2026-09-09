-- Diminta: Menampilkan urutan pembayaran, jarak hari sejak pembayaran sebelumnya, dan total belanja tiap pelanggan.
-- Dipilih: Window PARTITION BY customer_id dengan LAG untuk riwayat dan frame penuh untuk total pelanggan.
-- Alternatif: Subquery berkorelasi per pelanggan; tidak dipilih karena lebih mahal dan lebih sulit dibaca.

SELECT customer_id,
       payment_id,
       payment_date,
       amount,
       ROW_NUMBER() OVER pelanggan AS urutan_pembayaran,
       payment_date::date
           - LAG(payment_date::date) OVER pelanggan AS jarak_hari_sebelumnya,
       SUM(amount) OVER (
           PARTITION BY customer_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS total_belanja_pelanggan
FROM payment
WINDOW pelanggan AS (
    PARTITION BY customer_id
    ORDER BY payment_date, payment_id
)
ORDER BY customer_id, payment_date, payment_id;