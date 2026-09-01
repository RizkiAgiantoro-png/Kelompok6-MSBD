CREATE TABLE peminjaman (
    id_peminjaman SERIAL PRIMARY KEY,
    id_anggota INT NOT NULL,
    tanggal_pinjam DATE NOT NULL,
    tanggal_kembali DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'dipinjam',

    CONSTRAINT fk_peminjaman_anggota
        FOREIGN KEY (id_anggota)
        REFERENCES anggota(id_anggota)
);

CREATE TABLE baris_pinjam (
    id_baris_pinjam SERIAL PRIMARY KEY,
    id_peminjaman INT NOT NULL,
    id_unit INT NOT NULL,
    jumlah INT NOT NULL DEFAULT 1,

    CONSTRAINT fk_baris_peminjaman
        FOREIGN KEY (id_peminjaman)
        REFERENCES peminjaman(id_peminjaman),

    CONSTRAINT fk_baris_unit
        FOREIGN KEY (id_unit)
        REFERENCES unit_alat(id_unit)
);

CREATE TABLE perbaikan (
    id_perbaikan SERIAL PRIMARY KEY,
    id_unit INT NOT NULL,
    tanggal_masuk DATE NOT NULL,
    tanggal_selesai DATE,
    deskripsi TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'diperbaiki',

    CONSTRAINT fk_perbaikan_unit
        FOREIGN KEY (id_unit)
        REFERENCES unit_alat(id_unit)
);