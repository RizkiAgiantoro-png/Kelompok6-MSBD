Langkah 2 (Q6 sampai Q11)

Q6 Non-repeatable read
Pada tingkat isolasi bawaan yaitu READ COMMITTED, data yang sama dapat dibaca dengan nilai yang berbeda dalam satu transaksi jika transaksi lain telah mengubah data tersebut dan melakukan COMMIT. Saat Sesi A melakukan SELECT pertama, saldonya 1000000. Setelah Sesi B mengubahnya menjadi 900000 dan melakukan auto-commit, SELECT kedua di Sesi A membaca saldo baru yaitu 900000.

Q7 Perbandingan isolation
Ketika Sesi A menggunakan tingkat isolasi REPEATABLE READ, data akan ditahan dalam sebuah snapshot sejak kueri pertama dijalankan. Walaupun Sesi B berhasil melakukan UPDATE dan COMMIT menjadi 800000, Sesi A akan tetap membaca nilai 1000000 pada SELECT keduanya. Perbedaan mendasarnya adalah REPEATABLE READ menjamin data yang dibaca tetap konsisten sepanjang transaksi berlangsung.

Q8 Phantom read
Pada READ COMMITTED, Sesi A mengalami phantom read. Saat Sesi A menghitung baris di tengah transaksi, Sesi B memasukkan baris baru. Pembacaan kedua oleh Sesi A melihat baris "siluman" tersebut. Namun, saat diuji menggunakan REPEATABLE READ, Sesi A tidak melihat baris baru yang dimasukkan Sesi B. Hal ini membuktikan bahwa arsitektur MVCC pada PostgreSQL mampu mencegah phantom read pada level REPEATABLE READ, membuat level ini jauh lebih kuat dari standar SQL tradisional.

Q9 Dirty read
Sesi B mencoba membaca data dengan mengatur isolasi menjadi READ UNCOMMITTED. Saat Sesi A mengubah data tanpa melakukan COMMIT, Sesi B ternyata tidak dapat melihat perubahan tersebut. Perilaku ini terjadi karena mesin PostgreSQL dirancang untuk tidak mendukung Dirty Read sama sekali. Level READ UNCOMMITTED di dalam PostgreSQL otomatis dieksekusi sebagai READ COMMITTED.

Q10 Lost update
Lost update berhasil direproduksi ketika dua transaksi membaca nilai yang sama, memproses kalkulasi secara terpisah di luar database, lalu menuliskannya kembali sebagai nilai absolut. Sesi A ingin mengurangi 100000 dan Sesi B ingin mengurangi 50000. Keduanya mengira saldo awal 1000000, sehingga Sesi A menembak angka 900000 dan Sesi B menembak angka 950000. Karena Sesi B dieksekusi belakangan (setelah lock Sesi A dilepas), tulisan Sesi A sebesar 900000 hilang ditelan oleh tulisan Sesi B sebesar 950000.

Q11 Tabel Ringkasan Anomali
1. Non-repeatable read: Sesi A baca, Sesi B update+commit, Sesi A baca lagi nilainya beda. Isolation level yang diamati adalah READ COMMITTED. Cara mencegahnya adalah dengan menaikkan isolasi ke REPEATABLE READ.
2. Phantom read: Sesi A hitung baris, Sesi B insert+commit, Sesi A hitung lagi jumlahnya bertambah. Isolation level yang diamati adalah READ COMMITTED. Cara mencegahnya adalah menggunakan REPEATABLE READ.
3. Dirty read: Sesi A update (tanpa commit), Sesi B baca data. Di PostgreSQL tidak bisa diamati karena dicegah otomatis secara internal, meskipun Sesi B menggunakan READ UNCOMMITTED.
4. Lost update: Sesi A dan B baca data bersamaan, lalu update dengan nilai absolut secara berurutan menimpa satu sama lain. Isolation level yang diamati adalah READ COMMITTED. Cara mencegahnya adalah dengan melakukan update relatif (saldo = saldo - x) di level database, menggunakan SELECT FOR UPDATE, atau menaikkan level ke REPEATABLE READ/SERIALIZABLE.

Langkah 3 (Q12 sampai Q17)

Q12 Perbaikan Lost Update (Atomic Update)
Menghitung berdasarkan nilai kolom di database (misal: saldo = saldo - 10000) jauh lebih aman daripada membaca nilai, menghitung di aplikasi, lalu menulis nilai absolut (misal: saldo = 900000). Atomic update memastikan bahwa database menggunakan nilai terakhir yang ada di disk tepat pada saat UPDATE dieksekusi, sehingga perubahan dari transaksi lain yang masuk sepersekian detik sebelumnya tidak tertimpa begitu saja.

Q13 SELECT ... FOR UPDATE (Pessimistic Locking)
Ketika Sesi A mengeksekusi SELECT ... FOR UPDATE, Sesi B yang menjalankan perintah serupa akan langsung berstatus *waiting* (menunggu). Sesi B baru akan melanjutkan proses pencarian dan pengunciannya segera setelah Sesi A mengeksekusi COMMIT atau ROLLBACK. Cara ini sangat efektif untuk skenario antrean di mana kita ingin memastikan hanya satu transaksi yang dapat memanipulasi baris tertentu pada satu waktu.

