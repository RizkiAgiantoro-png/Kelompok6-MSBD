-- Diminta: menyiapkan klaster tertutup dan memuat skema lab11 secara deterministik.
-- Dipilih: menjalankan skrip setup pada skema terisolasi lab11 dengan jaringan internal.
-- Alternatif: memakai skema public; tidak dipilih karena mencampur data latihan dengan skema lain.

CREATE SCHEMA IF NOT EXISTS lab11;

-- Verifikasi jumlah baris keempat tabel awal
SELECT (SELECT count(*) FROM lab11.tenant)     AS tenant,
       (SELECT count(*) FROM lab11.pelanggan)  AS pelanggan,
       (SELECT count(*) FROM lab11.akun)       AS akun,
       (SELECT count(*) FROM lab11.transaksi)  AS transaksi;

SELECT tenant_id, count(*) FROM lab11.pelanggan GROUP BY 1 ORDER BY 1;