-- Diminta: Mengukur biaya trigger level baris pada UPDATE massal.
-- Dipilih: Membandingkan UPDATE dengan trigger aktif dan trigger dinonaktifkan menggunakan \timing.
-- Alternatif: EXPLAIN ANALYZE saja; tidak dipilih karena soal meminta pengukuran waktu eksekusi aktual.

\timing on

UPDATE lab4.film
SET rental_rate = rental_rate + 0.01;

ALTER TABLE lab4.film
DISABLE TRIGGER film_audit_harga;

UPDATE lab4.film
SET rental_rate = rental_rate + 0.01;

ALTER TABLE lab4.film
ENABLE TRIGGER film_audit_harga;