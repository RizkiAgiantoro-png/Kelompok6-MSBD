-- Diminta: menjelaskan risiko saat status yang telah tersimpan dipakai dalam laporan.
-- Dipilih: INSERT berparameter dan fungsi laporan dengan SQL statis.
-- Alternatif: merangkai ulang SQL dari nilai status yang dibaca dari tabel.

-- Kontrol defensif mandiri dengan data sintetis. Jalankan dalam satu sesi.
BEGIN;
CREATE TEMP TABLE q17_status (id int PRIMARY KEY, nilai text NOT NULL);
CREATE TEMP TABLE q17_pelanggan (kota text NOT NULL, status text NOT NULL);

PREPARE p11_q17_simpan(int, text) AS
    INSERT INTO pg_temp.q17_status (id, nilai) VALUES ($1, $2);
EXECUTE p11_q17_simpan(1, $status$O'Neil$status$);
DEALLOCATE p11_q17_simpan;

INSERT INTO pg_temp.q17_pelanggan (kota, status) VALUES
    ('Medan', $status$O'Neil$status$),
    ('Medan', 'aktif'),
    ('Binjai', 'aktif');

CREATE FUNCTION pg_temp.laporan_kota_aman(id_status int)
RETURNS TABLE (kota text, jumlah bigint)
LANGUAGE sql STABLE SECURITY INVOKER
AS $$
    SELECT p.kota, count(*)
    FROM pg_temp.q17_pelanggan AS p
    JOIN pg_temp.q17_status AS s ON p.status = s.nilai
    WHERE s.id = $1
    GROUP BY p.kota
    ORDER BY p.kota;
$$;

SELECT nilai AS status_tersimpan FROM pg_temp.q17_status WHERE id = 1;
SELECT * FROM pg_temp.laporan_kota_aman(1);
SELECT * FROM pg_temp.laporan_kota_aman(99);
ROLLBACK;

-- Parameter INSERT melindungi sintaks INSERT saja. Jika fungsi laporan
-- menyusun perintah baru dari isi status, batas kode dan data hilang di
-- tahap kedua. Pada fungsi di atas, status tetap menjadi operand JOIN.
