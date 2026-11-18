-- Diminta: membandingkan kombinasi unik sebelum/sesudah generalisasi dan menunjukkan kebocoran agregat.
-- Dipilih: hitung kelompok beranggota satu dan cari contoh dari data yang benar-benar tersedia.
-- Alternatif: menebak tanggal lahir unik; tidak dipilih karena datanya belum tentu cocok.

\set ON_ERROR_STOP on
SELECT session_user AS login, current_user AS peran;
-- Jalankan sebagai postgres agar perbandingan mencakup seluruh data lab.
WITH sebelum AS (
    SELECT kota, lahir FROM lab11.pelanggan
    GROUP BY kota, lahir HAVING count(*) = 1
), sesudah AS (
    SELECT kota, date_trunc('year', lahir)::date AS tahun
    FROM lab11.pelanggan
    GROUP BY kota, date_trunc('year', lahir)::date HAVING count(*) = 1
), jumlah AS (
    SELECT (SELECT count(*) FROM sebelum) AS unik_sebelum,
           (SELECT count(*) FROM sesudah) AS unik_sesudah
)
SELECT unik_sebelum, unik_sesudah,
       round(100.0 * (unik_sebelum - unik_sesudah) / nullif(unik_sebelum, 0), 2)
           AS penurunan_persen
FROM jumlah;
-- Unik berarti kombinasi yang hanya dimiliki satu orang, bukan semua DISTINCT.
-- Jika unik_sebelum=0, persentase NULL karena pembagian dengan nol tidak bermakna.

BEGIN;
CREATE TEMP TABLE target_q24 ON COMMIT DROP AS
SELECT kota, lahir
FROM lab11.pelanggan
WHERE kota IS NOT NULL AND lahir IS NOT NULL
  AND kota IN (SELECT kota FROM lab11.pelanggan GROUP BY kota HAVING count(*) > 1)
GROUP BY kota, lahir
HAVING count(*) = 1 AND count(saldo) = 1
ORDER BY kota, lahir
LIMIT 1;

SELECT * FROM target_q24;
-- Dua query ini hanya membaca agregat, tanpa menampilkan nama atau NIK.
CREATE TEMP TABLE agregat_semua ON COMMIT DROP AS
SELECT count(*) AS jumlah, sum(p.saldo) AS total
FROM lab11.pelanggan p JOIN target_q24 t ON p.kota = t.kota;
SELECT 'semua_di_kota' AS cakupan, * FROM agregat_semua;

CREATE TEMP TABLE agregat_tanpa_target ON COMMIT DROP AS
SELECT count(*) AS jumlah, sum(p.saldo) AS total
FROM lab11.pelanggan p JOIN target_q24 t ON p.kota = t.kota
WHERE p.lahir IS DISTINCT FROM t.lahir;
SELECT 'kecuali_tanggal_target' AS cakupan, * FROM agregat_tanpa_target;

SELECT a.jumlah - b.jumlah AS selisih_orang,
       a.total - coalesce(b.total, 0) AS saldo_terungkap
FROM agregat_semua a CROSS JOIN agregat_tanpa_target b
WHERE EXISTS (SELECT 1 FROM target_q24);
COMMIT;
-- Jika target kosong, data tidak menyediakan contoh unik untuk pasangan ini.
-- Catat keadaan itu, jangan mengarang target atau saldo.
-- Generalisasi mengurangi keunikan, tetapi belum menjamin data anonim.
