-- Diminta: menyediakan view tersamar bagi app_analitik dan menolak akses tabel asli.
-- Dipilih: view milik postgres tanpa security_invoker, dengan security_barrier.
-- Alternatif: security_invoker=true; tidak dipilih karena analis akan memerlukan hak tabel asli.

\set ON_ERROR_STOP on
SELECT session_user AS login, current_user AS peran;
-- Jalankan sebagai postgres. Pemilik view ini sengaja postgres untuk lab:
-- skema_owner tunduk FORCE RLS dan belum punya policy, sehingga bisa mendapat 0 baris.
BEGIN;
REVOKE pg_read_all_data FROM app_analitik;
ALTER ROLE app_analitik NOBYPASSRLS;
CREATE OR REPLACE VIEW lab11.v_pelanggan_samar
WITH (security_barrier = true, security_invoker = false) AS
SELECT id, tenant_id,
       left(nama, 1) || repeat('*', greatest(length(nama) - 1, 1)) AS nama,
       'xxxxxxxxxxxx' || right(nik, 4) AS nik,
       regexp_replace(surel, '^[^@]+', '****') AS surel,
       date_trunc('year', lahir)::date AS lahir_tahun,
       kota, round(saldo, -5) AS saldo_bulat
FROM lab11.pelanggan;
ALTER VIEW lab11.v_pelanggan_samar OWNER TO postgres;
REVOKE ALL ON lab11.pelanggan FROM app_analitik;
REVOKE ALL ON lab11.v_pelanggan_samar FROM PUBLIC;
GRANT USAGE ON SCHEMA lab11 TO app_analitik;
GRANT SELECT ON lab11.v_pelanggan_samar TO app_analitik;

-- REVOKE langsung tidak menghilangkan hak yang berasal dari peran lain/PUBLIC.
DO $$
BEGIN
    IF has_table_privilege('app_analitik', 'lab11.pelanggan', 'SELECT')
       OR has_any_column_privilege('app_analitik', 'lab11.pelanggan', 'SELECT') THEN
        RAISE EXCEPTION 'app_analitik masih punya hak baca turunan; periksa keanggotaan peran dan PUBLIC';
    END IF;
END;
$$;
COMMIT;

SET ROLE app_analitik;
SELECT session_user AS login, current_user AS peran;
SELECT * FROM lab11.v_pelanggan_samar ORDER BY id LIMIT 5;
SELECT count(*) AS baris_view FROM lab11.v_pelanggan_samar;

-- Hanya uji negatif ini yang diizinkan menghasilkan galat.
\set VERBOSITY verbose
\set ON_ERROR_STOP off
SELECT * FROM lab11.pelanggan LIMIT 1;
\set hasil_akses :SQLSTATE
\set ON_ERROR_STOP on
RESET ROLE;
SELECT :'hasil_akses' AS sqlstate_akses_langsung,
       :'hasil_akses' = '42501' AS akses_ditolak;
-- Harapkan permission denied (42501), bukan sekadar 0 baris akibat RLS.
