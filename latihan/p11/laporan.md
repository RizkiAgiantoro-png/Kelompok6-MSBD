# Laporan Latihan Kelompok Pertemuan 11

## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |
|---|---|---|---|
| Daffa Umayans Saragih | 251402011 | Langkah 1 & 2 (Setup & Q1-Q5, Refleksi A) | *(Diisi nanti saat commit)* |
| Anggota 2 | NIM 2 | Langkah 3 (Q6-Q11, Refleksi B) | *(Menunggu Anggota 2)* |
| Anggota 3 | NIM 3 | Langkah 4 (Q12-Q18, Refleksi C) | *(Menunggu Anggota 3)* |
| Anggota 4 | NIM 4 | Langkah 5 (Q19-Q24, Refleksi D) | *(Menunggu Anggota 4)* |
| Anggota 5 | NIM 5 | Langkah 6 & 7 (Q25-Q30, Refleksi E, PDP) | *(Menunggu Anggota 5)* |

## Q1–Q30: Perintah, Keluaran, dan Alasan Keputusan

### Langkah 1: Setup
**Q0: Verifikasi Skema lab11**
- `tenant`: 3
- `pelanggan`: 30000
- `akun`: 4
- `transaksi`: 120000
- **Distribusi Pelanggan:** Tiap tenant (tenant 1, 2, dan 3) terdistribusi merata dengan masing-masing berjumlah tepat 10000 baris.

### Langkah 2: Kepemilikan, GRANT, dan Peran Berlapis
**Q1: Hak Pemilik (q01_hak_pemilik.sql)**
- **Hasil:** Saat hak `UPDATE` dicabut, `skema_owner` ditolak saat mencoba mengubah data (*Permission denied*). Namun, `skema_owner` dapat menjalankan `GRANT UPDATE` kembali kepada dirinya sendiri dan akhirnya berhasil melakukan *update*.
- **Alasan:** Pemilik tabel (*owner*) memiliki hak istimewa absolut untuk mengelola izin (GRANT/REVOKE) pada objek miliknya. Meskipun hak DML-nya dicabut, ia selalu bisa memberikannya kembali.

**Q2: Drop Bukan Hak (q02_drop_bukan_hak.sql)**
- **Keluaran/Galat:** `WARNING: no privileges could be revoked for "akun"`
- **Alasan:** Hak operasi DDL seperti `DROP` dan `ALTER` bukanlah hak *privilege* biasa (seperti SELECT/UPDATE) yang dikelola melalui tabel ACL (Access Control List). Hak ini melekat secara permanen pada status "Kepemilikan", sehingga tidak bisa dicabut menggunakan perintah `REVOKE`.

**Q3: Default Privileges (q03_default_privileges.sql)**
- **Keluaran:** `via_postgres: f` (False)
- **Alasan:** Tabel yang dibuat oleh `skema_owner` otomatis bisa dibaca oleh aplikasi karena modul latihan telah menjalankan `ALTER DEFAULT PRIVILEGES FOR ROLE skema_owner ...`. Tabel yang dibuat oleh peran lain (seperti `postgres`) tidak mewarisi aturan tersebut, sehingga peran aplikasi tidak otomatis mendapat hak baca.

**Q4: Grant Option (q04_grant_option.sql)**
- **Keluaran Pencabutan:** Jika dicabut tanpa `CASCADE`, PostgreSQL memunculkan pesan galat `dependent privileges exist`. Setelah menggunakan `CASCADE`, hak baca untuk `app_analitik` menjadi `f` (False), sedangkan hak baca `app_write` tetap `t` (True).
- **Alasan:** Opsi `CASCADE` membatalkan hak turunan yang diteruskan oleh `app_write` kepada `app_analitik`. Perintah tersebut hanya mencabut "hak untuk meneruskan hak" (`GRANT OPTION`), bukan mencabut hak `SELECT` milik `app_write` itu sendiri.

**Q5: Tabel Peran (q05_tabel_peran.sql)**
1. `skema_owner`: Pemilik struktur dan objek (Tidak login)
2. `app_read`: Hanya bisa membaca data (`SELECT`) (Bisa login)
3. `app_write`: Membaca dan menulis data (Bisa login)
4. `app_portal`: Akses operasional aplikasi tenant (Bisa login)
5. `app_laporan`: Baca terbatas untuk pembuatan laporan (Bisa login)
6. `app_analitik`: Akses tampilan data tersamar / anonim (Bisa login)
7. `admin_audit`: Akses menulis log jejak audit (Bisa login)
- **Alasan aplikasi tidak pernah login sebagai pemilik:** Untuk mematuhi prinsip "Hak Istimewa Minimum" (*Least Privilege*). Jika kredensial aplikasi bocor atau diretas, penyerang tidak akan bisa menjatuhkan struktur tabel (DROP), mengubah arsitektur, atau menghapus sistem audit karena akun aplikasi tidak memiliki izin tersebut.

*(Q6 - Q30 akan dilanjutkan oleh anggota kelompok lain)*

## Refleksi A–E

**📝 Reflektif A (Langkah 2)**
Mencabut hak (*revoke privilege*) bukan jalan keluar untuk keluhan keamanan antar penyewa. Seperti yang dibuktikan di Langkah 2, pengguna yang memiliki hak aplikasi seperti `app_write` masih bisa mengedit seluruh baris di tabel `pelanggan` karena tidak ada batasan horizontal. Jika penyerang mengeksploitasi aplikasi, mencabut hak tak berguna karena penyerang "berpura-pura" menjadi aplikasi yang sah. Jalan keluar yang tepat adalah menggunakan **Row-Level Security (RLS)**, sehingga basis data menolak akses ke baris penyewa lain meskipun kuerinya dijalankan oleh aplikasi dengan hak `UPDATE` yang sah.

*(Refleksi B, C, D, E akan diisi oleh anggota lain)*

## Peta Tiket #1134 ke UU PDP
| Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti |
|---|---|---|---|
| *(Dilengkapi Anggota 5 di Langkah 6)* | | | |

## Pernyataan Etika
Seluruh percobaan serangan hanya dijalankan pada kontainer lab11 milik sendiri di jaringan tertutup.
*(Tanda Tangan Anggota Kelompok)*
1. Daffa Umayans Saragih ...........................
2. .................................................
3. .................................................
4. .................................................
5. .................................................

## Penggunaan AI dan Verifikasi
AI (LLM) digunakan untuk membantu menstrukturkan Markdown, merapikan dokumen SQL, dan menjabarkan perbedaan secara konseptual (seperti beda hak kepemilikan dan *default privileges*). Seluruh sintaks dan hasil keluaran dibuktikan dengan menjalankan kueri secara langsung pada kontainer `lab11-db` di jaringan `lab11_labnet`.