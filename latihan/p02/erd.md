    KATEGORI ||--o{ ALAT : "mengelompokkan"
    ALAT ||--|{ UNIT_ALAT : "memiliki"
    UNIT_ALAT ||--o{ PERBAIKAN : "menjalani"
    ANGGOTA ||--o{ PEMINJAMAN : "mengajukan"
    PEMINJAMAN ||--|{ BARIS_PINJAM : "berisi"
    UNIT_ALAT ||--o{ BARIS_PINJAM : "dipinjamkan"

    KATEGORI {
        ID id_kategori PK
        Field kode_kategori
        Field nama_kategori
    }
    ALAT {
        ID id_alat PK
        Field nama_alat
        Field merk
        Field spesifikasi_singkat
    }
    UNIT_ALAT {
        ID id_unit PK
        Field nomor_seri
        Field kondisi_saat_ini
    }
    PERBAIKAN {
        ID id_perbaikan PK
        Field tgl_mulai_perbaikan
        Field deskripsi_kerusakan
        Field estimasi_selesai
    }
    ANGGOTA {
        ID id_anggota PK
        Field nomor_induk
        Field nama
        Field status
    }
    PEMINJAMAN {
        ID id_peminjaman PK
        Field tgl_pinjam
        Field jatuh_tempo
    }
    BARIS_PINJAM {
        ID id_peminjaman PK,FK
        ID id_unit PK,FK
        Field catatan_awal
        Field tgl_kembali
        Field kondisi_saat_kembali
    }