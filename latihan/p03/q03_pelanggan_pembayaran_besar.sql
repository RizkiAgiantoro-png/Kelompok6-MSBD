-- Diminta: Menampilkan nama pelanggan yang pernah melakukan pembayaran lebih dari 9.99 dalam satu transaksi.
-- Dipilih: Klausa EXISTS dengan correlated subquery, karena mesin basis data akan langsung berhenti mencari (short-circuit) begitu menemukan satu baris yang cocok, sehingga jauh lebih cepat.
-- Alternatif: Menggunakan JOIN dan DISTINCT; dilarang keras oleh aturan soal karena memaksa basis data menggabungkan seluruh baris pembayaran terlebih dahulu yang akan memboroskan memori.

SELECT
    first_name,
    last_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id
      AND p.amount > 9.99
);