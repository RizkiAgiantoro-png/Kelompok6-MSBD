Langkah 4 (Q18 sampai Q23)

Q18 Perbandingan row lock
FOR UPDATE: kunci terkuat. Dipakai saat baris akan di-UPDATE/DELETE atau kunci/kolom kuncinya bisa berubah. Memblokir transaksi lain yang mau UPDATE, DELETE, FOR UPDATE, FOR NO KEY UPDATE, FOR SHARE, maupun FOR KEY SHARE pada baris yang sama.
FOR NO KEY UPDATE: seperti FOR UPDATE tetapi lebih lemah; dipakai saat baris akan diubah tanpa mengubah kolom kunci (PRIMARY KEY/UNIQUE yang dirujuk FK). Tidak memblokir FOR KEY SHARE, jadi insert pada tabel anak (FK) tetap bisa jalan. Ini kunci yang diambil UPDATE biasa.
FOR SHARE: kunci bersama; beberapa transaksi boleh memegang FOR SHARE sekaligus, dipakai agar baris tidak berubah selama dibaca. Memblokir UPDATE, DELETE, FOR UPDATE, FOR NO KEY UPDATE.
FOR KEY SHARE: kunci terlemah, hanya menjaga kunci baris tidak berubah/terhapus (dipakai internal oleh foreign key). Hanya diblokir oleh FOR UPDATE (dan DELETE / UPDATE yang mengubah kunci).

Q19 FOR UPDATE pada baris yang sama
Sesi A BEGIN lalu SELECT rekening 1 FOR UPDATE: langsung berhasil. Sesi B menjalankan perintah yang sama dan menggantung (menunggu), tidak ada hasil dan tidak ada error. Setelah Sesi A COMMIT, Sesi B langsung mendapat hasil dan memegang kunci. Artinya satu baris hanya bisa dikunci satu transaksi dalam satu waktu.

Q20 Deadlock
Sesi A mengunci rekening 1, Sesi B mengunci rekening 2. Sesi A minta rekening 2 (menunggu B), Sesi B minta rekening 1 (menunggu A): saling menunggu, tidak ada yang bisa maju. Setelah deadlock_timeout (1 detik) PostgreSQL mendeteksi siklus ini dan membatalkan salah satu transaksi dengan ERROR: deadlock detected, SQLSTATE 40P01. Transaksi yang lain lalu bisa lanjut. Pada percobaan kami, Sesi B yang dibatalkan (40P01), sedangkan Sesi A lalu memperoleh kunci rekening 2.. Sesi yang error wajib ROLLBACK.

Q21 Urutan penguncian konsisten
Jika semua sesi mengunci dari rekening_id terkecil ke terbesar (1 lalu 2), Sesi B akan menunggu di rekening 1 dan tidak memegang rekening 2 saat menunggu. Tidak ada siklus tunggu, jadi tidak terjadi deadlock; B hanya menunggu sebentar lalu lanjut setelah A COMMIT. Deadlock dapat dihindari pada skenario ini.

Q22 Deadlock vs antrean lock panjang
Deadlock: siklus saling tunggu, tidak akan selesai sendiri; PostgreSQL memutus dengan membatalkan satu transaksi (40P01). Antrean lock panjang: tidak ada siklus; sesi menunggu transaksi lain yang masih menahan lock (misalnya transaksi yang di-BEGIN, UPDATE, lalu dibiarkan terbuka tanpa COMMIT). Tidak ada error; sesi lain menggantung selama pemegang lock belum selesai. Pada percobaan, Sesi A UPDATE rekening 1 tanpa COMMIT, Sesi B UPDATE baris yang sama menggantung, dan pg_blocking_pids menunjukkan B diblokir oleh pid A. Selesai begitu A COMMIT/ROLLBACK. Mitigasi: transaksi dibuat singkat, lock_timeout, idle_in_transaction_session_timeout.

Q23 Perbandingan timeout
lock_timeout: batas waktu menunggu untuk mendapatkan lock; lewat dari itu perintah dibatalkan (55P03). Default 0 (tanpa batas).
statement_timeout: batas waktu eksekusi satu pernyataan secara keseluruhan; lewat dari itu dibatalkan (57014). Default 0.
idle_in_transaction_session_timeout: batas waktu sesi yang sudah BEGIN tetapi diam tanpa perintah; sesi diputus (25P03). Berguna melawan transaksi yang lupa COMMIT dan menahan lock.
deadlock_timeout: berapa lama sesi menunggu lock sebelum PostgreSQL mulai memeriksa apakah terjadi deadlock (default 1 detik). Ini bukan batas membatalkan permintaan lock biasa, hanya pemicu pemeriksaan deadlock.

