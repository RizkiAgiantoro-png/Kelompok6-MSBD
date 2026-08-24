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
