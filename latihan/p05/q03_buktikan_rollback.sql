-- Diminta: Membuktikan bahwa error pada pembayaran membatalkan (rollback) insert penyewaan.
-- Dipilih: Memberikan nilai negatif (-4.99) agar melanggar CHECK constraint dari domain lab5.positive_amount.
-- Alternatif: Melakukan transaksi manual (BEGIN; INSERT; ROLLBACK); tidak dipilih karena pemanggilan PROCEDURE otomatis dibungkus dalam satu transaksi.

CALL lab5.process_rental(1, 1, 1, -4.99);