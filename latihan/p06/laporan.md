Laporan Latihan Kelompok Pertemuan 6

Identitas Kelompok dan Kontribusi Commit
1. Daffa Umayans Saragih (251402011) : Langkah 1 (q00 - Q1) dan Langkah 2 (Q2 - Q6)
2. Anggota 2 : Langkah 3 (Q7 - Q11)
3. Anggota 3 : Langkah 4 (Q12 - Q16)
4. Anggota 4 : Langkah 5 (Q17 - Q21) dan Langkah 6 (Q22 - Q26)
5. Anggota 5 : Langkah 7 (Q27 - Q31) dan Finalisasi


Kondisi Uji
PostgreSQL : PostgreSQL 17 pada Docker container
Spesifikasi mesin : Laptop ASUS TUF Dash F15, RAM 8 GB, Windows 11
Setelan paralel : SET max_parallel_workers_per_gather = 0;
Jumlah pengulangan : Setiap query diuji 3 kali untuk mengambil waktu tercepat dan median


Jawaban Q1 sampai Q31

Langkah 1 (Q1)

Q1 Reflektif
Dari hasil pengukuran pada tabel lab6.event_log dengan total 2.000.000 baris, tercatat ukuran total tabel (pg_total_relation_size) sebesar 501 MB (524.894.208 bytes). Ukuran ini terbagi atas ukuran heap tabel sebesar 458 MB (479.789.056 bytes) dan ukuran index primary key sebesar 43 MB. Jika dibagi dengan jumlah baris, maka rata-rata ukuran per baris adalah 262,45 bytes untuk ukuran total, atau 239,89 bytes jika hanya menghitung bagian heap.

Jika dibandingkan dengan perkiraan kasar dari definisi tipe data kolomnya (event_id 8 bytes, customer_id 4 bytes, terjadi_pada 8 bytes, idempotency_key 16 bytes, jumlah sekitar 6 sampai 8 bytes, empat kolom text sekitar 43 bytes, ditambah array tags dan jsonb payload sekitar 72 bytes), ukuran murni datanya sebenarnya hanya sekitar 157 sampai 160 bytes per baris. Ukuran nyata di heap menjadi lebih besar (239,89 bytes per baris) karena PostgreSQL menambahkan overhead di setiap baris berupa header tuple (HeapTupleHeaderData) sebesar 24 bytes untuk menyimpan metadata transaksi (xmin, xmax, cid, ctid), line pointer (ItemIdData) sebesar 4 bytes di awal halaman, padding untuk alignment memori antar kolom, serta sisa ruang kosong di bagian akhir halaman berukuran 8 KB yang tidak cukup lagi untuk diisi baris baru.


Langkah 2 (Q2 sampai Q6)

Q2 Tuple per Halaman
Berdasarkan hasil perhitungan melalui kolom sistem ctid pada tabel lab6.event_log, diperoleh total halaman yang terisi sebanyak 58.568 halaman. Jumlah minimum tuple dalam satu halaman adalah 4 tuple (terletak pada halaman paling akhir), rata-rata tuple per halaman adalah 34,15 tuple, dan maksimum tuple per halaman adalah 35 tuple.

Angka ini jauh di bawah batas teoretis PostgreSQL yaitu 291 tuple per halaman. Selisih ini terjadi karena batas 291 tuple hanya bisa dicapai jika baris tabel tidak memiliki data kolom sama sekali, sehingga setiap baris hanya memakan 28 bytes (24 bytes header tuple dan 4 bytes line pointer pada halaman 8.192 bytes). Karena rata-rata satu baris pada tabel lab6.event_log berukuran sekitar 239,89 bytes, maka satu halaman berukuran 8.192 bytes setelah dikurangi header halaman memang hanya muat menampung paling banyak 35 baris.

Q3 TOAST
Dari hasil pengecekan kolom attstorage pada katalog pg_attribute untuk tabel lab6.event_log, diperoleh pembagian sebagai berikut:
- Kolom dengan nilai p (plain): event_id, customer_id, terjadi_pada, idempotency_key
- Kolom dengan nilai m (main): jumlah
- Kolom dengan nilai x (extended): status, wilayah, kota, email, tags, payload
- Kolom dengan nilai e (external): tidak ada

