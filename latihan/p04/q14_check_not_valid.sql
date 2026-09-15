-- Diminta: Menambahkan CHECK rental_rate tidak negatif menggunakan NOT VALID kemudian VALIDATE.
-- Dipilih: NOT VALID agar constraint dapat ditambahkan tanpa langsung memeriksa seluruh data lama.
-- Alternatif: CHECK langsung tanpa NOT VALID; tidak dipilih karena soal menguji proses validasi bertahap.

INSERT INTO lab4.film (
    film_id,
    title,
    rental_rate,
    rating
)
VALUES (
    3001,
    'Film Negatif',
    -1.00,
    'G'
);

ALTER TABLE lab4.film
ADD CONSTRAINT film_rental_rate_nonneg
CHECK (rental_rate >= 0) NOT VALID;

ALTER TABLE lab4.film
VALIDATE CONSTRAINT film_rental_rate_nonneg;

-- Perbaiki data yang melanggar constraint
UPDATE lab4.film
SET rental_rate = 0
WHERE film_id = 3001;

-- Validasi ulang setelah data diperbaiki
ALTER TABLE lab4.film
VALIDATE CONSTRAINT film_rental_rate_nonneg;