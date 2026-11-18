-- Diminta: menyalakan Row-Level Security pada tabel pelanggan dan membuktikan perilaku default-deny sebelum kebijakan dibuat.
-- Dipilih: mengaktifkan RLS dengan ALTER TABLE ... ENABLE ROW LEVEL SECURITY lalu menguji pembacaan sebagai peran app_laporan.
-- Alternatif: mengandalkan penyaringan WHERE di aplikasi; tidak dipilih karena jika pengembang lupa, data seluruh penyewa bocor (fail-open).

ALTER TABLE lab11.pelanggan ENABLE ROW LEVEL SECURITY;

BEGIN;
  SET LOCAL ROLE app_laporan;
  SELECT count(*) AS sebelum_ada_kebijakan FROM lab11.pelanggan; -- harapkan 0
COMMIT;

-- Penjelasan Keamanan:
-- Saat RLS diaktifkan tanpa kebijakan (policy), PostgreSQL menerapkan prinsip default-deny.
-- Kueri mengembalikan 0 baris secara aman (fail-closed), bukan galat atau membocorkan data.
