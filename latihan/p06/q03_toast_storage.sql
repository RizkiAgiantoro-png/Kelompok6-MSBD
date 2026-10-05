-- Q3: Periksa attstorage pada pg_attribute untuk melihat kolom bernilai x atau e
SELECT 
    attnum AS no_kolom,
    attname AS nama_kolom,
    format_type(atttypid, atttypmod) AS tipe_data,
    attstorage
FROM pg_attribute
WHERE attrelid = 'lab6.event_log'::regclass
  AND attnum > 0
  AND NOT attisdropped
ORDER BY attnum;