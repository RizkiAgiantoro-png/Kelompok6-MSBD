# Laporan Latihan Kelompok Pertemuan 11

## Anggota dan Kontribusi
| Nama | NIM | Kontribusi | Commit |
|---|---|---|---|
| Daffa Umayans Saragih | 251402011 | Langkah 1 & 2 (Setup & Q1-Q5, Refleksi A) | *(Diisi nanti saat commit)* |
| Juda Benhur Turnip | 251402096 | Langkah 3 (Q6-Q11, Refleksi B) | *(Diisi nanti saat commit)* |
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

### Langkah 3: Row-Level Security Multi-penyewa

**Q6: Default Deny (q06_default_deny.sql)**
- **Hasil:** `sebelum_ada_kebijakan: 0`
- **Alasan & Penjelasan Keamanan:** Ketika RLS diaktifkan pada tabel menggunakan `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` tanpa adanya kebijakan (*policy*) yang dibuat, PostgreSQL secara bawaan menerapkan prinsip *default-deny* (tertutup penuh). Setiap kueri dari peran non-owner/non-superuser akan mengembalikan 0 baris (*empty set*). Perilaku ini sangat aman (*fail-closed*) karena mencegah kebocoran data jika terjadi kelalaian atau kegagalan konfigurasi kebijakan keamanan.

**Q7: Kebijakan Penyewa (q07_kebijakan_penyewa.sql)**
- **Hasil:** Kebijakan `p_tenant_baca` dan `p_tenant_tulis` berhasil dibuat pada tabel `lab11.pelanggan`.
- **Alasan Pemilihan `nullif(..., '')`:** Sintaks `nullif(current_setting('app.tenant', true), '')::int` digunakan untuk mencegah galat tipe data pada PostgreSQL 17 (`invalid input syntax for type integer: ""`). Jika variabel `app.tenant` pernah disetel dan kemudian di-reset menjadi string kosong `''`, pemanggilan `::int` langsung akan memicu kegagalan runtime. Dengan `nullif`, nilai kosong diubah menjadi `NULL`, sehingga ekspresi perbandingan menghasilkan `NULL` (dinilai false oleh RLS) dan mengembalikan 0 baris secara aman tanpa galat.

**Q8: Uji Positif dan Negatif (q08_uji_positif_negatif.sql)**
- **Hasil:**
  - `terlihat_tenant1`: `10000` (Uji positif: seluruh data milik tenant 1 terlihat lengkap).
  - `harus_nol`: `0` (Uji negatif: data penyewa 2 tidak dapat diakses meskipun kueri meminta secara eksplisit `WHERE tenant_id = 2`).
- **Alasan & Penjelasan:** RLS secara otomatis menggabungkan predikat filter keamanan ke dalam kueri pengguna (`WHERE (tenant_id = 2) AND (tenant_id = 1)`). Karena kedua kondisi bertolak belakang, kueri mengevaluasi hasil menjadi kosong (0 baris), membuktikan integritas isolasi multi-tenant.

**Q9: Force dan Bypass (q09_force_dan_bypass.sql)**
- **Hasil:**
  - `owner_sebelum_force`: `30000` baris (pemilik tabel secara default kebal/bebas dari RLS).
  - `owner_sesudah_force`: `0` baris (setelah `FORCE ROW LEVEL SECURITY`, pemilik tabel dipaksa tunduk pada RLS; karena belum ada kebijakan untuk owner, berlaku default-deny).
  - `analitik_dengan_read_all_data`: `0` baris (peran bawaan `pg_read_all_data` tidak membypass RLS).
  - `analitik_dengan_bypassrls`: `30000` baris (peran dengan atribut `BYPASSRLS` menembus seluruh batasan isolasi RLS).
- **Pelajaran tentang `pg_read_all_data`:** Peran `pg_read_all_data` hanya memberikan hak akses baca vertikal (setingkat tabel), tetapi **TIDAK** memberikan izin untuk menembus aturan keamanan baris (horizontal). Batas horizontal RLS tetap tegak dan hanya dapat dilewati oleh atribut khusus `BYPASSRLS` atau peran `SUPERUSER`.

**Q10: Kolam Koneksi (q10_kolam_koneksi.sql)**
- **Penyebab Kebocoran:** Pada kolam koneksi (*connection pooling* seperti PgBouncer atau HikariCP), koneksi TCP fisik dipakai bergantian oleh banyak permintaan. Jika penyetelan tenant dilakukan di tingkat sesi (`SET app.tenant = '1'`), variabel ini akan menetap di sesi tersebut. Jika permintaan berikutnya tidak menyetel tenant, kueri akan berjalan di bawah konteks penyewa sebelumnya sehingga terjadi kebocoran data.
- **Pola Pencegahan:** Gunakan `SET LOCAL app.tenant = '1';` di dalam blok transaksi (`BEGIN ... COMMIT;`) atau fungsi `set_config('app.tenant', '1', true);` dengan parameter `is_local = true`. Dengan pola ini, konteks tenant otomatis dibersihkan saat transaksi berakhir (*commit* maupun *rollback*), sehingga koneksi yang kembali ke kolam berada dalam status netral/bersih.