Langkah 5 (Q24 sampai Q29)

Q24 SKIP LOCKED
Sesi A mengunci baris id=1 (FOR UPDATE). Sesi B menjalankan SELECT ... FOR UPDATE SKIP LOCKED LIMIT 1 dan langsung mendapat baris id=2; baris id=1 yang terkunci dilewati, tanpa menunggu. Kegunaan: worker antrean. Banyak worker bisa mengambil pekerjaan berbeda secara paralel tanpa saling menunggu dan tanpa mengambil pekerjaan yang sama.

Q25 NOWAIT
Sesi B menjalankan SELECT ... FOR UPDATE NOWAIT pada baris id=1 yang dikunci Sesi A: langsung gagal dengan ERROR: could not obtain lock on row in relation "antrean" (SQLSTATE 55P03), tanpa menunggu. Cocok bila aplikasi lebih baik gagal cepat dan memberi pesan "sedang diproses" daripada menggantung. Transaksi B harus di-ROLLBACK.

Q26 Write skew (REPEATABLE READ)
Aturan: minimal satu dokter aktif. Sesi A dan B sama-sama membaca jumlah dokter aktif = 2. A menonaktifkan dokter 1 lalu COMMIT, B menonaktifkan dokter 2 lalu COMMIT. Keduanya berhasil karena mengubah baris berbeda (tidak ada konflik tulis) dan masing-masing membaca snapshot lama. Hasil akhir: 0 dokter aktif, aturan bisnis dilanggar. Inilah write skew; REPEATABLE READ tidak mencegahnya.

Q27 SERIALIZABLE
Skenario sama dengan SERIALIZABLE: kedua sesi membaca count = 2 sebelum ada yang COMMIT. Salah satu transaksi dibatalkan dengan ERROR: could not serialize access due to read/write dependencies among transactions, SQLSTATE 40001, HINT: The transaction might succeed if retried. Pada percobaan kami, Sesi B yang gagal, tepat saat menjalankan UPDATE (Reason code: Canceled on identification as a pivot, during write), sedangkan COMMIT Sesi A berhasil.. Hasil akhir hanya satu dokter nonaktif, aturan terjaga. Transaksi yang gagal harus di-ROLLBACK lalu diulang dari awal.

Q28 SIReadLock
SIReadLock adalah predicate lock yang dicatat PostgreSQL pada transaksi SERIALIZABLE untuk melacak apa yang dibaca (tabel/halaman/baris). Ia bukan lock yang memblokir; transaksi lain tidak menunggu karenanya. Gunanya agar PostgreSQL bisa mendeteksi ketergantungan baca-tulis antar transaksi yang membentuk pola berbahaya (pivot), lalu membatalkan salah satu bila hasilnya tidak setara dengan eksekusi serial. Karena itu SERIALIZABLE tidak sama dengan FOR UPDATE: FOR UPDATE benar-benar memblokir, sedangkan SERIALIZABLE hanya mencatat dan mendeteksi (optimistic), sehingga konkurensi tetap tinggi tetapi ada kemungkinan gagal 40001. Bukti: query pg_locks WHERE mode='SIReadLock' menampilkan lock pada tabel dokter_jaga.

Q29 Pseudocode retry
```
MAX_RETRY = 5
BASE_DELAY_MS = 50
for attempt in 1..MAX_RETRY:
    try:
        BEGIN
        ... jalankan seluruh transaksi (SELECT + UPDATE) ...
        COMMIT
        kirim_email()        # efek eksternal hanya SETELAH commit berhasil
        return sukses
    except SQLSTATE in ('40001', '40P01'):
        ROLLBACK
        if attempt == MAX_RETRY: raise error
        delay = BASE_DELAY_MS * 2^(attempt-1)
        sleep(random(0, delay))        # exponential backoff + jitter
    except error_lain:
        ROLLBACK
        raise
```
Seluruh transaksi diulang dari BEGIN (bukan hanya pernyataan yang gagal) karena snapshot dan keputusan sebelumnya sudah tidak valid. Jitter mencegah beberapa sesi mengulang bersamaan dan bentrok lagi. Email/notifikasi dikirim setelah COMMIT karena jika dikirim di dalam transaksi lalu transaksi di-rollback atau di-retry, email sudah terkirim padahal data tidak tersimpan, atau terkirim berkali-kali. ROLLBACK database bisa dibatalkan, email tidak.
