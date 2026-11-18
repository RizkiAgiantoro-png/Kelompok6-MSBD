-- Diminta: memilih kolom dan arah ORDER BY dari daftar putih tertutup.
-- Dipilih: petakan pilihan ke pengenal dan kata kunci SQL tetap di Python.
-- Alternatif: ORDER BY $1. Parameter itu mewakili sebuah nilai, bukan nama kolom.

-- Uji tanpa koneksi melalui rentan.py:
-- python rentan.py --validasi-urut --kolom kota --arah turun
-- python rentan.py --validasi-urut --kolom saldo --arah turun
-- python rentan.py --validasi-urut --kolom kota --arah acak
-- Contoh SQL tetap untuk kombinasi kota/turun, dijalankan sebagai app_laporan.
BEGIN;
SET LOCAL app.tenant = '1';
SELECT id, nama, kota FROM lab11.pelanggan
ORDER BY kota DESC, id ASC
LIMIT 5;
ROLLBACK;
