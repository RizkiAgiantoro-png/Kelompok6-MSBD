-- Diminta: menetapkan batas per pernyataan untuk app_portal dan mencatat SQLSTATE.
-- Dipilih: statement_timeout 5 detik sebagai default untuk login baru.
-- Alternatif: hanya memasang timeout di aplikasi. Server perlu dapat membatalkan kueri.

-- Jalankan sebagai postgres di lab11-db, lalu buat koneksi baru sebagai app_portal.
ALTER ROLE app_portal SET statement_timeout = '5s';

SELECT r.rolname AS peran, cfg.pengaturan
FROM pg_db_role_setting AS s
JOIN pg_roles AS r ON r.oid = s.setrole
CROSS JOIN LATERAL unnest(s.setconfig) AS cfg(pengaturan)
WHERE r.rolname = 'app_portal' AND s.setdatabase = 0
  AND cfg.pengaturan LIKE 'statement_timeout=%';

-- Pada login baru app_portal: SHOW statement_timeout;  -- 5s
-- SQLSTATE pembatalan: 57014 (query_canceled).
-- Panggilan pg_sleep yang membuat statement melewati batas memicu ERROR.
-- Apabila log_min_error_statement <= ERROR, SQL pemicu juga tercatat.
-- Gunakan pesan timeout dan peran aplikasi sebagai sinyal untuk ditinjau.
