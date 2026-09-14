-- Diminta: Membuat ulang view dengan WITH CASCADED CHECK OPTION dan mengulangi insert Q2.
-- Dipilih: CREATE OR REPLACE VIEW ditambahkan klausa pengaman CASCADED CHECK OPTION.
-- Alternatif: WITH LOCAL CHECK OPTION; tidak dipilih karena soal secara spesifik meminta CASCADED.

CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99
WITH CASCADED CHECK OPTION;

-- Sisipkan lagi untuk memicu pesan galat dari sistem
INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (9998, 'Film Mahal Ditolak', 4.99, 'G');