-- Diminta: menguji pencarian dengan nilai yang di-bind sebagai parameter.
-- Dipilih: placeholder %s di Python dan $1 untuk kontrol SQL setara.
-- Alternatif: menghapus apostrof. Cara itu juga mengubah nama sah.

-- Di lab11-web: python rentan.py "O'Neil"
-- Jalankan SQL ini dengan login app_laporan. Kedua hasil mengikuti data lab.
BEGIN;
SET LOCAL app.tenant = '1';
SELECT session_user AS login, current_user AS peran;
PREPARE p11_q15_cari(text) AS
    SELECT count(*) AS jumlah
    FROM (
        SELECT id, nama, kota FROM lab11.pelanggan
        WHERE nama ILIKE $1 LIMIT 100
    ) AS hasil;
EXECUTE p11_q15_cari('%Pelanggan 12%');
EXECUTE p11_q15_cari($pola$%O'Neil%$pola$);
DEALLOCATE p11_q15_cari;
ROLLBACK;
