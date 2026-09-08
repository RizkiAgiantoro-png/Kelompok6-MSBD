-- Diminta: Menampilkan judul film yang tidak pernah disewa, ditulis dalam dua versi (NOT IN dan NOT EXISTS).
-- Dipilih: Versi 1 (NOT EXISTS dengan correlated subquery) sebagai pilihan utama karena aman dan kebal terhadap anomali nilai NULL.
-- Alternatif: Versi 2 (NOT IN); rentan terhadap bug Three-Valued Logic. Jika subquery mengembalikan satu saja nilai NULL, hasil NOT IN akan mendadak kosong total.

-- Versi 1: Menggunakan NOT EXISTS (Aman dan Disarankan)
SELECT title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE i.film_id = f.film_id
);

-- Versi 2: Menggunakan NOT IN (Rentan terhadap Nilai NULL)
SELECT title
FROM film
WHERE film_id NOT IN (
    SELECT i.film_id
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE i.film_id IS NOT NULL
);