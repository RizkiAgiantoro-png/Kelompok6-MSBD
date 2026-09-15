-- Request:
-- Menguji tiga aksi referensial foreign key:
-- NO ACTION, CASCADE, dan SET NULL.
--
-- Bentuk query yang dipilih:
-- Tiga tabel child dibuat dengan aksi referensial yang berbeda.
-- Bentuk ini dipilih agar efek penghapusan parent dapat dibandingkan
-- secara langsung.
--
-- Alternatif yang tidak dipilih:
-- Menggunakan satu foreign key saja.
-- Cara tersebut tidak dapat menunjukkan perbedaan perilaku
-- dari ketiga aksi referensial.

DROP TABLE IF EXISTS lab4.ulasan_setnull;
DROP TABLE IF EXISTS lab4.ulasan_cascade;
DROP TABLE IF EXISTS lab4.ulasan;

CREATE TABLE lab4.ulasan (
    ulasan_id SERIAL PRIMARY KEY,
    film_id INT NOT NULL,
    komentar TEXT,
    CONSTRAINT fk_ulasan_film
        FOREIGN KEY (film_id)
        REFERENCES lab4.film(film_id)
        ON DELETE NO ACTION
);

INSERT INTO lab4.ulasan (film_id, komentar)
VALUES (1, 'Ulasan dengan NO ACTION');

DELETE FROM lab4.film
WHERE film_id = 1;

CREATE TABLE lab4.ulasan_cascade (
    ulasan_id SERIAL PRIMARY KEY,
    film_id INT NOT NULL,
    komentar TEXT,
    CONSTRAINT fk_ulasan_cascade_film
        FOREIGN KEY (film_id)
        REFERENCES lab4.film(film_id)
        ON DELETE CASCADE
);

INSERT INTO lab4.ulasan_cascade (film_id, komentar)
VALUES (2, 'Ulasan dengan CASCADE');

DELETE FROM lab4.film
WHERE film_id = 2;

SELECT *
FROM lab4.ulasan_cascade
WHERE film_id = 2;

CREATE TABLE lab4.ulasan_setnull (
    ulasan_id SERIAL PRIMARY KEY,
    film_id INT NULL,
    komentar TEXT,
    CONSTRAINT fk_ulasan_setnull_film
        FOREIGN KEY (film_id)
        REFERENCES lab4.film(film_id)
        ON DELETE SET NULL
);

INSERT INTO lab4.ulasan_setnull (film_id, komentar)
VALUES (3, 'Ulasan dengan SET NULL');

DELETE FROM lab4.film
WHERE film_id = 3;

SELECT *
FROM lab4.ulasan_setnull
WHERE ulasan_id = 1;