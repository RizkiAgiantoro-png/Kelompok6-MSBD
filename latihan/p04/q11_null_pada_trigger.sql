-- Diminta: Menguji dampak penggunaan <> terhadap perubahan NULL pada trigger audit.
-- Dipilih: Menggunakan <> untuk memperlihatkan bahwa perbandingan dengan NULL menghasilkan UNKNOWN.
-- Alternatif: IS DISTINCT FROM; tidak dipakai pada eksperimen ini karena justru menjadi pembanding terhadap <>.

DROP TRIGGER IF EXISTS film_audit_harga ON lab4.film;

CREATE TRIGGER film_audit_harga
AFTER UPDATE OF rental_rate ON lab4.film
FOR EACH ROW
WHEN (OLD.rental_rate <> NEW.rental_rate)
EXECUTE FUNCTION lab4.catat_audit_harga();

UPDATE lab4.film
SET rental_rate = NULL
WHERE film_id = 4;

UPDATE lab4.film
SET rental_rate = 2.99
WHERE film_id = 4;

SELECT *
FROM lab4.audit_harga
WHERE film_id = 4
ORDER BY audit_id DESC;