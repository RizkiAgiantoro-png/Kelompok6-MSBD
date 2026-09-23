import os
import time

import psycopg
from psycopg import sql
from psycopg_pool import ConnectionPool


DSN = os.environ["DSN"]


# ============================================================
# Q10 — SELECT BERPARAMETER
# ============================================================

def q10_select_parameter():
    print("=" * 60)
    print("Q10 — SELECT BERPARAMETER")
    print("=" * 60)

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT customer_id, first_name, last_name
                FROM public.customer
                WHERE last_name = %s
                ORDER BY customer_id
                """,
                ("SMITH",)
            )

            rows = cur.fetchall()

            print("Hasil:")
            for row in rows:
                print(row)

    print()


# ============================================================
# Q11 — SQL INJECTION
# ============================================================

def q11_injection():
    print("=" * 60)
    print("Q11 — SQL INJECTION")
    print("=" * 60)

    payload = "SMITH' OR '1'='1"

    unsafe_sql = (
        "SELECT customer_id, first_name, last_name "
        f"FROM public.customer WHERE last_name = '{payload}'"
    )

    print("SQL f-string:")
    print(unsafe_sql)
    print()

    print("SQL f-string di atas hanya dicetak dan TIDAK dijalankan.")

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT customer_id, first_name, last_name
                FROM public.customer
                WHERE last_name = %s
                """,
                (payload,)
            )

            rows = cur.fetchall()

            print("Hasil parameter binding:")
            for row in rows:
                print(row)

    print()


# ============================================================
# Q12 — IDENTIFIER + ALLOW-LIST
# ============================================================

ALLOWED_ORDER_COLUMNS = {
    "first_name",
    "last_name",
    "customer_id",
}


def q12_order_by(column_name):
    print("=" * 60)
    print("Q12 — IDENTIFIER + ALLOW-LIST")
    print("=" * 60)

    if column_name not in ALLOWED_ORDER_COLUMNS:
        raise ValueError("Kolom ORDER BY tidak diizinkan")

    query = sql.SQL(
        """
        SELECT customer_id, first_name, last_name
        FROM public.customer
        ORDER BY {}
        LIMIT 10
        """
    ).format(sql.Identifier(column_name))

    print(f"ORDER BY: {column_name}")

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(query)

            rows = cur.fetchall()

            for row in rows:
                print(row)

    print()


# ============================================================
# Q13 — ROLLBACK DARI PYTHON
# ============================================================

def q13_rollback():
    print("=" * 60)
    print("Q13 — ROLLBACK DARI PYTHON")
    print("=" * 60)

    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT count(*) FROM lab5.rental_tx"
                )

                sebelum = cur.fetchone()[0]

                print("Sebelum:", sebelum)

                cur.execute(
                    """
                    CALL lab5.process_rental(%s, %s, %s, %s)
                    """,
                    (1, 1, 1, 4.99)
                )

                raise RuntimeError("gagal di tengah alur")

    except RuntimeError as error:
        print("Exception:", error)
        print("Transaksi dibatalkan / rollback.")

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT count(*) FROM lab5.rental_tx"
            )

            sesudah = cur.fetchone()[0]

            print("Sesudah:", sesudah)

    print()


# ============================================================
# Q14 — CONNECTION POOL
# ============================================================

def q14_pool():
    print("=" * 60)
    print("Q14 — CONNECTION POOL")
    print("=" * 60)

    pool = ConnectionPool(
        conninfo=DSN,
        min_size=2,
        max_size=2
    )

    with pool:
        for i in range(5):
            with pool.connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        "SELECT %s AS request_number",
                        (i + 1,)
                    )

                    print(cur.fetchone())

        print()
        print("Pool stats:")
        print(pool.get_stats())

    print()


# ============================================================
# Q15 — IDLE IN TRANSACTION
# ============================================================

def q15_idle_transaction():
    print("=" * 60)
    print("Q15 — IDLE IN TRANSACTION")
    print("=" * 60)

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")

            print(
                "Transaksi sedang dibiarkan selama 30 detik..."
            )
            print(
                "Gunakan terminal kedua untuk memeriksa "
                "pg_stat_activity."
            )

            time.sleep(30)

    print()


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    q10_select_parameter()
    q11_injection()
    q12_order_by("last_name")
    q13_rollback()
    q14_pool()
    q15_idle_transaction()