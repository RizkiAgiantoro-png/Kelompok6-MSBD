-- Diminta: memberi app_write hak SELECT dengan GRANT OPTION, meneruskannya ke app_analitik, lalu menguji pencabutan CASCADE.
-- Dipilih: menguji GRANT OPTION dan REVOKE dengan opsi CASCADE.
-- Alternatif: mencabut tanpa opsi; tidak dipilih karena melanggar aturan dependensi hak.

GRANT SELECT ON lab11.transaksi TO app_write WITH GRANT OPTION;

SET ROLE app_write;
GRANT SELECT ON lab11.transaksi TO app_analitik;
RESET ROLE;

-- REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write; -- Mengamati galat dependensi
REVOKE GRANT OPTION FOR SELECT ON lab11.transaksi FROM app_write CASCADE;

SELECT has_table_privilege('app_analitik','lab11.transaksi','SELECT') AS analitik,
       has_table_privilege('app_write','lab11.transaksi','SELECT')    AS app_write;