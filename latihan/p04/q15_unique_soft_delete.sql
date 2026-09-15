-- Request:
-- Membandingkan UNIQUE biasa dengan partial unique index
-- pada skenario soft delete.
--
-- Bentuk query yang dipilih:
-- Partial unique index dengan kondisi deleted_at IS NULL.
-- Bentuk ini dipilih agar judul film hanya unik untuk data yang masih aktif.
--
-- Alternatif yang tidak dipilih:
-- UNIQUE biasa pada kolom title.
-- UNIQUE biasa akan tetap menganggap data yang sudah soft delete
-- sebagai duplikat sehingga data aktif baru dengan judul yang sama
-- tidak dapat dibuat.

ALTER TABLE lab4.film
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL;

ALTER TABLE lab4.film
ADD CONSTRAINT ux_film_title UNIQUE (title);

INSERT INTO lab4.film (film_id, title, rental_rate, rating)
VALUES (3002, 'Film Soft Delete', 2.99, 'G');

UPDATE lab4.film
SET deleted_at = CURRENT_TIMESTAMP
WHERE film_id = 3002;

INSERT INTO lab4.film (film_id, title, rental_rate, rating)
VALUES (3003, 'Film Soft Delete', 3.99, 'PG');

ALTER TABLE lab4.film
DROP CONSTRAINT ux_film_title;

CREATE UNIQUE INDEX ux_film_judul_aktif
ON lab4.film (title)
WHERE deleted_at IS NULL;

INSERT INTO lab4.film (film_id, title, rental_rate, rating)
VALUES (3004, 'Film Soft Delete', 4.99, 'R');

UPDATE lab4.film
SET deleted_at = CURRENT_TIMESTAMP
WHERE film_id = 3004;

INSERT INTO lab4.film (film_id, title, rental_rate, rating)
VALUES (3005, 'Film Soft Delete', 5.99, 'NC-17');