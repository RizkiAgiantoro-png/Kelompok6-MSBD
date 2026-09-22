-- Diminta: function yang mengembalikan total pembayaran satu penyewaan.
-- Dipilih: LANGUAGE sql STABLE karena hanya membaca data tanpa efek samping.
-- Alternatif: LANGUAGE plpgsql; tidak dipilih karena logika terlalu sederhana dan SQL biasa lebih cepat.

CREATE OR REPLACE FUNCTION lab5.total_dibayar(p_rental_id bigint)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT coalesce(sum(amount), 0) 
  FROM lab5.payment_tx 
  WHERE rental_id = p_rental_id;
$$;