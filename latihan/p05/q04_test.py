import psycopg

# Sesuaikan port 5433 karena tadi kita ubah di docker-compose
DSN = "postgresql://msbd:msbd@localhost:5433/pagila"

print("Mencoba memanggil procedure dengan COMMIT dari Python...")
try:
    with psycopg.connect(DSN) as conn:
        conn.execute("CALL lab5.process_rental_q4(1, 1, 1, 4.99)")
except Exception as e:
    print("TERJADI ERROR:", type(e).__name__)
    print("PESAN ERROR:", e)