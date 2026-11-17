-- Diminta: mencabut hak UPDATE dari skema_owner lalu menguji dampaknya terhadap kepemilikan.
-- Dipilih: mencabut dan memberikan kembali hak UPDATE sebagai pembuktian hak istimewa pemilik.
-- Alternatif: membiarkan hak tanpa pencabutan; tidak dipilih karena gagal membuktikan hak kepemilikan.

REVOKE UPDATE ON lab11.pelanggan FROM skema_owner;

SET ROLE skema_owner;
BEGIN; 
  UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; 
ROLLBACK;  -- Ditolak karena hak dicabut

GRANT UPDATE ON lab11.pelanggan TO skema_owner; -- Diberikan kembali oleh pemilik sendiri

BEGIN; 
  UPDATE lab11.pelanggan SET kota = kota WHERE id = 3; 
ROLLBACK;  -- Berhasil karena pemilik memiliki hak istimewa (owner privilege)

RESET ROLE;