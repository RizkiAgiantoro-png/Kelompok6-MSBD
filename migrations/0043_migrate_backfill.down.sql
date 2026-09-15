-- Migration 0043 DOWN: menghapus data hasil backfill migration 0043.

DELETE FROM lab4.harga_film
WHERE wilayah = 'ID'
  AND berlaku = daterange('2026-01-01', NULL);