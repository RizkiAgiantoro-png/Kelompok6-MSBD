Hasil Pengukuran Latihan Pertemuan 6

Langkah 1 dan Langkah 2 (Q1 sampai Q6)

1. Q1: Ukuran Tabel dan Rata-rata Byte per Baris

 jumlah_baris | ukuran_total | ukuran_total_bytes | ukuran_heap | ukuran_heap_bytes | ukuran_index | rata_byte_per_baris_total | rata_byte_per_baris_heap 
--------------+--------------+--------------------+-------------+-------------------+--------------+---------------------------+--------------------------
      2000000 | 501 MB       |          524894208 | 458 MB      |         479789056 | 43 MB        |                    262.45 |                   239.89
(1 row)


2. Q2: Tuple per Halaman (ctid)

 total_halaman | min_tuple_per_halaman | rata_tuple_per_halaman | max_tuple_per_halaman | batas_teoretis_tuple 
---------------+-----------------------+------------------------+-----------------------+----------------------
         58568 |                     4 |                  34.15 |                    35 |                  291
(1 row)


3. Q3: Pemeriksaan TOAST (pg_attribute)

 no_kolom |   nama_kolom    |        tipe_data         | attstorage 
----------+-----------------+--------------------------+------------
        1 | event_id        | bigint                   | p
        2 | customer_id     | integer                  | p
        3 | terjadi_pada    | timestamp with time zone | p
        4 | status          | text                     | x
        5 | wilayah         | text                     | x
        6 | kota            | text                     | x
        7 | email           | text                     | x
        8 | idempotency_key | uuid                     | p
        9 | jumlah          | numeric(10,2)            | m
       10 | tags            | text[]                   | x
       11 | payload         | jsonb                    | x
(11 rows)


4. Q4 dan Q5: HOT Update dan Harga Fillfactor

Ukuran sebelum UPDATE:
 heap_penuh_sebelum | heap_longgar_sebelum 
--------------------+----------------------
 6560 kB            | 8168 kB
(1 row)

Ukuran sesudah UPDATE:
 nama_tabel  | ukuran_heap_sesudah | bytes_heap_sesudah | ukuran_index_sesudah | ukuran_total_sesudah | bytes_total_sesudah 
-------------+---------------------+--------------------+----------------------+----------------------+---------------------
 hot_longgar | 14 MB               |           14671872 | 2968 kB              | 17 MB                |            17752064
 hot_penuh   | 13 MB               |           13434880 | 3080 kB              | 16 MB                |            16629760
(2 rows)


5. Q6: Perbandingan UPDATE Kolom Tidak Terindeks vs Terindeks

   nama_tabel   | n_tup_upd | n_tup_hot_upd 
----------------+-----------+---------------
 hot_longgar    |     50000 |         12252
 hot_uji_indeks |     50000 |             0
(2 rows)