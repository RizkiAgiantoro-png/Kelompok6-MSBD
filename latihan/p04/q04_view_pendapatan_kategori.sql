-- Diminta: Membuat view dengan GROUP BY dan menguji insert untuk melihat galat auto-updatable.
-- Dipilih: CREATE VIEW menggunakan JOIN dan GROUP BY dari skema public, lalu disimulasikan dengan INSERT.
-- Alternatif: Menggunakan window function; tidak dipilih karena soal meminta penggunaan GROUP BY secara eksplisit.

CREATE OR REPLACE VIEW lab4.pendapatan_kategori AS
SELECT c.name AS kategori, sum(p.amount) AS total_pendapatan
FROM public.category c
JOIN public.film_category fc ON c.category_id = fc.category_id
JOIN public.inventory i ON fc.film_id = i.film_id
JOIN public.rental r ON i.inventory_id = r.inventory_id
JOIN public.payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- Uji coba insert yang dipastikan gagal oleh aturan auto-updatable PostgreSQL
INSERT INTO lab4.pendapatan_kategori (kategori, total_pendapatan)
VALUES ('Kategori Baru', 1000);