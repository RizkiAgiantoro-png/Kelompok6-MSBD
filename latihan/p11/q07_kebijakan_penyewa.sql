-- Diminta: membuat sepasang kebijakan isolasi penyewa (baca dan tulis) yang aman dari kesalahan pengetikan tipe data.
-- Dipilih: membungkus current_setting dengan nullif(..., '')::int pada klausul USING dan WITH CHECK.
-- Alternatif: menggunakan current_setting(...)::int langsung; tidak dipilih karena PostgreSQL 17 melempar galat 'invalid input syntax for type integer: ""' saat sesi memakai string kosong.

CREATE POLICY p_tenant_baca ON lab11.pelanggan FOR SELECT TO app_read, app_write
USING (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

CREATE POLICY p_tenant_tulis ON lab11.pelanggan FOR ALL TO app_write
USING (tenant_id = nullif(current_setting('app.tenant', true), '')::int)
WITH CHECK (tenant_id = nullif(current_setting('app.tenant', true), '')::int);

-- Catatan:
-- p_tenant_baca membatasi pembacaan baris hanya untuk tenant_id yang sesuai dengan sesi aktif.
-- p_tenant_tulis membatasi penulisan (INSERT/UPDATE/DELETE) agar data hanya dimanipulasi sesuai tenant_id sesi aktif.
