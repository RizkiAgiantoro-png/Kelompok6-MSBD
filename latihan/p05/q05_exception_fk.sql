-- Diminta: Menangkap galat foreign_key_violation dengan pesan lebih ramah.
-- Dipilih: Menggunakan blok EXCEPTION di dalam PL/pgSQL.
-- Alternatif: Melakukan SELECT untuk mengecek ID sebelum INSERT; tidak dipilih karena memboroskan query dan rawan race condition.

CREATE OR REPLACE PROCEDURE lab5.process_rental(
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

    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Data pelanggan, inventaris, atau staf tidak ditemukan. Pastikan ID yang dimasukkan valid.';
END;
$proc$;