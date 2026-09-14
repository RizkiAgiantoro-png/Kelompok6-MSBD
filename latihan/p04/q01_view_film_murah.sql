-- Diminta: membuat view lab4.film_murah dengan rental_rate <= 0.99 tanpa WITH CHECK OPTION.
-- Dipilih: CREATE VIEW biasa dengan klausa WHERE.
-- Alternatif: CREATE MATERIALIZED VIEW; tidak dipilih karena kita ingin data selalu up-to-date dan bisa menerima insert.

CREATE OR REPLACE VIEW lab4.film_murah AS
SELECT film_id, title, rental_rate, rating
FROM lab4.film
WHERE rental_rate <= 0.99;