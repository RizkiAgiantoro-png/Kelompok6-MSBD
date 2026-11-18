-- Diminta: enkripsi 1000 rekening, buktikan dekripsi dan perbedaan ciphertext.
-- Dipilih: pgp_sym_encrypt dengan kunci sesi khusus lab dan pemeriksaan jumlah baris.
-- Alternatif: hash rekening; tidak dipilih karena nomor rekening perlu bisa dikembalikan.

\set ON_ERROR_STOP on
SELECT session_user AS login, current_user AS peran;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';

BEGIN;
ALTER TABLE lab11.pelanggan ADD COLUMN IF NOT EXISTS rekening_enc bytea;
DO $$
BEGIN
    IF (SELECT count(*) FROM lab11.pelanggan WHERE id <= 1000) <> 1000
       OR EXISTS (SELECT 1 FROM lab11.pelanggan WHERE id <= 1000 AND rekening IS NULL) THEN
        RAISE EXCEPTION 'Periksa data awal: perlu 1000 rekening non-NULL dengan id <= 1000';
    END IF;
END;
$$;

UPDATE lab11.pelanggan
SET rekening_enc = pgp_sym_encrypt(rekening::text, current_setting('app.kunci_kolom'))
WHERE id <= 1000;

SELECT count(*) AS rekening_terenkripsi
FROM lab11.pelanggan WHERE id <= 1000 AND rekening_enc IS NOT NULL;

SELECT id, rekening,
       pgp_sym_decrypt(rekening_enc, current_setting('app.kunci_kolom')) AS hasil_dekripsi,
       pgp_sym_decrypt(rekening_enc, current_setting('app.kunci_kolom')) = rekening::text AS cocok
FROM lab11.pelanggan WHERE id <= 1000 ORDER BY id LIMIT 1;

SELECT pgp_sym_encrypt('x', current_setting('app.kunci_kolom')) =
       pgp_sym_encrypt('x', current_setting('app.kunci_kolom')) AS ciphertext_sama;
COMMIT;
RESET app.kunci_kolom;
-- Jalankan sebagai postgres agar FORCE RLS tidak menyembunyikan baris uji.
-- Kunci di atas hanya contoh lab. Kolom rekening asli masih ada: penambahan
-- rekening_enc saja belum melindungi salinan database yang memuat teks terang.
