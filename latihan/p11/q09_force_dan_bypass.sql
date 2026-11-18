-- Diminta: menguji dampak FORCE ROW LEVEL SECURITY pada pemilik skema dan membandingkan pg_read_all_data dengan BYPASSRLS.
-- Dipilih: mengukur baris skema_owner sebelum/sesudah FORCE, lalu menguji app_analitik dengan pg_read_all_data vs BYPASSRLS.
-- Alternatif: mengabaikan FORCE RLS; tidak dipilih karena pemilik tabel dapat membocorkan data jika aplikasi terkoneksi sebagai owner.

-- 1. Uji skema_owner sebelum FORCE RLS (melihat seluruh 30.000 baris karena owner bebas dari RLS default)
ALTER TABLE lab11.pelanggan NO FORCE ROW LEVEL SECURITY;
SET ROLE skema_owner;
SELECT count(*) AS owner_sebelum_force FROM lab11.pelanggan; -- hasil: 30000
RESET ROLE;

-- 2. Terapkan FORCE ROW LEVEL SECURITY (memaksa RLS berlaku bagi pemilik tabel)
ALTER TABLE lab11.pelanggan FORCE ROW LEVEL SECURITY;
SET ROLE skema_owner;
SELECT count(*) AS owner_sesudah_force FROM lab11.pelanggan; -- hasil: 0 (default-deny karena belum ada kebijakan untuk owner)
RESET ROLE;

-- 3. Uji peran pg_read_all_data pada app_analitik
GRANT pg_read_all_data TO app_analitik;
SET ROLE app_analitik;
SET app.tenant = '1';
SELECT count(*) AS analitik_dengan_read_all_data FROM lab11.pelanggan; -- hasil: 0 (tetap tunduk pada RLS!)
RESET ROLE;

-- 4. Bandingkan dengan atribut BYPASSRLS
ALTER ROLE app_analitik BYPASSRLS;
SET ROLE app_analitik;
SELECT count(*) AS analitik_dengan_bypassrls FROM lab11.pelanggan; -- hasil: 30000 (menembus isolasi RLS)
RESET ROLE;

-- Kembalikan konfigurasi semula
ALTER ROLE app_analitik NOBYPASSRLS;
REVOKE pg_read_all_data FROM app_analitik;

-- Pelajaran:
-- pg_read_all_data hanya memberikan hak akses tabel (vertikal), tetapi TIDAK menembus aturan baris RLS (horizontal).
-- Hanya atribut eksplisit BYPASSRLS atau SUPERUSER yang dapat menembus kebijakan RLS.
