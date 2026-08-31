KATEGORI ||--|{ ALAT : "mengelompokkan"
    ALAT ||--|{ UNIT_ALAT : "memiliki"
    UNIT_ALAT ||--o{ PERBAIKAN : "menjalani"
    ANGGOTA ||--o{ PEMINJAMAN : "mengajukan"
    PEMINJAMAN ||--|{ BARIS_PINJAM : "berisi"
    UNIT_ALAT ||--o{ BARIS_PINJAM : "dipinjamkan"

    KATEGORI {
        id_kategori PK
        kode_kategori
        nama_kategori
    }
    ALAT {
        id_alat PK
        nama_alat
        merk
    }
    UNIT_ALAT {
        id_unit PK
        nomor_seri
        kondisi
    }
    ANGGOTA {
        id_anggota PK
        nomor_induk
        nama
        status
    }
    PEMINJAMAN {
        id_peminjaman PK
        tgl_pinjam
        jatuh_tempo
        petugas
    }
    BARIS_PINJAM {
        id_peminjaman PK, FK
        id_unit PK, FK
        catatan_awal
        kondisi_kembali
    }
    PERBAIKAN {
        id_perbaikan PK
        tgl_mulai
        deskripsi
    }
    