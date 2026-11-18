-- Diminta: mencatat SQL dan jumlah hasil untuk pencarian normal penyewa 1.
-- Dipilih: jalankan Python dalam mode pembanding dan cek hitungannya dengan SQL tetap.
-- Alternatif: mencampur input dengan sintaks SQL. Keduanya dikirim terpisah.

-- Di lab11-web: python rentan.py --pembanding "Pelanggan 12"
-- Templat: SELECT id, nama, kota FROM lab11.pelanggan WHERE nama ILIKE %s
-- Parameter: '%Pelanggan 12%'. Masukan pengguna adalah Pelanggan 12.
-- Tanda % berasal dari kode pembentuk pola. Modul mengharapkan 365 baris.
-- Jalankan SQL ini dengan login app_laporan.
BEGIN;
SET LOCAL app.tenant = '1';
SELECT session_user AS login, current_user AS peran,
       count(*) AS jumlah_pembanding
FROM lab11.pelanggan
WHERE nama ILIKE '%Pelanggan 12%';
ROLLBACK;