Kolom yang memiliki attstorage bernilai x atau e dapat dikompresi dan dipindahkan penyimpanannya ke tabel TOAST terpisah apabila ukuran baris melebihi batas sekitar 2 KB. Akibatnya, jika kita menjalankan query mengambil semua kolom, PostgreSQL harus ikut membaca halaman di tabel TOAST dan melakukan dekompresi untuk mengambil kolom seperti payload atau tags, walaupun sebenarnya kita tidak membutuhkan kolom tersebut. Hal ini membuat jumlah blok yang dibaca meningkat dan memperlambat waktu eksekusi query.

Q4 HOT Update
Pada percobaan ini dibuat dua tabel dengan 50.000 baris, yaitu hot_penuh (fillfactor 100) dan hot_longgar (fillfactor 80), lalu dilakukan UPDATE pada kolom catatan yang tidak memiliki index. Hasil pembacaan pada pg_stat_user_tables menunjukkan:
- Tabel hot_penuh: n_tup_upd = 50000 dan n_tup_hot_upd = 0
- Tabel hot_longgar: n_tup_upd = 50000 dan n_tup_hot_upd = 12252

Tabel hot_penuh tidak menghasilkan HOT update sama sekali karena seluruh halaman sudah terisi 100 persen sejak INSERT awal, sehingga versi baris baru hasil UPDATE terpaksa ditempatkan di halaman baru. Sebaliknya, tabel hot_longgar menyisakan 20 persen ruang kosong di setiap halaman saat INSERT, sehingga ketika UPDATE dijalankan, sebanyak 12.252 baris berhasil diperbarui langsung di dalam halaman yang sama menggunakan mekanisme HOT update.

Q5 Harga Fillfactor
Perbandingan ukuran kedua tabel sebelum dan sesudah proses UPDATE 50.000 baris adalah sebagai berikut:
- Sebelum UPDATE: ukuran heap hot_penuh adalah 6.560 kB, sedangkan hot_longgar adalah 8.168 kB.
- Sesudah UPDATE pada hot_penuh: ukuran heap menjadi 13 MB (13.434.880 bytes), ukuran index 3.080 kB, dan ukuran total 16 MB (16.629.760 bytes).
- Sesudah UPDATE pada hot_longgar: ukuran heap menjadi 14 MB (14.671.872 bytes), ukuran index 2.968 kB, dan ukuran total 17 MB (17.752.064 bytes).

Ruang yang harus dibayar untuk mendapatkan peluang HOT update pada fillfactor 80 terlihat dari ukuran awal tabel hot_longgar yang memakan ruang sekitar 24,5 persen lebih besar dibanding hot_penuh (8.168 kB dibanding 6.560 kB) karena seperlima bagian dari tiap halaman sengaja dikosongkan. Sebagai gantinya, saat terjadi UPDATE, baris yang berhasil melakukan HOT update pada hot_longgar tidak perlu membuat entri baru di dalam index, yang terlihat dari ukuran index hot_longgar yang lebih kecil (2.968 kB) dibandingkan ukuran index pada hot_penuh (3.080 kB).

Q6 Reflektif
Pada pengujian Q6, dilakukan perbandingan antara meng-update kolom yang tidak terindeks (kolom catatan pada tabel hot_longgar) dengan meng-update kolom yang terindeks (kolom kode pada tabel hot_uji_indeks) di mana kedua tabel sama-sama memakai fillfactor 80. Hasilnya, update pada kolom tidak terindeks menghasilkan n_tup_hot_upd sebesar 12.252, sedangkan update pada kolom terindeks menghasilkan n_tup_hot_upd sebesar 0.

Perbedaan ini terjadi karena HOT (Heap-Only Tuple) update bekerja dengan cara menyimpan tuple versi baru di halaman yang sama dan membuat rantai penunjuk ctid dari tuple lama ke tuple baru di dalam halaman tersebut, sehingga index luar tetap menunjuk ke item pointer lama tanpa perlu tahu ada perubahan posisi baris. Cara ini hanya bisa dipakai apabila nilai dari kolom yang diindeks tidak berubah. Saat kolom kode yang memiliki index diubah nilainya (kode = kode + 1), pohon B-Tree pada index wajib membuat entri baru sesuai urutan nilai yang baru agar pencarian lewat index tetap benar. Karena index harus ikut diperbarui, maka mekanisme HOT update otomatis tidak bisa dijalankan walaupun halaman tabel masih memiliki ruang kosong.


Langkah 3 (Q7 sampai Q11)
Dilanjutkan oleh Anggota 2


Langkah 4 (Q12 sampai Q16)
Dilanjutkan oleh Anggota 3
Langkah 4 (Q12 sampai Q16) - Ramadiyan

Q12 - Partial Index

