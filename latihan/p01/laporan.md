Keluaran docker --version
Plaintext
Docker version 29.7.2, build a7dcaa6
Keluaran docker compose version
Plaintext
Docker Compose version v5.4.0
Keluaran docker compose ps
Plaintext
NAME         IMAGE            COMMAND                  SERVICE   CREATED         STATUS                            PORTS
msbd-mongo   mongo:8          "docker-entrypoint.s..." mongo     2 seconds ago   Up 1 second                       0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp
msbd-pg      postgres:17      "docker-entrypoint.s..." postgres  2 seconds ago   Up 1 second (health: starting)    0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
msbd-redis   redis:7-alpine   "docker-entrypoint.s..." redis     2 seconds ago   Up 1 second                       0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
Keluaran SELECT version();
Plaintext
                                                 version
---------------------------------------------------------------------------------------------------------
 PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(1 row)
Jawaban tiga pertanyaan tentang Image, Container, dan Volume
1. Docker Image
Docker Image secara teknis merupakan sebuah paket statis (read-only) yang berperan sebagai cetakan utama yang berisi seluruh instruksi dan komponen untuk menjalankan aplikasi secara utuh, mulai dari sistem operasi dasar, kode program, pustaka, hingga pengaturan lingkungan. Karena sifatnya yang tidak bisa diubah, pembaruan sekecil apa pun mengharuskan kita untuk membangun image yang baru. Konsep ini ibarat sebuah cetak biru (blueprint) bangunan sebelum didirikan, resep masakan yang memuat daftar bahan baku, atau sebuah file installer (seperti .exe atau .apk) pada sistem operasi tradisional.

2. Docker Container
Docker Container adalah wujud nyata atau instansiasi operasional dari sebuah Docker Image yang sedang berjalan, di mana ia mengeksekusi aplikasi di dalam sebuah lingkungan yang terisolasi sepenuhnya dari sistem operasi komputer utama. Sifat dasarnya adalah sementara (ephemeral) dan dirancang sangat ringan, sehingga dapat dihidupkan, dimatikan, atau dihapus dalam hitungan detik, bahkan memungkinkan kita untuk menjalankan puluhan container identik dari satu image secara bersamaan. Jika dianalogikan, apabila image adalah resep atau cetak biru, maka container adalah kue yang sudah matang atau bangunan fisik yang sudah bisa dihuni, layaknya sebuah "komputer virtual mini" yang secara spesifik ditugaskan untuk menjalankan satu layanan saja.

3. Volume
Volume adalah mekanisme yang disediakan oleh Docker untuk menyimpan data secara permanen agar tidak ikut musnah saat sebuah container dihapus, di-restart, atau diperbarui. Alih-alih menyimpan data di dalam wadah container yang bersifat sementara, Volume bekerja dengan menjembatani dan menuliskan data tersebut langsung ke hardisk fisik komputer host, yang mana hal ini sangat krusial untuk mengamankan data aplikasi seperti basis data PostgreSQL. Fitur ini dapat diibaratkan seperti flashdisk atau hardisk eksternal yang dicolokkan ke sebuah laptop (yang diibaratkan sebagai container), di mana jika laptop tersebut rusak atau diganti dengan yang baru, data di dalam flashdisk tetap utuh dan tinggal disambungkan kembali.


Jawaban empat pertanyaan pada Langkah 2
Apa yang terjadi jika bagian volumes: pada layanan PostgreSQL dihapus, lalu container dihentikan menggunakan perintah docker compose down -v? Jika bagian volumes dihilangkan, maka penyimpanan data menjadi bersifat sementara dan hanya tersedia selama container berjalan. Saat container dihentikan dan dihapus (terutama menggunakan perintah down -v), semua data di dalam database (termasuk tabel, skema, dan catatan) akan hilang secara permanen. Dan saat container dihidupkan lagi, database akan kosong lagi seperti baru terinstal.

Mengapa pemetaan port ditulis "5432:5432" dan bukan cukup satu angka? Apa yang harus diubah apabila komputer Anda sudah memiliki PostgreSQL lain yang menggunakan port 5432?
Penulisan 5432:5432 artinya port 5432 di komputer diarahkan ke port 5432 di Docker. Angka pertama adalah port yang dipake komputer untuk ngeakses Docker, sedangkan angka kedua adalah port PostgreSQL di dalam container. Kalo komputer udah ada PostgreSQL yang memakai port 5432, maka akan bentrok karena satu port tidak bisa dipakai dua layanan sekaligus. Solusinya, ubah angka pertamanya, misalnya jadi 5433:5432, sehingga PostgreSQL di Docker tetap memakai port 5432, tapi dari komputer kita aksesnya dari port 5433.

Apa fungsi blok healthcheck? Mengapa healthcheck penting ketika terdapat layanan lain yang bergantung pada basis data?
Fungsi utama healthcheck itu untuk memverifikasi apakah aplikasi di dalam container benar-benar udah siap buat menerima koneksi atau instruksi, bukan cuman sekedar mengecek apakah container-nya itu udah berstatus running atau belum.
Hal ini bisa dibilang sangat penting karena waktu container database menyala atau hidup, sistem database di dalamnya itu masih butuh waktu beberapa detik untuk booting. Kalau ada layanan lain (misalnya aplikasi web) yang diatur buat langsung terkoneksi ke database waktu menyala, aplikasi nya itu bisa error atau crash karena dia mencoba menghubungi database yang proses booting-nya belum selesai.

Menyimpan password langsung di dalam docker-compose.yml merupakan praktik yang kurang baik. Sebutkan satu cara yang lebih aman dan jelaskan mengapa hal tersebut penting ketika berkas masuk ke repositori Git.
Cara yang lebih aman adalah memakai file .env. nantinya  password-nya disimpan di dalam file .env terlebih dulu, lalu nanti dipanggil di docker-compose.yml memakai variabel (contohnya POSTGRES_PASSWORD=${DB_PASSWORD}).
cara ini lebih baik karena file docker-compose.yml akan kita push ke Git supaya bisa diakses anggota tim yang lain. kalau password-nya ditulis secara langsung, otomatis semua orang yang buka repositori kita bisa melihat password database kita. dengan pakai file .env, password-nya akan aman di komputer masing-masing karena karena file .env akan dicegah agar tidak ikut terunggah oleh .gitignore.

Perbandingan penggunaan psql dan DBeaver
Belum ada

Hasil query V1
Plaintext
 count 
-------
    21
(1 row)
Hasil query V2
Plaintext
     relname      | ukuran  
------------------+---------
 rental           | 2352 kB
 film             | 952 kB
 payment_p2017_04 | 656 kB
 payment_p2017_03 | 568 kB
 film_actor       | 488 kB
 inventory        | 440 kB
 payment_p2017_02 | 296 kB
 payment_p2017_01 | 248 kB
 customer         | 216 kB
 address          | 160 kB
(10 rows)
Hasil query V3
Plaintext
        title        | total_sewa 
---------------------+------------
 BUCKET BROTHERHOOD  |         34
 ROCKETEER MOTHER    |         33
 RIDGEMONT SUBMARINE |         32
 SCALAWAG DUCK       |         32
 FORWARD TEMPLE      |         32
(5 rows)