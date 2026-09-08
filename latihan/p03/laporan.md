# Laporan Latihan Kelompok Pertemuan 3

## Anggota dan Kontribusi

| Nama |NIM | Kontribusi |
| Commit |

| Mochamad Rizki Agiantoro | 251402135 |
|commit |
| Ramadiyan Athallah Kusuma | 251402027 |
|commit |
| Juda Benhur Turnip | 251402096 |
|commit |
| Dennis Pamungkas Panjaitan | 251402076 | 
|commit |
| Daffa Umayans Saragih | 251402011 |
 commit set up.sql, langkah 3 q1-q5,langkah 4 q6-q9,serta mengerjakan bagian untuk laporan yang terkait dengan commit-commit tersebut | |

Catatan: Pengerjaan Langkah 1 hingga Langkah 4 diambil alih sementara di awal untuk memastikan proyek kelompok tetap berjalan lancar.

---

## Refleksi A - Subquery

Pertanyaan Pada Q4, apa tepatnya yang membuat NOT IN berbahaya, dan bagaimana memeriksa apakah sebuah kolom rawan terhadap masalah itu?


Penggunaan NOT IN sangat berbahaya jika subquery menghasilkan nilai NULL.
Seperti yang pernah bapak jelaskan dalam kelas kalau kita pakai not in maka nanti hasilnya malah unknown nah ini bahaya nanti filter not in malah gagal menampikan datanya  

Pertanyaan Pada Q5, berapa kali subquery dievaluasi secara konseptual, dan mengapa sekali per baris luar belum tentu sama dengan yang benar-benar dikerjakan mesin?

Secara konseptual, correlated subquery dievaluasi satu kali untuk setiap baris di query luar. Namun pada praktiknya, query optimizer pada database cukup pintar dan jarang mengeksekusi subquery dengan cara looping satu per satu. Mesin database biasanya mengubah bentuknya menjadi operasi JOIN atau hashing di balik layar agar waktu eksekusinya lebih efisien.

---

## Refleksi B - CTE dan Recursive CTE

Pertanyaan Pada Q7, mengapa recursive term hanya melihat baris yang baru dihasilkan pada iterasi sebelumnya, dan apa akibatnya jika ia melihat seluruh hasil?

Recursive term hanya melihat baris yang baru dihasilkan agar proses penelusuran hierarki bisa terus bergerak maju ke bawah. Ini menjadi tanda bagi sistem untuk berhenti bekerja saat iterasi tidak lagi menghasilkan baris baru. Jika query melihat seluruh hasil dari awal, rekursi akan memproses ulang data yang sama secara terus-menerus dan memicu infinite loop.

Pertanyaan Kapan mengganti UNION ALL dengan UNION dapat menghentikan siklus, dan mengapa itu tetap bukan solusi yang baik?

Mengganti UNION ALL dengan UNION bisa menghentikan siklus karena operasi UNION secara otomatis menghapus baris yang duplikat. Saat siklus memunculkan data yang berulang, data itu langsung dibuang sehingga rekursi berhenti. Tapi ini bukan solusi yang baik karena operasi UNION sangat membebani memori untuk proses sorting. Selain itu, cara ini berisiko menghilangkan data valid yang nilainya memang kebetulan sama.

---

## Refleksi C - Window Function
(Belum dikerjakan)

## Refleksi D - Agregasi dan Operasi Himpunan
(Belum dikerjakan)

## Refleksi E - JSONB
(Belum dikerjakan)

## Temuan Q14
(Belum dikerjakan)
