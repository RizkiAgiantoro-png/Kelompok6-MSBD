-- Diminta: mencabut hak DROP dari skema_owner pada tabel akun dan mengamati galatnya.
-- Dipilih: menguji REVOKE DROP untuk membedakan hak biasa (SELECT/UPDATE) dengan hak kepemilikan (DROP/ALTER).
-- Alternatif: menguji pada tabel lain; tidak dipilih karena instruksi menetapkan tabel akun.

REVOKE DROP ON lab11.akun FROM skema_owner;
-- Catatan/Keluaran: Hak DROP, ALTER, dan kepemilikan objek tidak dapat dicabut dari pemilik objek (owner) karena melekat secara permanen pada struktur skema/tabel.