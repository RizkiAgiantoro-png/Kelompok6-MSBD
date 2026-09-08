-- Diminta: Judul film yang tidak pernah disewa, dengan dua versi query (NOT IN dan NOT EXISTS).
-- Dipilih: Dua versi dituliskan agar bisa diamati perbedaan mekanismenya saat berhadapan dengan NULL.
-- Alternatif: LEFT JOIN dan IS NULL; tidak dipilih karena fokus soal adalah membandingkan NOT IN dan NOT EXISTS.

-- Versi 1: NOT IN
SELECT f.title
FROM film f
WHERE f.film_id NOT IN (
    SELECT i.film_id 
    FROM inventory i 
    JOIN rental r ON r.inventory_id = i.inventory_id
)
ORDER BY f.title;

-- Versi 2: NOT EXISTS
SELECT f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1 
    FROM inventory i 
    JOIN rental r ON r.inventory_id = i.inventory_id 
    WHERE i.film_id = f.film_id
)
ORDER BY f.title;