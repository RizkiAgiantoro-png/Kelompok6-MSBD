# Laporan Kelompok Pertemuan 4

## Identitas Kelompok

| Nama                       | NIM       | Kontribusi                                                   | Commit |
| -------------------------- | --------- | ------------------------------------------------------------ | ------ |
| Daffa Umayans Saragih      | 251402011 | Anggota 1: setup awal, Q1–Q4, refleksi A, migration 0041     | -      |
| Ramadiyan Athallah Kusuma  | 251402027 | Anggota 2: Q5–Q8, refleksi B, migration 0042                 | -      |
| Mochamad Rizki Agiantoro   | 251402135 | Anggota 4: Q14–Q17, refleksi D, migrations 0044–0045         | -      |
| Juda Benhur Turnip         | 251402096 | Anggota 5: Q18–Q21, README, laporan akhir, finalisasi branch | -      |
| Dennis Pamungkas Panjaitan | 251402076 | Anggota 3: Q9–Q13, refleksi C, migration 0043                | -      |

## Bab I. Setup Awal

Proses dimulai dengan memastikan Docker sudah hidup, lalu mengaktifkan container PostgreSQL dan MongoDB. Setelah itu, database inti dibangun dari dump Pagila yang sudah tersedia di folder `dump`, kemudian skema `lab4` dibuat untuk menampung eksperimen tanpa memodifikasi data asli di `public`.

Pada tahap setup, `lab4.film` dibuat dengan menyalin struktur dan isi dari `public.film`, lalu `lab4.jejak_akses` dibuat dengan 500000 baris data dummy. Hasilnya sesuai target: tabel jejak akses berisi 500000 record.

## Q1–Q4: View dan kontrol akses melalui view

### Q1

Kita membuat view `lab4.film_murah` untuk menampilkan film dengan `rental_rate <= 0.99`. View ini dibuat dalam bentuk sederhana tanpa `WITH CHECK OPTION`, agar perilaku dasar view bisa diamati.

### Q2

Setelah memasukkan satu baris melalui view dengan `rental_rate = 4.99`, baris itu masuk ke tabel dasar, tetapi tidak muncul di view. Hal ini terjadi karena view hanya menampilkan data yang memenuhi filter `rental_rate <= 0.99`.

### Q3

Saat view dibuat ulang dengan `WITH CASCADED CHECK OPTION`, insert yang melanggar filter ditolak. Error yang muncul adalah:

```text
ERROR:  new row violates check option for view "film_murah"
DETAIL:  Failing row contains (9998, Film Mahal Ditolak, null, null, null, null, null, 4.99, null, null, G, null, null, null).
```

### Q4

Pembuatan view agregat dengan `GROUP BY` pada `lab4.pendapatan_kategori` menghasilkan error saat insert. Error yang muncul adalah:

```text
ERROR:  cannot insert into view "pendapatan_kategori"
DETAIL:  Views containing GROUP BY are not automatically updatable.
HINT:  To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.
```

Dari sini bisa dilihat bahwa view yang menghasilkan agregasi tidak selalu bisa dipakai untuk operasi tulis tanpa bantuan trigger khusus.

## Refleksi A

Dari hasil Q1–Q4, ada beberapa keuntungan yang jelas jika aplikasi memakai view, terutama dari sisi keamanan dan pengelompokan logika. View bisa menyembunyikan kolom atau baris yang tidak boleh diakses dan membuat query lebih rapi. Namun, ada juga kekurangannya. View yang rumit atau yang memakai agregasi sering membuat proses insert dan update menjadi terbatas. Dalam praktik, pendekatan ini justru menyulitkan ketika aplikasi butuh menangani data yang berasal dari laporan analitik yang tidak auto-updatable.

## Q5–Q8: Materialized View

### Q5

Pada Q5, query agregasi diukur waktunya dengan `timing`. Tujuannya adalah melihat performa saat data diolah per bulan dan per kanal. Hasilnya menunjukkan bahwa query dengan grouping sederhana tetap bisa diukur dan dibandingkan, terutama saat data volume besar.

