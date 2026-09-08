-- Diminta: Nama pelanggan yang pernah melakukan pembayaran > 9.99 dalam satu transaksi.
-- Dipilih: EXISTS berkorelasi untuk memastikan keberadaan transaksi tanpa menghasilkan duplikasi baris pelanggan.
-- Alternatif: JOIN + DISTINCT; tidak dipilih karena instruksi dengan tegas meminta EXISTS berkorelasi dan melarang JOIN + DISTINCT.

SELECT c.first_name, c.last_name
FROM customer c
WHERE EXISTS (
    SELECT 1 
    FROM payment p 
    WHERE p.customer_id = c.customer_id AND p.amount > 9.99
)
ORDER BY c.first_name, c.last_name;