**Q11: Tiga Celah Isolasi (q11_tiga_celah.sql)**
1. **Celah 1 (Superuser / BYPASSRLS):**
   - *Penyebab:* Aplikasi terkoneksi sebagai superuser atau peran berstatus BYPASSRLS sehingga mengabaikan RLS.
   - *Perbaikan:* Terapkan prinsip hak minimum dengan memastikan peran aplikasi tidak memiliki atribut superuser maupun BYPASSRLS.
   - *Bukti Nyata:* Saat `app_analitik` diberi atribut `BYPASSRLS`, kueri mengembalikan `30000` baris (seluruh data semua penyewa bocor), padahal tanpa atribut tersebut mengembalikan `0` baris.
2. **Celah 2 (Kebocoran Sesi pada Kolam Koneksi):**
   - *Penyebab:* Konteks `app.tenant` disetel tanpa `LOCAL` dan tertinggal di sesi kolam koneksi.
   - *Perbaikan:* Wajib menyetel konteks penyewa menggunakan transaksi lokal `SET LOCAL` atau `set_config(..., true)`.
3. **Celah 3 (Tabel Relasi / Anak dan View yang Tidak Dilindungi RLS):**
   - *Penyebab:* Tabel anak (seperti `transaksi`) atau View tidak dipasangi RLS sehingga data penyewa lain dapat diintip lewat relasi atau fungsi bocor (*leaky functions*).
   - *Perbaikan:* Wajib aktifkan RLS pada seluruh tabel relasi yang memuat referensi tenant serta pasang opsi `WITH (security_barrier = true)` pada seluruh View.

*(Q12 - Q30 akan dilanjutkan oleh anggota kelompok lain)*

## Refleksi A–E

**📝 Reflektif A (Langkah 2)**
Mencabut hak (*revoke privilege*) bukan jalan keluar untuk keluhan keamanan antar penyewa. Seperti yang dibuktikan di Langkah 2, pengguna yang memiliki hak aplikasi seperti `app_write` masih bisa mengedit seluruh baris di tabel `pelanggan` karena tidak ada batasan horizontal. Jika penyerang mengeksploitasi aplikasi, mencabut hak tak berguna karena penyerang "berpura-pura" menjadi aplikasi yang sah. Jalan keluar yang tepat adalah menggunakan **Row-Level Security (RLS)**, sehingga basis data menolak akses ke baris penyewa lain meskipun kuerinya dijalankan oleh aplikasi dengan hak `UPDATE` yang sah.

**📝 Reflektif B (Langkah 3)**
**Apakah penyaring `WHERE tenant_id` di aplikasi masih perlu ditulis padahal RLS sudah aktif?**
**Ya, tetap sangat perlu ditulis.** Keduanya mengemban tugas fundamental yang berbeda:
1. **RLS bertugas sebagai Garis Pertahanan Keamanan (Security Barrier):**
   RLS adalah jaring pengaman tingkat basis data (*defense-in-depth*). RLS menjamin bahwa meskipun terjadi bug di kode aplikasi, kelalaian developer lupa menuliskan filter, atau celah logika, basis data secara mutlak menolak membocorkan baris milik penyewa lain (*fail-safe security*).
2. **Penyaring `WHERE tenant_id` di aplikasi bertugas untuk Optimasi Kinerja & Rencana Eksekusi (Query Performance):**
   Dari sisi rencana eksekusi (*query execution plan*), PostgreSQL Query Planner sangat bergantung pada predikat eksplisit untuk menentukan jalur akses tercepat:
   - **Pemanfaatan Indeks:** Dengan menuliskan `WHERE tenant_id = $1` secara eksplisit, perencana kueri dapat langsung menggunakan indeks komposit `(tenant_id, ...)` pada kondisi indeks (*Index Cond*). Sebaliknya, jika hanya mengandalkan RLS, evaluasi fungsi dinamis `current_setting('app.tenant')` sering kali diperlakukan sebagai filter pasca-pembacaan baris (*Filter: ...*), yang berpotensi memicu *Sequential Scan* penuh pada tabel besar.
   - **Partition Pruning:** Jika tabel dipartisi berdasarkan `tenant_id`, klausul `WHERE tenant_id = $1` memungkinkan *pruning* partisi dilakukan sejak tahap perencanaan kueri (*compile-time pruning*), sehingga PostgreSQL hanya membaca partisi milik penyewa tersebut dan mengabaikan partisi penyewa lain.
- **Kesimpulan:** RLS menjamin **keamanan mutlak**, sedangkan klausul `WHERE` di aplikasi menjamin **efisiensi dan performa tinggi**.

*(Refleksi C, D, E akan diisi oleh anggota lain)*

## Peta Tiket #1134 ke UU PDP
| Keluhan | Pasal relevan | Kontrol teknis pencegah | Bukti |
|---|---|---|---|
| *(Dilengkapi Anggota 5 di Langkah 6)* | | | |

## Pernyataan Etika
Seluruh percobaan serangan hanya dijalankan pada kontainer lab11 milik sendiri di jaringan tertutup.
*(Tanda Tangan Anggota Kelompok)*
1. Daffa Umayans Saragih ...........................
2. Juda Benhur Turnip .............................
3. .................................................
4. .................................................
5. .................................................

## Penggunaan AI dan Verifikasi
AI (LLM) digunakan untuk membantu menstrukturkan Markdown, merapikan dokumen SQL, dan menjabarkan perbedaan secara konseptual (seperti beda hak kepemilikan dan *default privileges*). Seluruh sintaks dan hasil keluaran dibuktikan dengan menjalankan kueri secara langsung pada kontainer `lab11-db` di jaringan `lab11_labnet`.