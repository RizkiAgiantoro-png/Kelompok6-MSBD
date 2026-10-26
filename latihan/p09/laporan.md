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