### Q6

Query Q5 dibuat menjadi materialized view dengan `WITH NO DATA`. Sebelum refresh, PostgreSQL menolak pembacaan karena view belum diisi. Error aslinya adalah:

```text
ERROR:  materialized view "lab4.ringkasan_akses" has not been populated
```

Setelah refresh biasa, materialized view terisi dan siap dipakai.

### Q7

Ketika mencoba `REFRESH MATERIALIZED VIEW CONCURRENTLY`, PostgreSQL menolak sebelum dibuat index unik pada materialized view. Setelah index dibuat, refresh concurrent bisa dijalankan.

### Q8

Eksperimen dua sesi dilakukan untuk membuktikan bahwa refresh concurrent tidak memblokir pembaca. Pada satu sesi, data baru diinsert dalam jumlah besar, lalu refresh dijalankan. Pada sesi lain, `SELECT count(*) FROM lab4.ringkasan_akses` tetap berjalan. Saat refresh biasa dijalankan, pembaca lebih sering terhambat karena lock yang lebih kuat.

## Refleksi B

Materialized view sangat memperhatikan kebutuhan data yang sering dibaca tetapi tidak perlu selalu dihasilkan dari query mentah. Namun, ia memerlukan jadwal refresh dan harus dijaga agar data tidak terlalu stale. Dalam praktik, kompromi yang paling masuk akal adalah membatasi kebaruan data pada interval tertentu, misalnya per beberapa menit atau per jam, lalu menyiapkan log atau alarm ketika refresh gagal. Ini menjaga performa tetap bagus tanpa menutup kebutuhan laporan yang akurat.

## Q9–Q13: Trigger Audit

### Q9

Kita membuat tabel `lab4.audit_harga`, fungsi trigger, dan trigger level baris yang mencatat perubahan `rental_rate`. Trigger memakai `AFTER UPDATE OF rental_rate` dan `WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)` agar tidak mencatat perubahan yang tidak relevan.

### Q10

Pengujian dilakukan pada tiga kondisi: perubahan harga, penetapan harga yang sama, dan perubahan title. Hanya perubahan yang benar-benar mengubah nilai `rental_rate` yang tercatat di tabel audit.

### Q11

Kita mengganti kondisi `IS DISTINCT FROM` menjadi `<>`, lalu menguji perubahan nilai `NULL`. Kondisi `<>` tidak menangani `NULL` dengan baik karena perbandingan terhadap NULL menghasilkan `UNKNOWN`, sehingga trigger tidak memicu seperti yang diharapkan.

### Q12

Pada Q12, update massal dilakukan dengan trigger aktif dan nonaktif. Waktu eksekusi trigger aktif lebih lama, yang menunjukkan overhead row-level trigger cukup signifikan saat banyak baris diubah.

### Q13

Pada Q13, trigger pernyataan dibuat memakai transition table. Dalam eksperimen ini, satu statement dapat diproses sekaligus, sehingga waktu yang dibutuhkan lebih rendah dibanding row-level trigger untuk banyak record.

## Refleksi C

Trigger baris tetap lebih tepat saat kita membutuhkan konteks tiap record secara spesifik, seperti mencatat data lama dan baru per baris. Sementara trigger pernyataan lebih cocok untuk proses massal yang ingin diubah sekaligus. Salah satu kemampuan yang tidak dimiliki trigger pernyataan adalah akses langsung ke `OLD` dan `NEW` per baris. Selain itu, mengirim email dari trigger tidak aman karena trigger berjalan di dalam transaksi. Jika transaksi di-rollback, efek eksternal seperti email tidak ikut dibatalkan, sehingga bisa menimbulkan inkonsistensi.

## Q14–Q17: Constraint sebagai kontrak data

### Q14

Constraint `CHECK (rental_rate >= 0)` ditambahkan dengan `NOT VALID`, lalu divalidasi. Saat data negatif masih ada, validasi gagal. Setelah data diperbaiki, validasi berhasil.

### Q15

