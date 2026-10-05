-- Q2: Hitung tuple per halaman melalui ctid dan bandingkan dengan batas teoretis 291 tuple
WITH tuple_per_page AS (
    SELECT (ctid::text::point)[0]::bigint AS nomor_halaman,
           count(*) AS jumlah_tuple
    FROM lab6.event_log
    GROUP BY 1
)
SELECT 
    count(*) AS total_halaman,
    min(jumlah_tuple) AS min_tuple_per_halaman,
    round(avg(jumlah_tuple), 2) AS rata_tuple_per_halaman,
    max(jumlah_tuple) AS max_tuple_per_halaman,
    291 AS batas_teoretis_tuple
FROM tuple_per_page;