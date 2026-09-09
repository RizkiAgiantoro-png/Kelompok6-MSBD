-- Diminta: Menampilkan notifikasi lunas dengan transaksi, kota pelanggan, dan jumlah numerik serta membuat indeks GIN.
-- Dipilih: Operator ->> untuk nilai teks, cast numerik untuk jumlah, dan @> untuk pencarian JSONB terindeks.
-- Alternatif: Menyimpan semua nilai sebagai teks; tidak dipilih karena jumlah perlu dipakai dalam operasi numerik.

DROP INDEX IF EXISTS idx_notifikasi_payload_gin;
CREATE INDEX idx_notifikasi_payload_gin
    ON notifikasi USING GIN (payload);

SELECT payload ->> 'trx' AS nomor_transaksi,
       payload -> 'pelanggan' ->> 'kota' AS kota_pelanggan,
       (payload ->> 'jumlah')::numeric AS jumlah
FROM notifikasi
WHERE payload @> '{"status":"lunas"}'::jsonb
ORDER BY notifikasi_id;

\d notifikasi