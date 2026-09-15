Bagian Q1 - Q4 (View)
Q2: Penjelasan Baris Menghilang
Pada Q2, baris berhasil disisipkan dan muncul di tabel dasar (1 baris), tetapi tidak muncul di view (0 baris). Hal ini terjadi karena view film_murah memiliki filter kondisi (rental_rate <= 0.99). Saat kita memasukkan data dengan harga 4.99, data tersebut masuk ke tabel dasar, namun saat view dibaca ulang, data tersebut disaring keluar karena tidak memenuhi syarat filter view.

Q3: Pesan Galat Check Option
ERROR:  new row violates check option for view "film_murah"
DETAIL:  Failing row contains (9998, Film Mahal Ditolak, null, null, null, null, null, 4.99, null, null, G, null, null, null).

Q4: Pesan Galat Auto-Updatable
ERROR:  cannot insert into view "pendapatan_kategori"
DETAIL:  Views containing GROUP BY are not automatically updatable.
HINT:  To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.
Penjelasan: View ini tidak auto-updatable karena menggunakan klausa GROUP BY. PostgreSQL tidak bisa secara otomatis menebak bagaimana memecah satu baris data agregasi (hasil perhitungan sum/group) untuk dikembalikan menjadi baris-baris data individual di tabel dasar.

Refleksi A
Sebuah tim menempatkan seluruh akses aplikasi melalui view dengan alasan lebih aman dan lebih rapi. Sebutkan dua keuntungan, dua kerugian, dan satu keadaan konkret ketika pendekatan ini justru mempersulit tim.

Keuntungan:

Keamanan data lebih terjamin karena tim bisa membatasi kolom atau baris tertentu (row-level/column-level security) yang boleh diakses aplikasi tanpa menyentuh tabel dasar.

Abstraksi query, di mana logika JOIN yang rumit disembunyikan dari aplikasi sehingga kode aplikasi menjadi lebih bersih.

Kerugian:

Penurunan performa pada operasi pembacaan berulang jika view tersebut menggabungkan banyak tabel besar tanpa di-materialize, karena query akan dieksekusi dari awal setiap kali dipanggil.

Keterbatasan operasi tulis (INSERT/UPDATE/DELETE), di mana tidak semua view bersifat auto-updatable.

Keadaan konkret yang mempersulit:
Ketika aplikasi bisnis menuntut pengguna untuk bisa memasukkan (INSERT) data secara langsung ke halaman laporan analitik. Karena view laporan tersebut menggunakan fungsi agregat seperti GROUP BY atau sistem window, view akan otomatis menolak operasi tulis. Tim database harus bekerja ekstra menulis trigger INSTEAD OF yang sangat kompleks hanya agar aplikasi bisa melakukan modifikasi data standar.

Refleksi B 

1. Penggunaan Materialized View (Q05–Q07):
   - Materialized View sangat efektif untuk menyimpan hasil query agregasi/kompleks secara fisik di disk, sehingga mempercepat performa pembacaan data (`SELECT`).
   - Saat membuat Materialized View dengan klausul `WITH NO DATA`, tabel view tidak dapat diakses sebelum dilakukan perintah `REFRESH MATERIALIZED VIEW`.
   - Untuk menjalankan pembaruan data secara fleksibel menggunakan `REFRESH MATERIALIZED VIEW CONCURRENTLY`, PostgreSQL mewajibkan adanya setidaknya satu `UNIQUE INDEX` (tanpa klausul `WHERE`) pada kolom Materialized View tersebut.

2. Pengujian Akses Pembaca (Q08):
   - Fitur `CONCURRENTLY` terbukti mencegah *exclusive lock* pada tabel view.
   - Proses pembaruan data berjalan di latar belakang (background), sehingga transaksi pembacaan (`SELECT`) dari pengguna/aplikasi lain tetap dapat berjalan lancar tanpa mengalami *blocking*.

3. Implementasi Migration 0042 (Dual-Write Trigger):
   - *Trigger* berhasil dibuat untuk menangani skenario sinkronisasi otomatis (*dual-write*).
   - Setiap kali terjadi perubahan nilai `rental_rate` pada tabel utama `film`, fungsi *trigger* secara otomatis memperbarui nilai harga yang setara pada tabel `harga_film`.

   Refleksi C
   1. Perbandingan Trigger Row-Level dan Statement-Level
   Berdasarkan Q12 dan Q13, terdapat perbedaan pada cara trigger dijalankan. Row-level trigger berjalan untuk setiap baris yang mengalami perubahan. Pada Q12, UPDATE terhadap 1.000 baris menyebabkan trigger row-level dipanggil untuk setiap baris tersebut.
   Sementara itu, statement-level trigger berjalan satu kali untuk satu statement, meskipun statement tersebut mengubah banyak baris. Pada Q13 digunakan transition table untuk memperoleh kumpulan baris lama dan baru yang terkena perubahan. Dengan demikian, statement-level trigger dapat memproses perubahan secara berkelompok.

   2. Hasil Benchmark
   Hasil pengukuran waktu eksekusi pada percobaan adalah:
   Trigger row-level aktif: 56.446 ms
   Trigger row-level disabled: 22.032 ms
   Trigger statement-level: 41.357 ms
   Hasil tersebut menunjukkan bahwa penggunaan trigger menambah waktu eksekusi UPDATE. Row-level trigger memiliki overhead lebih besar karena function trigger dijalankan untuk setiap baris yang berubah. Pada percobaan ini, statement-level trigger memiliki waktu eksekusi lebih rendah dibandingkan row-level trigger aktif karena trigger hanya dijalankan satu kali untuk satu statement dan perubahan dapat diproses melalui transition table.

   3. Satu Kemampuan yang Tidak Dimiliki Statement-Level Trigger
   Statement-level trigger tidak secara langsung memiliki konteks OLD dan NEW untuk setiap baris seperti row-level trigger. Untuk mengetahui kumpulan baris yang berubah, statement-level trigger dapat menggunakan transition table, yaitu tabel sementara yang merepresentasikan kumpulan data lama dan data baru dari statement tersebut.

   4. Mengapa Mengirim Email Langsung dari Trigger Buruk?
   Mengirim email secara langsung dari trigger kurang baik karena trigger berjalan di dalam transaksi database. Jika transaksi kemudian mengalami ROLLBACK, perubahan pada database dapat dibatalkan, tetapi efek eksternal seperti email yang sudah dikirim tidak otomatis ikut dibatalkan. Hal tersebut dapat menyebabkan penerima memperoleh email yang seolah-olah menyatakan perubahan berhasil, padahal transaksi database sebenarnya gagal.
   Oleh karena itu, efek eksternal seperti pengiriman email lebih baik dilakukan melalui mekanisme asynchronous setelah transaksi database berhasil.