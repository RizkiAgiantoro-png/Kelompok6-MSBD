-- Diminta: Memperbaiki query agar tahan terhadap siklus (infinite loop) yang terjadi akibat modifikasi data.
-- Dipilih: Penggunaan pelacakan jalur bertipe array dan ANY() untuk mendeteksi apakah ID sudah pernah dilewati.
-- Alternatif: Menggunakan UNION alih-alih UNION ALL; tidak dipilih karena berisiko membuang data duplikat alami dan lebih membebani memori.

WITH RECURSIVE hierarki_aman AS (
    SELECT pegawai_id, nama, atasan_id, 0 AS level, ARRAY[pegawai_id] AS path
    FROM pegawai
    WHERE atasan_id IS NULL
    
    UNION ALL
    
    SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1, h.path || p.pegawai_id
    FROM pegawai p
    JOIN hierarki_aman h ON p.atasan_id = h.pegawai_id
    WHERE NOT (p.pegawai_id = ANY(h.path))
)
SELECT pegawai_id, nama, level, path
FROM hierarki_aman
ORDER BY path;