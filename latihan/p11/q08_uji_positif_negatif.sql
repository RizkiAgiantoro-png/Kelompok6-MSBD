-- Diminta: melakukan uji positif (membaca data penyewa sendiri) dan uji negatif (mencoba membaca data penyewa lain) sebagai app_laporan.
-- Dipilih: menjalankan kueri hitung tenant 1 dan kueri eksplisit WHERE tenant_id = 2 dalam transaksi dengan SET LOCAL.
-- Alternatif: hanya menguji kueri positif; tidak dipilih karena uji keamanan wajib membuktikan penolakan akses data penyewa lain.

BEGIN;
  SET LOCAL ROLE app_laporan;
  SET LOCAL app.tenant = '1';
  SELECT count(*) AS terlihat_tenant1 FROM lab11.pelanggan;              -- harapkan 10000
  SELECT count(*) AS harus_nol FROM lab11.pelanggan WHERE tenant_id = 2; -- harapkan 0
COMMIT;

-- Hasil:
-- terlihat_tenant1 = 10000 (uji positif berhasil, seluruh baris milik tenant 1 terbaca).
-- harus_nol = 0 (uji negatif berhasil, klausa WHERE eksplisit penyerang disaring secara otomatis oleh RLS).
