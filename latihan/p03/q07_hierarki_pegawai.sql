-- Diminta: Menampilkan hierarki pegawai, level kedalaman, dan jalur jabatan dari puncak.
-- Dipilih: Recursive CTE dengan anchor pada atasan_id IS NULL karena struktur data berbentuk pohon hierarkis (parent-child).
-- Alternatif: Self-join bertingkat manual; tidak dipilih karena hierarki bisa terus bertambah kedalamannya.

WITH RECURSIVE hierarki AS (
    SELECT pegawai_id, nama, atasan_id, 0 AS level, nama::text AS jalur
    FROM pegawai
    WHERE atasan_id IS NULL
    
    UNION ALL
    
    SELECT p.pegawai_id, p.nama, p.atasan_id, h.level + 1, h.jalur || ' > ' || p.nama
    FROM pegawai p
    JOIN hierarki h ON p.atasan_id = h.pegawai_id
)
SELECT pegawai_id, nama, level, jalur
FROM hierarki
ORDER BY jalur;