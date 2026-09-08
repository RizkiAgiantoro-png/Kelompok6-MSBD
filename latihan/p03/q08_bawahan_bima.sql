-- Diminta: Menampilkan bawahan langsung maupun tidak langsung dari Bima beserta jaraknya.
-- Dipilih: Recursive CTE dengan penyaringan anchor secara spesifik pada nama 'Bima'.
-- Alternatif: Memfilter nama 'Bima' di query utama dari seluruh hierarki; tidak dipilih karena membatasi dari anchor jauh lebih efisien.

WITH RECURSIVE bawahan AS (
    SELECT pegawai_id, nama, atasan_id, 0 AS jarak
    FROM pegawai
    WHERE nama = 'Bima'
    
    UNION ALL
    
    SELECT p.pegawai_id, p.nama, p.atasan_id, b.jarak + 1
    FROM pegawai p
    JOIN bawahan b ON p.atasan_id = b.pegawai_id
)
SELECT pegawai_id, nama, jarak
FROM bawahan
WHERE jarak > 0
ORDER BY jarak, pegawai_id;