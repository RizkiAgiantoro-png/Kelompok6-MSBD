-- Diminta: Membuat salinan procedure dengan menyisipkan COMMIT di tengah.
-- Dipilih: Menyisipkan COMMIT setelah INSERT pertama (rental_tx).
-- Alternatif: Memakai FUNCTION; tidak dipilih karena function PostgreSQL sama sekali tidak mengizinkan instruksi COMMIT.

CREATE OR REPLACE PROCEDURE lab5.process_rental_q4(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
)
LANGUAGE plpgsql
AS $proc$
DECLARE
    v_rental_id bigint;
BEGIN
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    COMMIT; -- Ini adalah COMMIT buatan yang diminta dosen untuk Q4

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
END;
$proc$;