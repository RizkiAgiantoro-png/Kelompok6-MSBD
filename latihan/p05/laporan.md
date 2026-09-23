# Laporan Latihan Kelompok Pertemuan 5

## Refleksi A

Pada Q3, transaksi dimulai dan diakhiri secara otomatis oleh PostgreSQL. Buktinya bisa dilihat dari jumlah data di tabel rental_tx. Saat pemanggilan procedure gagal akibat pelanggaran constraint nilai negatif pada pembayaran, baris data penyewaan sama sekali tidak bertambah. Ini membuktikan bahwa sistem database secara otomatis melakukan rollback terhadap seluruh perintah yang ada di dalam blok procedure tersebut.

Sedangkan pada Q4, transaksi dimulai oleh aplikasi luar, yaitu Python melalui library psycopg. Bukti dari hal ini adalah munculnya error invalid transaction termination ketika procedure mencoba melakukan perintah COMMIT di tengah-tengah eksekusi. Error ini membuktikan bahwa PostgreSQL menolak COMMIT dari dalam procedure karena ia mendeteksi transaksi tersebut dibuka oleh Python, sehingga yang berhak mengakhiri atau menutup transaksinya hanyalah Python itu sendiri, bukan basis datanya.

## Hasil Eksekusi Q06–Q09

### Q06 — Domain positive_amount
1. **Pengujian Nilai 0**:
   - **Query**: `INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (1, 0);`
   - **Pesan Galat**: `ERROR: value for domain lab5.positive_amount violates check constraint "positive_amount_check"`
   - **SQLSTATE**: `23514` (`check_violation`)
2. **Pengujian Nilai Negatif (-5.00)**:
   - **Query**: `INSERT INTO lab5.payment_tx (rental_id, amount) VALUES (1, -5.00);`
   - **Pesan Galat**: `ERROR: value for domain lab5.positive_amount violates check constraint "positive_amount_check"`
   - **SQLSTATE**: `23514` (`check_violation`)

### Q07 — Enum status
1. **Sebelum ALTER TYPE**:
   - **Query**: `UPDATE lab5.rental_tx SET status = 'EXPIRED' WHERE rental_id = 1;`
   - **Pesan Galat**: `ERROR: invalid input value for enum lab5.rental_status: "EXPIRED"`
   - **SQLSTATE**: `22P02` (`invalid_text_representation`)
2. **Penambahan Nilai Enum**:
   - **Perintah**: `ALTER TYPE lab5.rental_status ADD VALUE 'EXPIRED';`
   - **Hasil**: `ALTER TYPE`
3. **Sesudah ALTER TYPE**:
   - **Query**: `UPDATE lab5.rental_tx SET status = 'EXPIRED' WHERE rental_id = 1;`
   - **Hasil**: `UPDATE 1` (Status pada `rental_id = 1` berhasil diubah menjadi `'EXPIRED'`).

### Q08 — Array tags
- **Query**:
  ```sql
  UPDATE lab5.rental_tx SET tags = ARRAY['promo', 'akhir-pekan', 'anggota'] WHERE rental_id = 1;
  SELECT rental_id, tags FROM lab5.rental_tx WHERE 'promo' = ANY(tags);
  ```
- **Keluaran**:
  ```text
   rental_id |            tags             
  -----------+-----------------------------
           1 | {promo,akhir-pekan,anggota}
  (1 row)
  ```

### Q09 — JSONB metadata
- **Query**:
  ```sql
  UPDATE lab5.rental_tx SET metadata = '{"channel":"web","device":"android"}'::jsonb WHERE rental_id = 1;
  SELECT rental_id, metadata ->> 'channel' AS kanal FROM lab5.rental_tx WHERE rental_id = 1;
  ```
- **Keluaran**:
  ```text
   rental_id | kanal 
  -----------+-------
           1 | web
  (1 row)
  ```

## Refleksi B

Antara kolom `tags` (Array) dan `metadata` (JSONB):

- **Array (`tags`) vs JSONB (`metadata`)**:
  - `tags` (Array) cocok untuk daftar nilai homogen sederhana (seperti kata kunci/kategori) tanpa pasangan key-value atau hirarki.
  - `metadata` (JSONB) cocok untuk data tidak terstruktur atau semi-terstruktur opsional yang memiliki struktur key-value dinamis (misalnya `channel`, `device`, `app_version`) tanpa perlu mengubah skema tabel setiap ada penambahan atribut baru.

