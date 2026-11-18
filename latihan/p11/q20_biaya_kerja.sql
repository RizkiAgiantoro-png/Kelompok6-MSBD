-- Diminta: membandingkan waktu bcrypt cost 6, cost 10, dan md5.
-- Dipilih: mengukur 100 hash per metode dengan clock_timestamp dan input yang sama.
-- Alternatif: hanya mengukur gen_salt; tidak dipilih karena biaya hashing ada pada crypt.

\set ON_ERROR_STOP on
SELECT session_user AS login, current_user AS peran;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
BEGIN;
CREATE TEMP TABLE hasil_q20 (
    metode text, ulangan int, total_ms numeric, rata_rata_ms numeric
) ON COMMIT DROP;

DO $$
DECLARE
    metode text;
    mulai timestamptz;
    durasi numeric;
    i int;
    n CONSTANT int := 100;
    sandi CONSTANT text := 'contoh-sandi-lab11';
BEGIN
    FOREACH metode IN ARRAY ARRAY['bcrypt cost 6', 'bcrypt cost 10', 'md5'] LOOP
        mulai := clock_timestamp();
        FOR i IN 1..n LOOP
            IF metode = 'bcrypt cost 6' THEN
                PERFORM crypt(sandi, gen_salt('bf', 6));
            ELSIF metode = 'bcrypt cost 10' THEN
                PERFORM crypt(sandi, gen_salt('bf', 10));
            ELSE
                PERFORM md5(sandi);
            END IF;
        END LOOP;
        durasi := extract(epoch FROM (clock_timestamp() - mulai)) * 1000;
        INSERT INTO hasil_q20 VALUES (metode, n, durasi, durasi / n);
    END LOOP;
END;
$$;

SELECT metode, ulangan, round(total_ms, 3) AS total_ms,
       round(rata_rata_ms, 6) AS rata_rata_ms
FROM hasil_q20
ORDER BY CASE metode WHEN 'bcrypt cost 6' THEN 1 WHEN 'bcrypt cost 10' THEN 2 ELSE 3 END;
COMMIT;
-- Angka mencakup overhead loop dan pemanggilan fungsi, bukan benchmark murni.
-- Bcrypt sengaja lambat agar tebakan sandi massal lebih mahal.
-- Catat hasil mesin sendiri; jangan menyalin waktu contoh di slide.
