-- Diminta: membuktikan domain positive_amount menolak pembayaran nol dan negatif.
-- Dipilih: menguji dua nilai tidak valid secara terpisah.
-- Alternatif: hanya menguji satu nilai; tidak dipilih karena tugas meminta dua bukti galat.

INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, 0);

INSERT INTO lab5.payment_tx (rental_id, amount)
VALUES (1, -5.00);
