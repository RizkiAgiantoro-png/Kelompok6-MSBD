-- Setup awal Latihan Pertemuan 9.
-- Jalankan pada database lab yang boleh diubah, bukan pada skema Pagila.
-- Menjalankan ulang skrip ini mengembalikan dua rekening awal ke saldo 1000000.

CREATE SCHEMA IF NOT EXISTS lab9;

CREATE TABLE IF NOT EXISTS lab9.rekening (
    rekening_id INT PRIMARY KEY,
    pemilik TEXT NOT NULL,
    saldo NUMERIC(12,2) NOT NULL CHECK (saldo >= 0)
);

INSERT INTO lab9.rekening (rekening_id, pemilik, saldo) VALUES
    (1, 'Ani', 1000000),
    (2, 'Budi', 1000000)
ON CONFLICT (rekening_id) DO UPDATE
SET pemilik = EXCLUDED.pemilik,
    saldo = EXCLUDED.saldo;

SELECT rekening_id, pemilik, saldo
FROM lab9.rekening
ORDER BY rekening_id;

SELECT COUNT(*) AS jumlah_rekening, SUM(saldo) AS total_saldo
FROM lab9.rekening;
