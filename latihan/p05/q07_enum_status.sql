-- Diminta: menguji enum status dan menambahkan nilai baru.
-- Dipilih: menguji nilai EXPIRED sebelum dan sesudah ALTER TYPE.
-- Alternatif: langsung menambahkan EXPIRED tanpa membuktikan penolakan awal.

UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;

ALTER TYPE lab5.rental_status
ADD VALUE 'EXPIRED';

UPDATE lab5.rental_tx
SET status = 'EXPIRED'
WHERE rental_id = 1;
