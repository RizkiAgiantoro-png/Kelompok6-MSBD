-- Diminta: mengukur hak tabel dan visibilitas baris untuk app_laporan.
-- Dipilih: uji baca dengan login app_laporan dan konteks penyewa 1.
-- Alternatif: menghitung sebagai superuser. Hasilnya tidak mewakili RLS aplikasi.

BEGIN;
SET LOCAL app.tenant = '1';
SELECT session_user AS login,
       current_user AS peran,
       pg_has_role(current_user, 'app_read', 'USAGE') AS memakai_hak_baca,
       pg_has_role(current_user, 'app_write', 'MEMBER') AS anggota_app_write,
       has_table_privilege('lab11.pelanggan', 'SELECT') AS boleh_select,
       has_table_privilege('lab11.pelanggan', 'INSERT') AS boleh_insert,
       has_table_privilege('lab11.pelanggan', 'UPDATE') AS boleh_update,
       has_table_privilege('lab11.pelanggan', 'DELETE') AS boleh_delete,
       row_security_active('lab11.pelanggan') AS rls_berlaku;

SELECT count(*) AS semua_baris_terlihat,
       count(*) FILTER (WHERE tenant_id = 1) AS baris_penyewa_1,
       count(*) FILTER (WHERE tenant_id <> 1) AS baris_penyewa_lain
FROM lab11.pelanggan;
ROLLBACK;

-- Hak tabel menentukan operasi yang diizinkan. RLS membatasi baris
-- yang terlihat. Keduanya tetap diperlukan saat filter pencarian gagal.
