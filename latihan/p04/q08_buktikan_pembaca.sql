-- Diminta: Membuktikan bahwa REFRESH CONCURRENTLY tidak mengunci akses pembaca.
-- Dipilih: Simulasi insert data besar lalu menguji pembacaan saat refresh berjalan.
-- Alternatif: Refresh biasa; tidak dipilih untuk akses bersamaan karena melakukan exclusive lock pada tabel.

-- Menambahkan data baru dalam jumlah besar agar proses REFRESH memakan waktu
INSERT INTO lab4.jejak_akses (film_id, waktu, kanal)
SELECT
    (random() * 999)::int + 1,
    now(),
    'web'
FROM generate_series(1, 200000);

-- Uji Refresh Concurrent (Pembaca di terminal lain tetap bisa SELECT)
REFRESH MATERIALIZED VIEW CONCURRENTLY lab4.ringkasan_akses;