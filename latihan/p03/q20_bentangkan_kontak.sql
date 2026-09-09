-- Diminta: Membentangkan array kontak menjadi satu baris per kontak dan tetap menampilkan kontak kosong.
-- Dipilih: LEFT JOIN LATERAL jsonb_array_elements agar notifikasi tanpa kontak tetap muncul.
-- Alternatif: CROSS JOIN LATERAL; tidak dipilih karena akan menghilangkan array kontak yang kosong.

SELECT n.payload ->> 'trx' AS nomor_transaksi,
       kontak.item ->> 'jenis' AS jenis_kontak,
       kontak.item ->> 'nomor' AS nomor_kontak
FROM notifikasi n
LEFT JOIN LATERAL jsonb_array_elements(n.payload -> 'kontak') AS kontak(item)
    ON true
ORDER BY n.notifikasi_id, jenis_kontak, nomor_kontak;