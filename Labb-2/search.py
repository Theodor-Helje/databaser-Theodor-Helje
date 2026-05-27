import pandas as pd
from sqlalchemy import create_engine, select, text
from sqlalchemy import Integer, String
from sqlalchemy.engine import URL
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass

class BokSök(Base):
    __tablename__ = "BokSök"

    ISBN: Mapped[str] = mapped_column(String(13), primary_key=True)
    Titel: Mapped[str] = mapped_column(String(100))
    Butiksnamn: Mapped[str] = mapped_column(String(100), primary_key=True)
    Antal: Mapped[int] = mapped_column(Integer, nullable=False, default=0)



def connection_setup(server_name="localhost", database_name="bokhandel"):

    connection_string = (
        f"DRIVER=ODBC Driver 18 for SQL Server;"
        f"SERVER={server_name};"
        f"DATABASE={database_name};"
        "UID=BokSökUser;"
        "PWD=ABC123!;"
        "TrustServerCertificate=yes;"
    )

    url_string = URL.create(
        "mssql+pyodbc",
        query={"odbc_connect": connection_string}
    )

    try:
        engine = create_engine(url_string)
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception as e:
        print(f"Failed to connect to sql server:\n{e}")
    
    return engine


def search_for_book(engine, search_string):
    stmt = (select(BokSök.Titel, BokSök.Butiksnamn, BokSök.Antal)
            .where(BokSök.Titel.like(f"%{search_string}%")))
    
    with engine.connect() as conn:
        df = pd.DataFrame(conn.execute(stmt).mappings().all())

    return df



if __name__ == "__main__":
    from os import system

    print("Connecting..")
    engine = connection_setup()

    print('\n\n')

    while True:
        if not input("Press enter to search, type anything to close: ") == '':
             break
        system('cls')

        search = input("Search: ")
        print(f"\nResults:\n{search_for_book(engine, search)}\n")