-- Diminta: menjelaskan beda hasil ketika masukan ikut membentuk SQL.
-- Dipilih: menjelaskan peran pola, literal teks, dan komentar SQL.
-- Alternatif: menganggap satu karakter kutip selalu menyebabkan galat sintaks.

-- Tanpa komentar, bagian pola yang ditambahkan aplikasi masih ikut
-- dievaluasi. Kondisi perbandingan dapat bernilai salah, sementara pola
-- nama awal dapat tidak cocok, sehingga hasilnya kosong.
-- Komentar mengabaikan sisa baris SQL. Jika kondisi yang tersisa selalu
-- benar, ekspresi pencarian tidak lagi membatasi baris yang bisa dilihat
-- oleh peran. Kebijakan RLS tetap menentukan visibilitas baris.
-- Pembanding di bawah memakai ekspresi SQL tetap, tanpa masukan dinamis.
SELECT 'a' = 'a%' AS persen_dalam_perbandingan_adalah_karakter_biasa,
       'a' ILIKE 'a%' AS persen_dalam_pola_adalah_wildcard;
