-- Migration 0042: trigger tulis ganda untuk mencerminkan perubahan rental_rate ke harga_film.

CREATE OR REPLACE FUNCTION lab4.sinkron_harga_film()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lab4.harga_film (
        film_id,
        wilayah,
        harga,
        berlaku
    )
    VALUES (
        NEW.film_id,
        'ID',
        NEW.rental_rate,
        daterange(CURRENT_DATE, NULL)
    )
    ON CONFLICT DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS film_dual_write ON lab4.film;

CREATE TRIGGER film_dual_write
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate IS DISTINCT FROM NEW.rental_rate)
EXECUTE FUNCTION lab4.sinkron_harga_film();