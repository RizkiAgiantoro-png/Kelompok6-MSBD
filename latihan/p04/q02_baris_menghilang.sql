-- Diminta: menyisipkan film dengan rental_rate 4.99 lewat view, lalu menghitung selisih baris di view dan tabel dasar.
-- Dipilih: INSERT INTO dilanjutkan dengan dua SELECT count untuk membuktikan anomali baris yang menghilang.
-- Alternatif: Menggunakan subquery untuk menghitung selisih; tidak dipilih karena dosen meminta hitungan secara terpisah.

INSERT INTO lab4.film_murah (film_id, title, rental_rate, rating)
VALUES (9999, 'Film Mahal Misterius', 4.99, 'G');

-- Cek di tabel dasar (pasti ada dan bernilai 1)
SELECT count(*) AS di_tabel_dasar FROM lab4.film WHERE title = 'Film Mahal Misterius';

-- Cek di view (pasti tidak ada dan bernilai 0)
SELECT count(*) AS di_view FROM lab4.film_murah WHERE title = 'Film Mahal Misterius';