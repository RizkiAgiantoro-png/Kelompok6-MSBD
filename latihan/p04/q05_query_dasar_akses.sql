-- Diminta: Mengukur waktu query agregasi jumlah akses dan film unik per bulan serta kanal.
-- Dipilih: GROUP BY berdasarkan bulan dan kanal karena data akan diringkas pada dua dimensi tersebut.
-- Alternatif: Window function; tidak dipilih karena hasil yang diminta berupa satu baris untuk setiap kelompok bulan-kanal.

\timing on

SELECT
    date_trunc('month', a.waktu) AS bulan,
    a.kanal,
    count(*) AS jumlah_akses,
    count(DISTINCT a.film_id) AS film_unik
FROM lab4.jejak_akses a
GROUP BY 1, 2
ORDER BY 1, 2;