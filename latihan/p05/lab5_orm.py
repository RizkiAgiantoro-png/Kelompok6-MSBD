# Diminta: menguji ORM SQLAlchemy dan membuktikan masalah N+1.
# Dipilih: Declarative SQLAlchemy 2.0 dengan echo=True.
# Alternatif: SQL mentah untuk seluruh operasi ORM; tidak dipilih karena tugas menguji eager loading.

import os
import time

from sqlalchemy import create_engine, ForeignKey, text, select
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    relationship,
    Session,
    selectinload,
    joinedload,
)


DSN = os.environ["DSN"]

SQLALCHEMY_DSN = DSN.replace(
    "postgresql://",
    "postgresql+psycopg://",
    1
)

engine = create_engine(
    SQLALCHEMY_DSN,
    echo=True
)


class Base(DeclarativeBase):
    pass


class Customer(Base):
    __tablename__ = "customer"
    __table_args__ = {"schema": "public"}

    customer_id: Mapped[int] = mapped_column(primary_key=True)

    rentals: Mapped[list["Rental"]] = relationship(
        back_populates="customer"
    )


class Rental(Base):
    __tablename__ = "rental_tx"
    __table_args__ = {"schema": "lab5"}

    rental_id: Mapped[int] = mapped_column(primary_key=True)

    customer_id: Mapped[int] = mapped_column(
        ForeignKey("public.customer.customer_id")
    )

    customer: Mapped[Customer] = relationship(
        back_populates="rentals"
    )


def q17_n_plus_one():
    print("\n===== Q17 N+1 =====")

    with Session(engine) as session:
        customers = session.scalars(
            select(Customer).limit(10)
        ).all()

        for customer in customers:
            print(
                "customer_id:",
                customer.customer_id,
                "jumlah rental:",
                len(customer.rentals)
            )


def q18_selectinload():
    print("\n===== Q18 SELECTINLOAD =====")

    with Session(engine) as session:
        customers = session.scalars(
            select(Customer)
            .options(selectinload(Customer.rentals))
            .limit(10)
        ).all()

        for customer in customers:
            print(
                "customer_id:",
                customer.customer_id,
                "jumlah rental:",
                len(customer.rentals)
            )


def q19_joinedload():
    print("\n===== Q19 JOINEDLOAD =====")

    with Session(engine) as session:
        customers = session.scalars(
            select(Customer)
            .options(joinedload(Customer.rentals))
            .limit(10)
        ).unique().all()

        for customer in customers:
            print(
                "customer_id:",
                customer.customer_id,
                "jumlah rental:",
                len(customer.rentals)
            )


def q20_orm():
    print("\n===== Q20 ORM =====")

    start = time.perf_counter()

    with Session(engine) as session:
        result = session.execute(
            text("""
                SELECT
                    f.film_id,
                    f.title,
                    COUNT(r.rental_id) AS jumlah_disewa
                FROM public.film f
                JOIN public.inventory i
                    ON i.film_id = f.film_id
                JOIN public.rental r
                    ON r.inventory_id = i.inventory_id
                GROUP BY f.film_id, f.title
                ORDER BY jumlah_disewa DESC
                LIMIT 5
            """)
        )

        rows = result.fetchall()

    elapsed = time.perf_counter() - start

    print("Hasil:")
    for row in rows:
        print(row)

    print(f"Waktu ORM: {elapsed:.6f} detik")


def q20_raw_sql():
    print("\n===== Q20 RAW SQL =====")

    start = time.perf_counter()

    import psycopg

    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    f.film_id,
                    f.title,
                    COUNT(r.rental_id) AS jumlah_disewa
                FROM public.film f
                JOIN public.inventory i
                    ON i.film_id = f.film_id
                JOIN public.rental r
                    ON r.inventory_id = i.inventory_id
                GROUP BY f.film_id, f.title
                ORDER BY jumlah_disewa DESC
                LIMIT 5
            """)

            rows = cur.fetchall()

    elapsed = time.perf_counter() - start

    print("Hasil:")
    for row in rows:
        print(row)

    print(f"Waktu SQL mentah: {elapsed:.6f} detik")


if __name__ == "__main__":
    q17_n_plus_one()
    q18_selectinload()
    q19_joinedload()
    q20_orm()
    q20_raw_sql()