Dibuat Partial Index `ev_gagal_idx` pada kolom `terjadi_pada` dengan kondisi `status = 'GAGAL'`, kemudian dibandingkan dengan index biasa `ev_terjadi_pada_idx`.

Hasil:
- `ev_gagal_idx` = 896 kB
- `ev_terjadi_pada_idx` = 43 MB
- Penghematan = 97,96%

Partial Index jauh lebih kecil karena hanya menyimpan baris dengan `status = 'GAGAL'`.

Q13 - Expression Index

Dibuat Expression Index:

```sql
CREATE INDEX ev_email_lower_idx
ON lab6.event_log (lower(email));

Q14 - Covering Index
Dibuat Covering Index:

CREATE INDEX ev_cover_idx
ON lab6.event_log (customer_id)
INCLUDE (terjadi_pada, jumlah);

Query menggunakan Index Only Scan.

Sebelum VACUUM:
Heap Fetches = 0
Execution Time = 0.294 ms

Sesudah VACUUM (ANALYZE):
Heap Fetches = 0
Execution Time = 0.110 ms

Q15 - Perbandingan Index INCLUDE dan 3 Kolom

Ukuran ev_cover_idx dengan INCLUDE:
77 MB

Ukuran ev_cover_3col_idx:
77 MB

Hasil execution plan menggunakan:
Index Only Scan
Index: ev_cover_3col_idx
Heap Fetches = 0
Execution Time = 0.212 ms

Pada pengujian ini, kedua index memiliki ukuran yang sama.

Q16 - Pengaruh VACUUM terhadap Heap Fetches
VACUUM memperbarui visibility map pada tabel. Jika halaman heap sudah ditandai sebagai all-visible, PostgreSQL dapat mengambil data langsung dari index melalui Index Only Scan tanpa perlu memeriksa heap. Oleh karena itu, jumlah Heap Fetches dapat berkurang atau menjadi 0.


Langkah 5 (Q17 sampai Q21)

Q17 - GIN pada JSONB
Dibuat GIN Index `ev_payload_gin_idx` menggunakan `jsonb_path_ops` pada kolom `payload`.
- Ukuran Heap Tabel: 458 MB
- Ukuran GIN Index (`ev_payload_gin_idx`): 7.096 kB (~7,1 MB, hanya 1,5% dari ukuran heap).
- Plan & Hasil Query: PostgreSQL menggunakan `Bitmap Index Scan` pada `ev_payload_gin_idx` dilanjutkan dengan `Bitmap Heap Scan`.
- Waktu Eksekusi: 262.616 ms dengan `shared hit=3 read=58587`.
GIN `jsonb_path_ops` jauh lebih hemat ruang karena hanya menyimpan hash dari path dan value JSONB yang digunakan dalam pencarian operator `@>`.

Q18 - GIN pada Array
Dilakukan pengujian query `tags @> ARRAY['kanal:1']` dengan dan tanpa GIN Index (`ev_tags_gin_idx`).
- Dengan GIN Index (`Bitmap Index Scan`): Execution Time = 239.944 ms (Buffers: `shared hit=1 read=58644`).
- Tanpa Index (`Seq Scan`): Execution Time = 326.577 ms (Buffers: `shared hit=16341 read=42235`).
Penggunaan GIN Index mempercepat pencarian elemen di dalam array bertipe text dengan memfilter halaman secara efisien via bitmap.

Q19 - Ukuran BRIN vs B-Tree & Correlation
- Nilai `correlation` untuk kolom `terjadi_pada` pada katalog `pg_stats` bernilai `1` (korelasi fisik sempurna karena data di-generate dengan urutan timestamp naik).
- Ukuran BRIN Index (`ev_terjadi_pada_brin_idx`): 32 kB
- Ukuran B-Tree Index (`ev_terjadi_pada_btree_idx`): 43 MB
- BRIN Index berukuran lebih dari 1.300x lebih kecil daripada B-Tree Index karena BRIN hanya menyimpan sepasang nilai minimum dan maksimum per range halaman (128 halaman), bukan entri untuk setiap baris.

Q20 - Pengujian Rentang 7 Hari (BRIN vs B-Tree)
Pengujian query pencarian rentang 7 hari pada 2.000.000 baris:
- BRIN Index (`Bitmap Heap Scan` via `ev_terjadi_pada_brin_idx`): Execution Time = 12.350 ms, Buffers read/hit = 1.545 blocks.
- B-Tree Index (`Index Scan` via `ev_terjadi_pada_btree_idx`): Execution Time = 6.553 ms, Buffers read/hit = 1.671 blocks.
B-Tree sedikit lebih cepat (6,55 ms vs 12,35 ms) karena dapat melompati langsung ke halaman spesifik tanpa Recheck Cond. Namun, BRIN mencapai performa yang sangat dekat (12,35 ms) hanya dengan konsumsi memori 32 kB dibanding 43 MB pada B-Tree.

Q21 Reflektif - Rasionalisasi Penggunaan BRIN
Penghematan ukuran BRIN (hanya berukuran beberapa puluh kilobytes) sangat sepadan digunakan apabila:
1. Kolom data bertipe time-series atau append-only dengan korelasi fisik yang sangat tinggi mendekati 1.0 (seperti log kejadian / transaksi).
2. Ukuran tabel sangat besar (puluhan/ratusan GB) di mana simpanan RAM/Disk terbatas, dan selisih waktu eksekusi beberapa milidetik masih dalam ambang toleransi aplikasi.


Langkah 6 (Q22 sampai Q26)

Q22 - Selektivitas Status
Dibuat index `ev_status_idx` pada kolom `status`. Hasil pengujian:
- `status = 'SUKSES'` (~84% data / 1.680.000 baris): Query Planner memilih `Seq Scan` (Execution Time = 605.160 ms).
- `status = 'GAGAL'` (~2% data / 40.000 baris): Query Planner memilih `Bitmap Index Scan` (Execution Time = 1166.755 ms).
Optimizer memilih Seq Scan pada nilai mayoritas karena membaca halaman secara berurutan jauh lebih murah dibanding membaca index yang mengarahkan ke hampir 100% halaman heap secara acak.

Q23 & Q24 - Titik Peralihan Selektivitas & Dampak random_page_cost
- Distribusi Data: `SUKSES` (84,00%), `TERTUNDA` (14,00%), `GAGAL` (2,00%).
- Pada `random_page_cost` default (4.0), query dengan `status = 'TERTUNDA'` (14%) menggunakan `Bitmap Heap Scan` dengan Execution Time = 1088.108 ms.
- Saat `random_page_cost` diturunkan menjadi `1.1` (Q24), optimizer beralih menggunakan pure `Index Scan using ev_status_idx` (estimasi cost turun dari 65.245 menjadi 40.863), dan Execution Time berkurang drastis menjadi 133.236 ms.
Penurunan `random_page_cost` membuat optimizer menganggap pembacaan halaman acak di disk/RAM hampir se-murah pembacaan berurutan, sehingga memicu pergeseran titik transisi ke arah penggunaan Index Scan.

Q25 - Extended Statistics (wilayah-kota)
Dilakukan perbandingan estimasi baris pada query `WHERE wilayah = 'SUMUT' AND kota = 'SUMUT-1'`:
- Sebelum Extended Statistics:
  - Rows Estimated: 9.314 baris
  - Rows Actual: 44.444 baris (Terdapat kesalahan estimasi ~4,77x karena PostgreSQL mengasumsikan kedua kolom independen).
- Sesudah Extended Statistics (`CREATE STATISTICS ev_wil_kota_stat (dependencies, ndistinct)` + `ANALYZE`):
  - Rows Estimated: 43.730 baris
  - Rows Actual: 44.444 baris (Estimasi hampir 100% akurat).

Q26 Reflektif - Ambang Peralihan Selektivitas
Titik peralihan dari Index Scan ke Sequential Scan bukan merupakan angka persentase tetap (misalnya tidak selalu di 10% atau 15%) karena ambang batas tersebut dihitung secara dinamis oleh Query Planner berdasarkan:
1. Nilai `random_page_cost` dibanding `seq_page_cost`.
2. Jumlah tuple per halaman (kepadatan baris).
3. Korelasi fisik data pada disk.
4. Ukuran total tabel dan ketersediaan cache buffer memori.



Langkah 7 (Q27 sampai Q31)
Dilanjutkan oleh Anggota 5


Tabel Perbandingan
Query/index | Tercepat | Median | Buffers | Ukuran | Keputusan


Rekomendasi Akhir
Dilanjutkan oleh Anggota 5


Penggunaan AI dan Verifikasi
Bantuan AI digunakan untuk membantu penulisan query pembacaan katalog sistem PostgreSQL seperti pg_attribute, pg_stat_user_tables, dan cara mengambil nomor halaman dari kolom ctid. Seluruh query telah dijalankan sendiri pada container PostgreSQL lokal dan seluruh angka yang ditulis di laporan ini sesuai dengan keluaran nyata di terminal.