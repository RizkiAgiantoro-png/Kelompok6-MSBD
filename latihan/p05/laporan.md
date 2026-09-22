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