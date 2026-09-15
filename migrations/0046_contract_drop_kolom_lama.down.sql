-- Migration 0046 DOWN.
-- Hanya menambahkan kembali kolom, bukan memulihkan nilai historis lama.

ALTER TABLE lab4.film
ADD COLUMN rental_rate numeric(4,2);
