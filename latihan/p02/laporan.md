Laporan Praktikum Manajemen Sistem Basis Data - Latihan 2
Topik: Dari Kebutuhan ke Skema Berversi (Database Migration & Evolution)

1. Nama Domain dan Alasan Pemilihan

Domain: Sistem Manajemen Peminjaman Alat Laboratorium.

Alasan Pemilihan: kami memilih ii karena jauh lebih mudah untuk dibayangkan pak kayak nanti entitas-entitasnya mudah dibayangkan (Anggota, Alat, Transaksi). ada kompleksitas relasi Many-to-Many (M:N) dan  memiliki aturan bisnis nyata (seperti pelacakan kondisi alat fisik berdasarkan nomor seri, bukan sekadar jenis barang).

2. Ringkasan Lingkup Sistem

Termasuk (In-Scope):

Manajemen katalog master alat dan kategori.

Manajemen inventaris unit fisik alat (berdasarkan nomor seri/kode unik).

Proses transaksi peminjaman (header) dan detail item yang dipinjam (baris pinjam).

Proses pengembalian beserta pencatatan kondisi unit alat saat dikembalikan.

Tidak Termasuk (Out-of-Scope):

Proses pengadaan/pembelian alat laboratorium baru dari vendor.

Modul pembayaran denda finansial (hanya mencatat status keterlambatan/kerusakan).

Integrasi dengan Sistem Informasi Akademik (SIA) atau penjadwalan kelas praktikum.

3. Ringkasan Kebutuhan Data
Sistem ini dirancang untuk mengakomodasi 8 kebutuhan data (KD) utama:

KD-01 Data Kategori: Pengelompokan jenis alat (misal: Elektronika, Alat Ukur).

KD-02 Katalog Alat: Spesifikasi umum alat (merek, tipe, deskripsi).

KD-03 Unit Fisik Alat: Pencatatan inventaris fisik individual yang memuat nomor seri dan kondisi spesifik.

KD-04 Data Anggota: Mahasiswa atau staf yang memiliki hak akses untuk meminjam alat.

KD-05 Header Peminjaman: Data transaksi utama (tanggal pinjam, tenggat waktu, peminjam).

KD-06 Baris Peminjaman (Detail): Data item spesifik (unit fisik) yang dipinjam dalam satu transaksi peminjaman.

KD-07 Pengembalian Alat: Pembaruan status transaksi saat alat dikembalikan (termasuk tanggal kembali aktual).

KD-08 Riwayat Kerusakan: Pencatatan perubahan status unit alat jika dikembalikan dalam keadaan rusak/perlu perbaikan.

4. Penjelasan Singkat ERD
ERD dirancang dengan pemisahan konseptual yang tegas antara Katalog Alat dan Unit Fisik Alat. Hubungan peminjaman tidak ditarik langsung ke Katalog Alat, melainkan ke Unit Fisik Alat melalui entitas asosiatif Baris Peminjaman. Hal ini menyelesaikan masalah relasi Many-to-Many sehingga sistem dapat melacak secara akurat unit fisik mana (dengan nomor seri berapa) yang dipinjam, dikembalikan, atau rusak dalam suatu transaksi.

5. Status Migration & Bukti Rebuild

Status Migration: Seluruh skrip migrasi Flyway (V1 hingga V5) telah dieksekusi dengan status Success ke dalam database proyek_dev yang di-host pada container PostgreSQL.

Bukti Rebuild: Database berhasil direplikasi ulang dari nol. Penghapusan database (DROP DATABASE proyek_dev), pembuatan ulang (CREATE DATABASE proyek_dev), dan eksekusi skema dari awal berjalan tanpa error maupun anomali, membuktikan bahwa skrip bersifat reproducible. (Telah dilampirkan pada bukti/rebuild-database.png).

6. Bukti Pola Tiga Langkah NOT NULL
Penerapan constraint NOT NULL pada kolom baru dilakukan menggunakan pola evolusi 3 langkah (Zero Downtime Migration Pattern) untuk mencegah kerusakan pada data yang sudah ada:

Langkah 1 (V3): Menambahkan kolom petugas dengan sifat nullable (mengizinkan NULL).

Langkah 2 (V4): Mengisi (backfill) baris data lama yang nilai petugas-nya masih NULL dengan nilai default menggunakan perintah UPDATE.

Langkah 3 (V5): Menerapkan constraint ALTER TABLE ... ALTER COLUMN petugas SET NOT NULL; secara aman karena tidak ada lagi baris data yang kosong.

7. Hasil Seed Data Idempoten
Skrip seed data (01_master_data.sql) ditulis menggunakan klausa ON CONFLICT (kolom_unik) DO UPDATE. Skrip ini terbukti idempoten. Saat dieksekusi melalui loop di terminal secara berulang (2 kali), data tidak mengalami duplikasi. Hasil penghitungan baris (SELECT count(*)) pada tabel kategori dan anggota tetap konsisten di angka 3. (Telah dilampirkan pada bukti/seed-data.png).

8. Pengamatan dari pg_stat_activity (Eksperimen Locking)
Eksperimen database locking berhasil disimulasikan menggunakan 3 sesi terminal yang saling independen:

Terminal 1: Membuka transaksi (BEGIN) pada tabel peminjaman tanpa melakukan COMMIT.

Terminal 2: Menjalankan ALTER TABLE peminjaman ADD COLUMN catatan text;. Perintah ini tertahan (hang) karena menunggu pelepasan kunci (lock) dari Terminal 1.

