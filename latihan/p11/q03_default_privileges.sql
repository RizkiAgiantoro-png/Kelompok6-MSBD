-- Diminta: membuat tabel baru sebagai postgres di skema lab11 dan memeriksa akses app_laporan.
-- Dipilih: menguji hak akses tabel baru di bawah pembuat postgres vs skema_owner.
-- Alternatif: membuat tabel di skema public; tidak dipilih karena harus menggunakan skema lab11.

CREATE TABLE lab11.catatan_postgres (id int);

SELECT has_table_privilege('app_laporan','lab11.catatan_postgres','SELECT') AS via_postgres;

DROP TABLE lab11.catatan_postgres;

-- Penjelasan: Tabel yang dibuat oleh skema_owner otomatis bisa dibaca oleh app_laporan karena skrip setup awal sudah memasang ALTER DEFAULT PRIVILEGES FOR ROLE skema_owner. Sebaliknya, postgres tidak memiliki hak default tersebut untuk app_laporan.