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