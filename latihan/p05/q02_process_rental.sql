-- Diminta: Procedure lab5.process_rental untuk membuat baris di rental_tx dan payment_tx.
-- Dipilih: LANGUAGE plpgsql karena kita butuh menyimpan ID rental sementara (RETURNING) ke dalam variabel.
-- Alternatif: Menggunakan CTE (Common Table Expressions) dengan SQL biasa, namun PL/pgSQL lebih tepat untuk alur bisnis kompleks.

CREATE OR REPLACE PROCEDURE lab5.process_rental(
    p_customer_id integer,
    p_inventory_id integer,
    p_staff_id integer,
    p_amount numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rental_id bigint;
BEGIN
    -- 1. Masukkan data ke rental_tx dan tangkap ID-nya
    INSERT INTO lab5.rental_tx (customer_id, inventory_id, staff_id)
    VALUES (p_customer_id, p_inventory_id, p_staff_id)
    RETURNING rental_id INTO v_rental_id;

    -- 2. Masukkan pembayaran ke payment_tx dengan ID rental tadi
    INSERT INTO lab5.payment_tx (rental_id, amount)
    VALUES (v_rental_id, p_amount);
END;
$$;