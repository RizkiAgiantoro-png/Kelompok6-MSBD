-- Diminta: menjelaskan bahaya kebocoran konteks penyewa di kolam koneksi dan menunjukkan pola pencegahannya.
-- Dipilih: mendemonstrasikan pola SET LOCAL dan set_config(..., true) di dalam transaksi.
-- Alternatif: memakai SET app.tenant biasa (level sesi) dengan RESET ALL manual; tidak dipilih karena rentan bocor jika aplikasi mengalami unhandled exception sebelum RESET terpanggil.

-- 1. Simulasi Masalah: Konteks penyewa tertinggal di level sesi koneksi
-- Jika sesi menyetel tenant tanpa LOCAL:
-- SET app.tenant = '1';
-- Saat koneksi dikembalikan ke pool dan dipakai permintaan berikutnya yang lupa menyetel tenant,
-- data penyewa 1 akan bocor ke permintaan tersebut:
-- SELECT current_setting('app.tenant', true); -- mengembalikan '1' (bocor!)

-- 2. Pola Pencegahan 1: Menggunakan SET LOCAL di dalam blok transaksi
BEGIN;
  SET LOCAL ROLE app_laporan;
  SET LOCAL app.tenant = '1';
  SELECT count(*) AS baris_tenant1 FROM lab11.pelanggan;
COMMIT;
-- Begitu COMMIT atau ROLLBACK selesai, konteks app.tenant otomatis terhapus (kosong/NULL).

-- 3. Pola Pencegahan 2: Menggunakan fungsi set_config(..., true)
BEGIN;
  SELECT set_config('app.tenant', '1', true); -- parameter ke-3 (is_local = true)
  SELECT count(*) AS baris_tenant1_config FROM lab11.pelanggan;
COMMIT;
-- Konteks terisolasi hanya pada transaksi aktif dan aman digunakan pada connection pooler (PgBouncer/HikariCP).