Terminal 3 (pg_stat_activity): Terpantau jelas bahwa proses dari Terminal 2 berstatus active namun tertahan dengan wait_event_type berupa Lock dan wait_event berupa relation, menunjukan tabel sedang dikunci secara eksklusif. (Telah dilampirkan pada bukti/pg-stat-activity.png).

9. Jawaban Pertanyaan Evaluasi

Pertanyaan 1:
Mengapa kita tidak melakukan pengujian langsung pada basis data proyek utama? Mengapa perlu dibuat proyek_test?
Jawaban: Pengujian seringkali melibatkan manipulasi data (penambahan data dummy, modifikasi, atau bahkan penghapusan). Memisahkan environment ke proyek_test memastikan bahwa data pengujian yang "kotor" ini tidak merusak integritas data pengembangan (proyek_dev) atau produksi.

Pertanyaan 2:
Kebutuhan data mana yang memiliki aturan paling rumit? Apakah lebih tepat ditegakkan dengan constraint basis data atau logika aplikasi?
Jawaban: KD-07 Pengembalian Alat memiliki aturan paling rumit. Proses ini melibatkan banyak logika lintas tabel: mencatat tanggal kembali, mengubah status ketersediaan unit alat fisik menjadi "Tersedia" atau "Rusak", dan memvalidasi keterlambatan. Aturan ini jauh lebih tepat dikelola menggunakan kode aplikasi (Application Logic) karena logika ini melibatkan alur bisnis dinamis yang terlalu kaku dan kompleks jika dipaksakan menggunakan Trigger atau Constraint di level database.

Pertanyaan 3:
Jelaskan mengapa Anda menggunakan entitas asosiatif (jika ada relasi many-to-many).
Entitas asosiatif (Baris Peminjaman) digunakan karena satu transaksi peminjaman bisa mencakup banyak alat, dan satu alat bisa dipinjam berkali-kali di transaksi berbeda. Entitas asosiatif ini krusial untuk menyimpan atribut spesifik per item, seperti "Kondisi Alat Saat Kembali" yang jelas berbeda untuk setiap alat meskipun dipinjam pada nomor transaksi yang sama.

Pertanyaan 4:
Apakah Anda memisahkan entitas KATALOG BARANG dan UNIT FISIK BARANG? Berikan contoh pertanyaan bisnis yang hanya bisa dijawab dari pemisahan ini.
kami memisahkannya pak karena  Katalog adalah model (contoh: Osiloskop Analog Tipe X), sedangkan Unit Fisik adalah wujud nyata barang tersebut (contoh: Osiloskop Tipe X dengan Nomor Seri OS-001).
Pertanyaan bisnis yang bisa dijawab: "Berapa kali Osiloskop dengan nomor seri OS-001 mengalami kerusakan sepanjang tahun ini dibandingkan dengan Osiloskop bernomor seri OS-002?"

Pertanyaan 5:
Apa yang terjadi jika Anda mengubah file migrasi V1 setelah dijalankan dan menjalankan kembali Flyway? Bagaimana cara memperbaiki kesalahan skema secara historis?
Flyway akan gagal berjalan dan mengeluarkan error checksum mismatch karena hash file V1 yang baru tidak cocok dengan catatan hash V1 yang sudah tersimpan di tabel flyway_schema_history. Cara yang benar adalah tidak mengubah file V1 yang sudah terlanjur dieksekusi, melainkan membuat file migrasi baru (misalnya V6__perbaikan_tabel_x.sql) yang berisi perintah ALTER untuk memperbaiki struktur tersebut.

Pertanyaan 6:
Berdasarkan eksperimen locking, apa dampaknya jika migrasi struktur (ALTER TABLE) tertahan di lingkungan produksi?
Jika migrasi tertahan di tahap produksi, perintah ALTER TABLE tersebut akan memaksa seluruh transaksi lain (seperti Insert atau Select dari user) untuk ikut mengantre di belakangnya. Akibatnya, koneksi database akan menumpuk, timeout akan terjadi di sisi aplikasi, dan sistem akan mengalami downtime atau kelumpuhan sementara hingga lock tersebut dilepaskan.

Pertanyaan 7:
Jelaskan perbedaan mendasar antara skrip Migration dan skrip Seed Data secara fungsionalitas dan karakteristik operasionalnya.
Jawaban:

Migration: Berisi perintah DDL (Data Definition Language) untuk membangun/mengubah arsitektur tabel. Bersifat historis, dikelola oleh versi, dan secara ketat hanya boleh dieksekusi satu kali.

Seed Data: Berisi perintah DML (Data Manipulation Language) untuk menyuntikkan data master/awal. Bersifat idempoten (menggunakan On Conflict Do Update), sehingga aman jika dieksekusi puluhan kali tanpa menyebabkan error atau duplikasi baris.

Daftar Kontribusi Anggota Kelompok

Mochamad Rizki Agiantoro (251402135): Menyusun dokumen perancangan Kebutuhan Data (kebutuhan.md).

Ramadiyan Athallah Kusuma (251402027): Merancang Entity Relationship Diagram dan mengekspor hasilnya (erd.png dan erd.md).

Juda Benhur Turnip (251402096): Membuat skrip migrasi awal pembentukan tabel (V1 dan V2) serta melakukan pengujian rebuild database.

Dennis Pamungkas Panjaitan (251402076): Membuat skrip evolusi skema 3 langkah (V3, V4, V5) untuk penerapan constraint NOT NULL dan melakukan eksperimen database locking.

Daffa Umayans Saragih (251402011): Melakukan perbaikan konfigurasi Docker Compose, mengimplementasikan skrip Seed Data idempoten, mengeksekusi migrasi, serta menyusun konsolidasi laporan akhir.