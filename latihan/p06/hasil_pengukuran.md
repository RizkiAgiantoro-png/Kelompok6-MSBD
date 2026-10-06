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

## Langkah 7 (Q27 sampai Q31)
Q27: Harga Tulis Index

Pengujian dilakukan dengan INSERT sebanyak 200.000 baris pada tabel tanpa index dan tabel dengan lima index. Setiap kondisi dijalankan tiga kali.

Tanpa index
Run 1 | 848.287 ms
Run 2 | 607.452 ms
Run 3 | 694.427 ms

Tercepat | 607.452 ms
Median   | 694.427 ms
Dengan lima index
Run 1 | 4568.800 ms
Run 2 | 3848.288 ms
Run 3 | 3791.625 ms

Tercepat | 3791.625 ms
Median   | 3848.288 ms

Perbandingan median:

Tanpa index       | 694.427 ms
Dengan 5 index    | 3848.288 ms
Kenaikan          | 454.17%
Rasio waktu       | ~5.54x

Buffer pada pengujian:

Tanpa index
shared hit | 211761
dirtied    | 5885
written    | 5887

Dengan 5 index
shared hit | 1925600
read       | 4
dirtied    | 10026
written    | 10024
Q28: Harga Penyimpanan Index
kondisi            | table_size | index_size | total_size | table_bytes | index_bytes | total_bytes
-------------------+------------+------------+------------+-------------+-------------+-------------
Tanpa index        | 46 MB      | 0 bytes    | 46 MB      | 48242688    | 0           | 48242688
Dengan lima index  | 46 MB      | 32 MB      | 78 MB      | 48242688    | 33939456    | 82182144

Tambahan ukuran:

tambahan_ukuran         | 32 MB
persen_kenaikan_ukuran  | 70.35%
Q29: Statistik Index pada lab6.event_log
schemaname | table_name |   index_name   | idx_scan | idx_tup_read | idx_tup_fetch | index_bytes | index_size
-----------+------------+----------------+----------+--------------+---------------+-------------+------------
lab6       | event_log  | event_log_pkey |        1 |      2000000 |             0 |    44941312 | 43 MB

Definisi index:

CREATE UNIQUE INDEX event_log_pkey
ON lab6.event_log USING btree (event_id)
Q30: Data Pendukung Rekomendasi Index
index_name    | idx_scan | idx_tup_read | idx_tup_fetch | index_bytes | index_size
--------------+----------+--------------+---------------+-------------+-----------
event_log_pkey | 1       | 2000000      | 0             | 44941312    | 43 MB

Ukuran total event_log:

table_size   | 458 MB
indexes_size | 43 MB
total_size   | 501 MB
Q31: Dasar Keputusan Index
event_log_pkey
idx_scan  | 1
size      | 43 MB
status    | Dipertahankan karena merupakan primary key

Lima index pada pengujian Q27
median INSERT tanpa index | 694.427 ms
median INSERT dengan 5 index | 3848.288 ms
kenaikan waktu | 454.17%

Tambahan storage
tanpa index | 46 MB
dengan 5 index | 78 MB
kenaikan | 70.35%