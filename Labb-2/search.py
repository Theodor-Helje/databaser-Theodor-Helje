import pandas as pd #df = pd.read_sql_query(query, con=engine, index_col="Id")
from sqlalchemy import create_engine, select, text
from sqlalchemy import Integer, String, ForeignKey
from sqlalchemy.engine import URL
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass

class Böcker(Base):
    __tablename__ = "Böcker"

    ISBN: Mapped[str] = mapped_column(String(13), primary_key=True)
    Titel: Mapped[str] = mapped_column(String(100), nullable=False)

class Butiker(Base):
    __tablename__ = "Butiker"

    ID: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    Butiksnamn: Mapped[str] = mapped_column(String(100), nullable=False)

class LagerSaldo(Base):
    __tablename__ = "LagerSaldo"

    ButikId: Mapped[int] = mapped_column(ForeignKey("Butiker.ID"), primary_key=True)
    ISBN: Mapped[str] = mapped_column(ForeignKey("Böcker.ISBN"), primary_key=True)
    Antal: Mapped[int] = mapped_column(Integer, nullable=False, default=0)



def connection_setup(server_name="localhost", database_name="bokhandel"):

    connection_string = (
        f"DRIVER=ODBC Driver 18 for SQL Server;"
        f"SERVER={server_name};"
        f"DATABASE={database_name};"
        "UID=bokapp_user;"
        "PWD=StrongPassword123!;"
        #f"Trusted_Connection=yes;"
        f"TrustServerCertificate=yes;"
    )

    url_string = URL.create(
        "mssql+pyodbc",
        query={"odbc_connect": connection_string}
    )

    try:
        engine = create_engine(url_string)
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception:
        print(f"Failed to connect to sql server:\n{Exception}")
    
    return engine


def search_for_book(engine, search_string):
    stmt = (select(Böcker.Titel, Butiker.Butiksnamn, LagerSaldo.Antal)
            .join(LagerSaldo, Böcker.ISBN == LagerSaldo.ISBN)
            .join(Butiker, Butiker.ID == LagerSaldo.ButikId)
            .where(Böcker.Titel.like(f"%{search_string}%")))
    
    with engine.connect() as conn:
        result = conn.execute(stmt)
    
        df = pd.DataFrame(
            result.fetchall(),
            columns=result.keys()
        )

    return df



if __name__ == "__main__":
    from os import system

    print("Connecting..")
    engine = connection_setup()
    print(f'Successfully connected\n\n')

    while True:
        if not input("Press enter to search, type anything to close: ") == '':
             break
        system('cls')

        search = input("Search: ")
        print(f"\nResults:\n{search_for_book(engine, search)}\n")