-- Mengisi data kategori (menggunakan id_kategori sebagai kunci konflik)
INSERT INTO kategori (id_kategori, nama_kategori) VALUES
(1, 'Elektronika dan Kelistrikan'),
(2, 'Perangkat Komputer dan Jaringan'),
(3, 'Alat Ukur dan Kalibrasi')
ON CONFLICT (id_kategori)
DO UPDATE SET nama_kategori = EXCLUDED.nama_kategori;

-- Mengisi data anggota (menggunakan email sebagai kunci konflik)
INSERT INTO anggota (nama, email, no_hp) VALUES
('Budi Santoso', 'budi.santoso@students.usu.ac.id', '081234567890'),
('Siti Aminah', 'siti.aminah@students.usu.ac.id', '081298765432'),
('Andi Wijaya', 'andi.wijaya@students.usu.ac.id', '081312345678')
ON CONFLICT (email)
DO UPDATE SET 
    nama = EXCLUDED.nama, 
    no_hp = EXCLUDED.no_hp;