Kita membandingkan `UNIQUE` biasa dengan partial unique index. Dalam skenario soft delete, `UNIQUE` biasa tidak cocok karena data yang sudah dihapus masih ikut menghalangi data baru dengan judul yang sama. Partial unique index dengan `WHERE deleted_at IS NULL` lebih tepat karena hanya data aktif yang harus unik.

### Q16

Pada foreign key, perilaku `NO ACTION`, `CASCADE`, dan `SET NULL` menunjukkan perbedaan yang jelas saat parent row dihapus. `NO ACTION` menolak penghapusan, `CASCADE` menghapus data child, dan `SET NULL` mengubah foreign key menjadi `NULL`.

### Q17

Tabel `harga_film` dibuat dengan constraint `EXCLUDE USING gist` agar rentang validitas harga tidak saling tumpang tindih untuk film dan wilayah yang sama. Insert pertama berhasil, sedangkan insert kedua yang overlap ditolak oleh PostgreSQL.

## Refleksi D

Trigger yang hanya membaca tabel sebelum insert bisa gagal saat dua transaksi berjalan bersamaan, karena masing-masing melihat kondisi yang sama pada waktu yang sama. `EXCLUDE` bekerja melalui index dan mekanisme integritas database yang sudah part of database engine, sehingga jauh lebih aman untuk menangani race condition dibanding validasi manual di aplikasi.

## Q18–Q21: Expand–Contract dan migrasi aman

### Q18

Pada fase expand, tabel `harga_film` dibuat dan trigger `film_dual_write` ditambahkan. Artinya, setiap perubahan `rental_rate` pada bentuk lama juga dicerminkan ke bentuk baru, sehingga aplikasi lama tetap dapat berjalan sambil struktur baru disiapkan.

### Q19

Backfill dilakukan dalam potongan 1000 film. Hasil verifikasi menunjukkan nol film yang belum memiliki data `harga_film` untuk wilayah `ID`.

```text
belum_ter_migrasi
-------------------
0
```

### Q20

Setelah view fasad dibuat dan dual-write dimatikan, kolom lama dihapus. Pada saat pembaca lama mencoba membaca `rental_rate` kembali, PostgreSQL mengembalikan error asli:

```text
ERROR:  column "rental_rate" does not exist
LINE 1: SELECT title, rental_rate FROM lab4.film LIMIT 5;
                      ^
```

Kesalahan ini menjadi bukti bahwa kontrak telah selesai: bentuk lama benar-benar tidak lagi terbaca setelah drop kolom, dan ini harus dijelaskan dalam laporan agar urutan tidak salah.

### Q21

Migrasi dibuat dalam format berversi untuk tiap langkah: expand, dual-write, backfill, verifikasi, fasad, dan drop kolom akhir. Catatan pentingnya adalah migration terakhir tidak bisa dipulihkan sepenuhnya, karena data lama `rental_rate` sudah dihapus dari tabel.

## Ringkasan waktu

| Tugas | Waktu | Penafsiran                                                         |
| ----- | ----: | ------------------------------------------------------------------ |
| Q5    |     - | Query agregasi berjalan sesuai kebutuhan dasar                     |
| Q6    |     - | Refresh biasa diperlukan agar materialized view terisi             |
| Q7    |     - | Refresh concurrent hanya bisa dijalankan setelah index unik dibuat |
| Q12   |     - | Row-level trigger memiliki overhead yang nyata                     |
| Q13   |     - | Statement-level trigger lebih efisien pada perubahan massal        |

## Migration dan commit

- 0041: membuat tabel harga baru
- 0042: trigger dual-write
- 0043: backfill bertahap
- 0044: verifikasi hasil migrasi
- 0045: view fasad
- 0046: drop kolom lama

## Catatan akhir

Semua tahapan dilakukan dengan tetap menjaga data asli di `public` aman. Seluruh eksperimen dan migrasi dikerjakan di skema `lab4`, yang menjadi prinsip utama dalam latihan ini. Proyek ini bukan sekadar soal query, tetapi juga tentang menjaga konsistensi data ketika struktur database berubah dalam proses yang aman dan terukur.
