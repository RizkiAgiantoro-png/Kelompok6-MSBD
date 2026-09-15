# Refleksi D

## Race Condition pada Pengecekan Manual

Pengecekan manual dengan SELECT sebelum INSERT dapat mengalami race condition.

Contoh:

T1 melakukan SELECT untuk mengecek apakah periode harga sudah digunakan.
T2 melakukan SELECT pada saat yang hampir bersamaan.

Keduanya dapat melihat bahwa belum ada data yang bertabrakan.

Kemudian:

T1 melakukan INSERT.
T2 juga melakukan INSERT.

Akibatnya, dua transaksi dapat memasukkan periode yang saling overlap meskipun
sebelumnya masing-masing transaksi sudah melakukan pengecekan.

## Mengapa EXCLUDE Lebih Aman

EXCLUDE constraint melakukan pengecekan integritas langsung pada level database.

Dengan menggunakan EXCLUDE USING gist, PostgreSQL dapat memastikan bahwa
kombinasi film_id dan wilayah yang sama tidak memiliki range berlaku yang overlap.

Dengan demikian, aturan tersebut tidak hanya bergantung pada urutan SELECT
dan INSERT dari aplikasi, sehingga lebih aman terhadap race condition.