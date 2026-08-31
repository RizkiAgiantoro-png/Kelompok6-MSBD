## Lingkup

| Termasuk | Tidak termasuk |
|---|---|
| Katalog spesifikasi alat dan pencatatan unit fisik | Pengadaan dan pembelian alat baru dari vendor |
| Proses peminjaman dan pengembalian unit alat | Pembayaran denda keterlambatan secara finansial |
| Perhitungan durasi peminjaman dan denda | Sinkronisasi data induk mahasiswa dari sistem akademik pusat |
| Riwayat kondisi dan perbaikan unit alat | Penjadwalan praktikum kelas |

---

### KD-01 Pendataan Anggota
- Deskripsi : mencatat data mahasiswa atau dosen yang berhak meminjam alat
- Data      : id_anggota, nomor_induk, nama, status_keanggotaan, tgl_bergabung
- Aturan    : nomor_induk harus unik; status harus valid (aktif/ditangguhkan)
- Volume    : ±500 anggota terdaftar
- Sumber    : wawancara kepala lab
- Prioritas : wajib

### KD-02 Klasifikasi Kategori Alat
- Deskripsi : mengelompokkan alat berdasarkan jenisnya untuk kemudahan pencarian
- Data      : id_kategori, kode_kategori, nama_kategori
- Aturan    : kode_kategori harus unik dan maksimal 5 karakter
- Volume    : ±20 kategori
- Sumber    : observasi rak penyimpanan
- Prioritas : menengah

### KD-03 Katalog Alat
- Deskripsi : mencatat spesifikasi umum dari alat yang tersedia di lab
- Data      : id_alat, id_kategori, nama_alat, merk, spesifikasi_singkat
- Aturan    : setiap alat wajib masuk ke dalam satu kategori
- Volume    : ±100 jenis alat
- Sumber    : daftar inventaris lab
- Prioritas : wajib

### KD-04 Inventaris Unit Alat Fisik
- Deskripsi : mencatat setiap barang fisik berdasarkan nomor serinya
- Data      : id_unit, id_alat, nomor_seri, kondisi_saat_ini
- Aturan    : kondisi unit alat memengaruhi apakah barang bisa dipinjam atau tidak
- Volume    : ±500 unit fisik
- Sumber    : pengecekan fisik barang
- Prioritas : wajib

### KD-05 Pengajuan Peminjaman (Header)
- Deskripsi : mencatat data utama transaksi peminjaman oleh anggota
- Data      : id_peminjaman, id_anggota, tgl_pinjam, jatuh_tempo, petugas
- Aturan    : jatuh_tempo tidak boleh lebih kecil dari tgl_pinjam
- Volume    : ±30 transaksi/hari
- Sumber    : buku log peminjaman
- Prioritas : wajib

### KD-06 Detail Item Dipinjam (Baris Pinjam)
- Deskripsi : mencatat unit alat apa saja yang dibawa dalam satu transaksi peminjaman
- Data      : id_peminjaman, id_unit, catatan_awal
- Aturan    : satu transaksi bisa memuat banyak unit; unit dalam perbaikan tidak bisa dipinjam
- Volume    : ±90 detail/hari
- Sumber    : buku log peminjaman
- Prioritas : wajib

### KD-07 Pengembalian Alat
- Deskripsi : petugas mencatat pengembalian unit alat oleh peminjam
- Data      : id_peminjaman, id_unit, tgl_kembali, kondisi_saat_kembali
- Aturan    : keterlambatan dari jatuh_tempo otomatis memicu catatan denda; kondisi rusak memicu status perbaikan
- Volume    : ±60 transaksi/hari
- Sumber    : hasil wawancara
- Prioritas : wajib

### KD-08 Pencatatan Perbaikan Alat
- Deskripsi : mencatat riwayat perbaikan jika unit alat dikembalikan dalam kondisi rusak
- Data      : id_perbaikan, id_unit, tgl_mulai_perbaikan, deskripsi_kerusakan, estimasi_selesai
- Aturan    : selama masuk tabel perbaikan, unit_alat dikunci dari sistem peminjaman
- Volume    : ±5 pencatatan/minggu
- Sumber    : teknisi lab
- Prioritas : rendah