- **Kapan Data Dipindahkan Menjadi Tabel Relasional**:
  - Data dari kolom Array/JSONB sebaiknya dipindahkan menjadi tabel tersendiri jika:
    1. Diperlukan validasi Integritas Referensial (Foreign Key) terhadap tabel master data (misalnya memastikan tag yang diinput terdaftar pada tabel `master_tags`).
    2. Data tersebut sering di-JOIN dan di-agregasi secara intensif dengan tabel lain dalam query analitik.

- **Pertanyaan Bisnis yang Mengubah Keputusan**:
  - *"Apakah manajemen membutuhkan laporan analitik terpusat dengan validasi data tag/metadata yang ketat dan relasi ke entitas bisnis lainnya?"*
  - Jika ya, maka data `tags` atau `metadata` harus direfaktor/dipindahkan dari kolom array/JSONB ke tabel relasional terpisah (seperti `rental_tags` atau `rental_metadata_attributes`).

  ## Refleksi C

Q3 dan Q13 sama-sama menunjukkan rollback transaksi, tetapi mekanisme pemicunya berbeda.

Pada Q3, rollback dipicu oleh galat dari basis data ketika procedure menerima kondisi yang tidak valid. Pada Q13, rollback dipicu oleh exception yang dilempar dari sisi aplikasi Python sebelum transaksi selesai.

Persamaannya adalah perubahan yang masih berada dalam transaksi dibatalkan sehingga keadaan database kembali seperti sebelum transaksi.

Salah satu hal yang dapat dilakukan sisi aplikasi adalah menangkap exception dan menentukan bagaimana error tersebut diterjemahkan atau ditangani oleh alur aplikasi, misalnya mengubahnya menjadi respons atau pesan yang sesuai kepada pengguna.git status

## Refleksi D

### Q17–Q19

Pada Q17 digunakan lazy loading sehingga ketika relationship `rentals` diakses untuk setiap customer, SQLAlchemy menjalankan query tambahan untuk masing-masing customer. Dari hasil eksekusi terlihat 1 query untuk mengambil 10 customer dan 10 query tambahan untuk mengambil rental. Hal ini menunjukkan pola N+1 query.

Pada Q18 digunakan `selectinload()`. SQLAlchemy mengambil data customer menggunakan satu query dan data rental menggunakan satu query tambahan dengan kondisi `IN`. Dengan demikian, untuk 10 customer hanya digunakan 2 query utama.

Pada Q19 digunakan `joinedload()`. SQLAlchemy mengambil data customer dan rental menggunakan `LEFT OUTER JOIN` dalam satu query. Hasil log SQL menunjukkan bahwa relationship rental dimuat bersamaan dengan data customer.

### Q20

Q20 membandingkan hasil query untuk mencari lima film yang paling sering disewa menggunakan SQLAlchemy dan SQL mentah.

Hasil keduanya sama, yaitu:

1. BUCKET BROTHERHOOD: 34 rental
2. ROCKETEER MOTHER: 33 rental
3. GRIT CLOCKWORK: 32 rental
4. RIDGEMONT SUBMARINE: 32 rental
5. FORWARD TEMPLE: 32 rental

Waktu eksekusi SQLAlchemy:

`0.053829 detik`

Waktu eksekusi SQL mentah:

`0.054719 detik`

Hasil pengujian menunjukkan bahwa kedua pendekatan menghasilkan data yang sama dengan waktu eksekusi yang sangat berdekatan. SQLAlchemy memudahkan integrasi query dengan kode aplikasi, sedangkan SQL mentah memberikan kontrol langsung terhadap perintah SQL yang dijalankan.

`selectinload()` dapat digunakan ketika relationship ingin dimuat dengan query terpisah menggunakan `IN`, sedangkan `joinedload()` dapat digunakan ketika relationship ingin dimuat menggunakan JOIN dalam query utama. Pemilihan pendekatan bergantung pada kebutuhan query dan jumlah data yang diproses.