-- Diminta: Mencatat perubahan rental_rate pada level baris melalui audit.
-- Dipilih: AFTER UPDATE OF rental_rate dengan IS DISTINCT FROM agar hanya perubahan harga yang dicatat.
-- Alternatif: AFTER UPDATE tanpa OF dan WHEN; tidak dipilih karena dapat mencatat perubahan yang tidak berkaitan dengan harga.

CREATE TABLE IF NOT EXISTS lab4.audit_harga (
    audit_id bigserial PRIMARY KEY,
    film_id integer NOT NULL,
    harga_lama numeric(5,2),
    harga_baru numeric(5,2),
    diubah_oleh text NOT NULL DEFAULT current_user,
    diubah_pada timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION lab4.catat_audit_harga()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lab4.audit_harga (
        film_id,
        harga_lama,
        harga_baru,
        diubah_oleh,
        diubah_pada
    )
    VALUES (
        OLD.film_id,
        OLD.rental_rate,
        NEW.rental_rate,
        current_user,
        now()
    );

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS film_audit_harga ON lab4.film;

CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_audit_harga();