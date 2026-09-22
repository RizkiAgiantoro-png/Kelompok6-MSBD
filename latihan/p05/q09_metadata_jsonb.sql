-- Diminta: menyimpan metadata JSONB dan mengambil channel.
-- Dipilih: operator ->> karena hasil channel dibutuhkan sebagai text.
-- Alternatif: menyimpan metadata sebagai text; tidak dipilih karena kolom sudah bertipe JSONB.

UPDATE lab5.rental_tx
SET metadata = '{"channel":"web","device":"android"}'::jsonb
WHERE rental_id = 1;

SELECT
    rental_id,
    metadata ->> 'channel' AS kanal
FROM lab5.rental_tx
WHERE rental_id = 1;
