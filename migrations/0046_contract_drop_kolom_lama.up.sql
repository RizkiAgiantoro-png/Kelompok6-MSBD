-- Migration 0046: tahap contract akhir.
-- Jangan dijalankan sebelum verifikasi Q19 = 0 dan view fasad telah stabil.

ALTER TABLE lab4.film
DROP COLUMN rental_rate;
