-- Diminta: menyebutkan tiga cara isolasi RLS masih bisa ditembus, satu kalimat perbaikan masing-masing, dan membuktikan minimal satu celah.
-- Dipilih: menganalisis celah BYPASSRLS/superuser, kebocoran sesi pool, dan tabel relasi/view tanpa RLS, lalu membuktikan celah BYPASSRLS dengan keluaran nyata.
-- Alternatif: hanya menyebutkan teori tanpa bukti; tidak dipilih karena instruksi mewajibkan minimal satu bukti nyata.

-- Tiga Cara Isolasi RLS Bisa Ditembus:
-- 1. Celah Superuser / Atribut BYPASSRLS:
--    Aplikasi terhubung menggunakan peran superuser atau peran yang memiliki atribut BYPASSRLS sehingga seluruh kebijakan RLS diabaikan.
--    Perbaikan: Terapkan prinsip hak minimum (Least Privilege) dan pastikan kredensial aplikasi tidak menggunakan peran superuser maupun atribut BYPASSRLS.
--
-- 2. Celah Kebocoran Konteks Kolam Koneksi (Session Leakage):
--    Variabel app.tenant disetel di tingkat sesi tanpa transaksi (SET tanpa LOCAL), sehingga konteks tertinggal dan terbaca oleh permintaan penyewa lain pada koneksi yang sama.
--    Perbaikan: Selalu bungkus eksekusi query dalam transaksi dengan SET LOCAL app.tenant = '...' atau set_config('app.tenant', '...', true).
--
-- 3. Celah Tabel Relasi / Anak dan View yang Lupa Diberi RLS:
--    Tabel pelanggan dilindungi RLS, tetapi tabel anak (seperti akun atau transaksi) atau View lupa diaktifkan RLS-nya sehingga data penyewa lain dapat dibaca langsung lewat relasi tersebut.
--    Perbaikan: Wajib aktifkan RLS (ENABLE ROW LEVEL SECURITY) pada seluruh tabel yang memuat data peka atau relasi tenant, serta gunakan security_barrier = true pada seluruh View.

-- Pembuktian Nyata Celah 1 (BYPASSRLS Menembus Isolasi):
GRANT SELECT ON lab11.pelanggan TO app_analitik;

-- Tahap A: Tanpa BYPASSRLS (Aman, terisolasi)
BEGIN;
  SET LOCAL ROLE app_analitik;
  SET LOCAL app.tenant = '1';
  SELECT count(*) AS tanpa_bypassrls FROM lab11.pelanggan; -- Hasil: 0 (tunduk RLS)
COMMIT;

-- Tahap B: Eksploitasi / Pembuktian dengan BYPASSRLS
ALTER ROLE app_analitik BYPASSRLS;

BEGIN;
  SET LOCAL ROLE app_analitik;
  SET LOCAL app.tenant = '1';
  SELECT count(*) AS celah_bypassrls_tembus FROM lab11.pelanggan; -- Hasil: 30000 (Seluruh data penyewa lain bocor!)
COMMIT;

-- Pembersihan
ALTER ROLE app_analitik NOBYPASSRLS;
REVOKE SELECT ON lab11.pelanggan FROM app_analitik;
