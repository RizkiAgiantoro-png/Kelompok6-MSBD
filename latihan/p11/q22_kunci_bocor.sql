-- Diminta: mengamati enkripsi dari sesi kedua dan mencari kemungkinan kebocoran kunci.
-- Dipilih: dua koneksi postgres, membandingkan SET berisi kunci dengan SELECT enkripsi.
-- Alternatif: menyimpulkan aman hanya karena ciphertext tidak terbaca; kunci juga perlu diperiksa.

-- psql interaktif: sesi A memakai \set sesi_a true sebelum \i file ini.
-- Sesi B menjalankan file ini tanpa variabel sesi_a; ulangi saat sesi A aktif.
\set ON_ERROR_STOP on
\if :{?sesi_a}
\else
  \set sesi_a false
\endif

SELECT session_user AS login, current_user AS peran, pg_backend_pid() AS pid;
\if :sesi_a
  SET application_name = 'p11_q22_enkripsi';
  SET app.kunci_kolom = 'kunci-lab11-jangan-dipakai-di-produksi';
  -- Saat prompt ini menunggu, B dapat melihat SET terakhir pada sesi idle.
  \prompt 'Jalankan sesi B untuk merekam SET. Setelah itu tekan Enter: ' lanjut

  -- Jeda per baris memberi waktu untuk mengamati, tanpa mengubah data.
  -- Maksimal 1000 baris, sekitar 20 detik ditambah waktu enkripsi.
  WITH proses AS MATERIALIZED (
      SELECT pgp_sym_encrypt(rekening::text, current_setting('app.kunci_kolom')) AS ciphertext,
             pg_sleep(0.02) AS jeda
      FROM lab11.pelanggan WHERE id <= 1000
  )
  SELECT count(ciphertext) AS jumlah_diproses FROM proses;
  RESET app.kunci_kolom;
  RESET application_name;
\else
  SELECT pid, usename, application_name, state, query_start, query
  FROM pg_stat_activity
  WHERE datname = current_database()
    AND application_name = 'p11_q22_enkripsi'
    AND pid <> pg_backend_pid();
  -- Ulangi \i saat A menjalankan enkripsi. Simpan kedua keluaran.
\endif

-- pg_stat_activity menampilkan teks query, bukan isi seluruh variabel sesi
-- atau nilai rekening yang dibaca dari tabel. SET dengan literal kunci bisa
-- terlihat; SELECT yang merujuk current_setting tidak menuliskan literal itu.
-- Periksa juga log PostgreSQL dan riwayat perintah klien/skrip aplikasi.
-- Keterlihatan query sesi lain bergantung pada hak pengamat; di sini postgres.
