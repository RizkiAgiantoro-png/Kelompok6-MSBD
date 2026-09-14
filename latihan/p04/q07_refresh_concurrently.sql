-- Diminta: Menguji REFRESH MATERIALIZED VIEW CONCURRENTLY, membuat unique index, lalu mengukur refresh concurrent.

-- Coba CONCURRENTLY tanpa index (akan menghasilkan ERROR)
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;

-- Buat UNIQUE INDEX (Wajib UNIQUE)
CREATE UNIQUE INDEX ux_ringkasan_akses ON lab4.ringkasan_akses (bulan, kanal);

-- Jalankan CONCURRENTLY setelah ada index
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;