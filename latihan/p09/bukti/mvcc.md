Bukti Eksekusi Langkah 3 (Q12 - Q17)
Mencegah Lost Update dan Memahami MVCC

Q12 & Q13: Mencegah Lost Update (Atomic Update & SELECT FOR UPDATE)
Sesi A mengunci baris dengan FOR UPDATE. Sesi B mencoba FOR UPDATE pada baris yang sama. Sesi B tertahan.
Setelah Sesi A commit, Sesi B baru melanjutkan eksekusi dan mendapatkan nilai terkini untuk dikalkulasi.
Kesimpulan: FOR UPDATE mengunci baris secara eksplisit (Pessimistic Locking) sehingga mencegah transaksi lain menimpa data di saat bersamaan.

Q14: Optimistic Concurrency Control
Sesi A membaca saldo 950000. Sesi B langsung UPDATE tanpa lock menjadi 900000.
Sesi A mencoba UPDATE dengan kondisi WHERE saldo = 950000. Karena nilai sudah berubah, UPDATE Sesi A menghasilkan "UPDATE 0" (tidak ada baris yang di-update).
Kesimpulan: Aplikasi bisa mengetahui data telah berubah dengan mengecek jumlah baris yang berhasil di-update. Jika 0, berarti data sudah kadaluarsa (Stale Data).

Q15 & Q16: MVCC dan Metadata Transaksi
Sesi A mengubah saldo tanpa commit.
Sesi B menjalankan SELECT biasa dan langsung melihat data lama tanpa harus menunggu Sesi A selesai (tidak tertahan lock).
Dari hasil SELECT xmin dan xmax, terlihat bahwa Sesi B membaca versi tupel (baris) yang lama, sementara Sesi A memegang versi tupel yang baru dengan xmax yang mengarah ke ID transaksi Sesi A.
Kesimpulan: Pembaca (SELECT) tidak memblokir Penulis (UPDATE), dan Penulis tidak memblokir Pembaca, berkat Multi-Version Concurrency Control (MVCC).