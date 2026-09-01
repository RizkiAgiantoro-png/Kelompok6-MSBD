CREATE TABLE kategori (
    id_kategori SERIAL PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL
);

CREATE TABLE alat (
    id_alat SERIAL PRIMARY KEY,
    nama_alat VARCHAR(100) NOT NULL,
    id_kategori INT NOT NULL,
    jumlah INT NOT NULL DEFAULT 0,
    kondisi VARCHAR(50),

    CONSTRAINT fk_alat_kategori
        FOREIGN KEY (id_kategori)
        REFERENCES kategori(id_kategori)
);

CREATE TABLE unit_alat (
    id_unit SERIAL PRIMARY KEY,
    id_alat INT NOT NULL,
    kode_unit VARCHAR(50) UNIQUE NOT NULL,
    kondisi VARCHAR(50) NOT NULL,

    CONSTRAINT fk_unit_alat
        FOREIGN KEY (id_alat)
        REFERENCES alat(id_alat)
);

CREATE TABLE anggota (
    id_anggota SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_hp VARCHAR(20)
);