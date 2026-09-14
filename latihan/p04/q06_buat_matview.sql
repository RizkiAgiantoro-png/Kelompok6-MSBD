-- Diminta: Mengubah query Q5 menjadi materialized view dengan WITH NO DATA, menguji pembacaan sebelum refresh, lalu melakukan refresh biasa.
-- Dipilih: Materialized view agar hasil agregasi dapat disimpan dan dibaca tanpa menghitung ulang seluruh data setiap kali.
-- Alternatif: View biasa; tidak dipilih karena view biasa selalu menghitung query dasarnya saat dibaca.

CREATE MATERIALIZED VIEW lab4.ringkasan_akses AS
SELECT
    date_trunc('month', a.waktu) AS bulan,
    a.kanal,
    count(*) AS jumlah_akses,
    count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2
WITH NO DATA;

-- Uji baca sebelum REFRESH (Pasti ERROR)
SELECT * FROM lab4.ringkasan_akses;

-- REFRESH biasa
REFRESH MATERIALIZED VIEW lab4.ringkasan_akses;

-- Uji baca setelah REFRESH
SELECT * FROM lab4.ringkasan_akses;