-- Diminta: menyimpan tiga tag dan mencari rental berdasarkan tag.
-- Dipilih: menggunakan ARRAY dan operator ANY.
-- Alternatif: menyimpan tag sebagai satu string; tidak dipilih karena kolom tags sudah bertipe array.

UPDATE lab5.rental_tx
SET tags = ARRAY['promo', 'akhir-pekan', 'anggota']
WHERE rental_id = 1;

SELECT rental_id, tags
FROM lab5.rental_tx
WHERE 'promo' = ANY(tags);
