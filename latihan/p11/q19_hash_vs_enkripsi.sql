-- Diminta: hash kata sandi akun dengan bcrypt cost 8 dan bandingkan dua hash dari sandi yang sama.
-- Dipilih: crypt dengan garam acak, lalu verifikasi sandi terhadap hash yang disimpan.
-- Alternatif: enkripsi kata sandi; tidak dipilih karena sandi cukup diverifikasi, tidak perlu dibuka kembali.

-- Jalankan lewat psql sebagai postgres. Nama kolom sandi harus mengikuti tabel asli.
-- Periksa dengan \d lab11.akun, lalu gunakan -v kolom_sandi=NAMA_KOLOM.
\set ON_ERROR_STOP on
\if :{?kolom_sandi}
\else
  \echo 'Belum dijalankan: isi variabel kolom_sandi sesuai struktur lab11.akun.'
  \quit
\endif

SELECT session_user AS login, current_user AS peran;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;
-- Kolom tambahan dipakai agar data awal tetap tersedia untuk percobaan kelompok.
-- Ini belum merupakan migrasi produksi: sandi teks terang masih harus dihapus
-- setelah proses migrasi dan verifikasi selesai.
ALTER TABLE lab11.akun ADD COLUMN IF NOT EXISTS sandi_hash text;
UPDATE lab11.akun
SET sandi_hash = crypt(:"kolom_sandi"::text, gen_salt('bf', 8));

SELECT count(*) AS jumlah_akun,
       count(sandi_hash) AS akun_terhash,
       count(*) FILTER (
           WHERE crypt(:"kolom_sandi"::text, sandi_hash) = sandi_hash
       ) AS sandi_cocok
FROM lab11.akun;
COMMIT;

WITH pasangan AS MATERIALIZED (
    SELECT crypt('contoh-sandi-lab11', gen_salt('bf', 8)) AS hash_1,
           crypt('contoh-sandi-lab11', gen_salt('bf', 8)) AS hash_2
)
SELECT hash_1, hash_2, hash_1 <> hash_2 AS hash_berbeda,
       crypt('contoh-sandi-lab11', hash_1) = hash_1 AS sandi_benar,
       crypt('sandi-salah', hash_1) = hash_1 AS sandi_salah
FROM pasangan;

-- Garam acak menghambat penggunaan tabel hash siap pakai dan pencocokan
-- pengguna yang memakai sandi sama. Tebakan per hash tetap mungkin;
-- biaya bcrypt memperlambatnya. Hasil yang diharapkan: t, t, f.
