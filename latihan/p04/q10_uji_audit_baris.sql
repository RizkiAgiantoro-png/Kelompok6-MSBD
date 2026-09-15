-- Diminta: Membuktikan bahwa hanya perubahan rental_rate menghasilkan audit.
-- Dipilih: Menguji perubahan harga, penetapan harga yang sama, dan perubahan title.
-- Alternatif: Hanya menguji satu UPDATE; tidak dipilih karena tidak cukup untuk membuktikan kondisi yang diabaikan.

UPDATE lab4.film
SET rental_rate = rental_rate + 0.01
WHERE film_id = 1;

UPDATE lab4.film
SET rental_rate = rental_rate
WHERE film_id = 2;

UPDATE lab4.film
SET title = title || ' TEST'
WHERE film_id = 3;

SELECT *
FROM lab4.audit_harga
ORDER BY audit_id DESC;