Q14 Optimistic Locking dengan Kondisi Nilai
Jika tidak ingin menggunakan FOR UPDATE yang menahan transaksi (blocking), kita bisa menambahkan kondisi nilai yang dibaca pada klausa WHERE (misalnya WHERE rekening_id = 2 AND saldo = 950000). Jika transaksi lain sudah mengubah saldo tersebut, kueri UPDATE ini akan mengembalikan "UPDATE 0". Aplikasi kemudian mengetahui bahwa data sudah berubah, lalu dapat melakukan pembatalan atau mengulangi proses (retry).

Q15 MVCC (Multi-Version Concurrency Control)
Secara konseptual, saat terjadi UPDATE, PostgreSQL tidak menimpa data asli di tempat. Alih-alih, ia membuat "versi baru" dari baris tersebut. Transaksi yang sedang berjalan (Sesi A) melihat versi baru ini. Transaksi lain (Sesi B) yang melakukan SELECT akan diarahkan untuk membaca "versi lama" yang masih valid untuk snapshot mereka. Inilah sebabnya pembaca (SELECT) tidak perlu menunggu penulis (UPDATE) selesai.

Q16 Metadata xmin dan xmax
Kolom xmin menyimpan ID transaksi yang menciptakan (INSERT/UPDATE) versi baris tersebut, sedangkan xmax menyimpan ID transaksi yang menghapus atau menimpa (UPDATE/DELETE) baris tersebut. Keduanya adalah metadata internal mesin PostgreSQL. Satu nilai saja tidak cukup untuk mendiagnosis visibilitas karena kita harus mencocokkannya dengan daftar transaksi yang sedang aktif (pg_stat_activity) untuk mengetahui apakah xmax tersebut berasal dari transaksi yang sudah di-commit atau masih menggantung.

Q17 Manfaat MVCC dan Vacuum
Manfaat utama MVCC adalah performa konkurensi yang sangat tinggi karena operasi baca dan tulis tidak saling mengunci. Namun, karena UPDATE membuat versi baris baru, versi baris lama (dead tuples) akan terus menumpuk di dalam disk (tabel bloat). Oleh karena itu, proses VACUUM sangat diperlukan untuk menyapu bersih versi-versi baris lama yang sudah tidak lagi terlihat oleh transaksi mana pun, agar ruang penyimpanannya bisa digunakan kembali.

Langkah 4 (Q18 sampai Q23)

Q18 Perbandingan row lock
FOR UPDATE: kunci terkuat. Dipakai saat baris akan di-UPDATE/DELETE atau kunci/kolom kuncinya bisa berubah. Memblokir transaksi lain yang mau UPDATE, DELETE, FOR UPDATE, FOR NO KEY UPDATE, FOR SHARE, maupun FOR KEY SHARE pada baris yang sama.
FOR NO KEY UPDATE: seperti FOR UPDATE tetapi lebih lemah; dipakai saat baris akan diubah tanpa mengubah kolom kunci (PRIMARY KEY/UNIQUE yang dirujuk FK). Tidak memblokir FOR KEY SHARE, jadi insert pada tabel anak (FK) tetap bisa jalan. Ini kunci yang diambil UPDATE biasa.
FOR SHARE: kunci bersama; beberapa transaksi boleh memegang FOR SHARE sekaligus, dipakai agar baris tidak berubah selama dibaca. Memblokir UPDATE, DELETE, FOR UPDATE, FOR NO KEY UPDATE.
FOR KEY SHARE: kunci terlemah, hanya menjaga kunci baris tidak berubah/terhapus (dipakai internal oleh foreign key). Hanya diblokir oleh FOR UPDATE (dan DELETE / UPDATE yang mengubah kunci).

Q19 FOR UPDATE pada baris yang sama
Sesi A BEGIN lalu SELECT rekening 1 FOR UPDATE: langsung berhasil. Sesi B menjalankan perintah yang sama dan menggantung (menunggu), tidak ada hasil dan tidak ada error. Setelah Sesi A COMMIT, Sesi B langsung mendapat hasil dan memegang kunci. Artinya satu baris hanya bisa dikunci satu transaksi dalam satu waktu.

Q20 Deadlock
Sesi A mengunci rekening 1, Sesi B mengunci rekening 2. Sesi A minta rekening 2 (menunggu B), Sesi B minta rekening 1 (menunggu A): saling menunggu, tidak ada yang bisa maju. Setelah deadlock_timeout (1 detik) PostgreSQL mendeteksi siklus ini dan membatalkan salah satu transaksi dengan ERROR: deadlock detected, SQLSTATE 40P01. Transaksi yang lain lalu bisa lanjut. [ISI: sesi mana yang kena error pada percobaan kami:B. Sesi yang error wajib ROLLBACK.

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
Skenario sama dengan SERIALIZABLE: kedua sesi membaca count = 2 sebelum ada yang COMMIT. Salah satu transaksi dibatalkan dengan ERROR: could not serialize access due to read/write dependencies among transactions, SQLSTATE 40001, HINT: The transaction might succeed if retried. [ISI: sesi/ pernyataan mana yang kena error: ___ ]. Hasil akhir hanya satu dokter nonaktif, aturan terjaga. Transaksi yang gagal harus di-ROLLBACK lalu diulang dari awal.

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