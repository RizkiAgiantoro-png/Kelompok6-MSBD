-- Diminta: Menggunakan trigger level pernyataan dengan transition table untuk membuat audit massal.
-- Dipilih: FOR EACH STATEMENT dengan OLD TABLE dan NEW TABLE agar seluruh perubahan dapat diproses sebagai satu operasi.
-- Alternatif: FOR EACH ROW; tidak dipilih karena Q13 menguji pendekatan statement-level.

CREATE OR REPLACE FUNCTION lab4.catat_audit_massal()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lab4.audit_harga (
        film_id,
        harga_lama,
        harga_baru
    )
    SELECT
        baru.film_id,
        lama.rental_rate,
        baru.rental_rate
    FROM lama
    JOIN baru USING (film_id)
    WHERE lama.rental_rate IS DISTINCT FROM baru.rental_rate;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS film_audit_harga_massal ON lab4.film;

CREATE TRIGGER film_audit_harga_massal
AFTER UPDATE ON lab4.film
REFERENCING OLD TABLE AS lama NEW TABLE AS baru
FOR EACH STATEMENT
EXECUTE FUNCTION lab4.catat_audit_massal();

\timing on

UPDATE lab4.film
SET rental_rate = rental_rate + 0.01;