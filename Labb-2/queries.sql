USE bokhandel;
GO


DROP TABLE IF EXISTS [bokhandel].[dbo].[OrderDetaljer];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Ordrar];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Anställda];
DROP TABLE IF EXISTS [bokhandel].[dbo].[LagerSaldo];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Böcker];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Butiker];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Kunder];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Förlag];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Författare];



CREATE TABLE Författare(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Förnamn] NVARCHAR(MAX),
    [Efternamn] NVARCHAR(MAX),
    [Födelsedatum] DATE
);


CREATE TABLE Förlag( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Namn] NVARCHAR(MAX) NOT NULL
);


CREATE TABLE Kunder( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY, --identity tills kund-id-standard är bestämd
    [UserName] NVARCHAR(MAX) NOT NULL,
    [EmailAdress] NVARCHAR(MAX) CHECK ([EmailAdress] LIKE '%@%')
);


CREATE TABLE Butiker(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Butiksnamn] VARCHAR(MAX) NOT NULL,
    [Land] VARCHAR(MAX) NOT NULL,
    [STAD] VARCHAR NOT NULL,
    [Adress] VARCHAR(MAX) NOT NULL,
    [Postnummer] VARCHAR(MAX) NOT NULL
);


CREATE TABLE Böcker(
    [ISBN13] CHAR(13) PRIMARY KEY,
    [Titel] VARCHAR(MAX) NOT NULL,
    [Språk] VARCHAR(MAX) NOT NULL,
    [Pris] DECIMAL(8, 2),
    [Utgivningsdatum] DATE NOT NULL,
    [FörfattareID] INT FOREIGN KEY REFERENCES Författare(ID),
    [FörlagID] INT FOREIGN KEY REFERENCES Förlag(ID)
);


CREATE TABLE LagerSaldo(
    [ButikId] INT FOREIGN KEY REFERENCES Butiker(ID),
    [ISBN] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN13),
    [Antal] INT CHECK ([Antal] >= 0) DEFAULT 0,
    PRIMARY KEY ([ButikId], [ISBN])
);


CREATE TABLE Anställda( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Förnamn] NVARCHAR(MAX) NOT NULL,
    [Efternamn] NVARCHAR(MAX) NOT NULL,
    [Titel] NVARCHAR(MAX) NOT NULL,
    [ButikId] INT FOREIGN KEY REFERENCES Butiker(ID)
);


CREATE TABLE Ordrar( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [KundID] INT FOREIGN KEY REFERENCES Kunder(ID),
    [AnställdID] INT FOREIGN KEY REFERENCES Anställda(ID),
    [Adress] NVARCHAR(MAX) NOT NULL,
    [Beställt] DATE NOT NULL,
    [Skickat] DATE
);

CREATE TABLE OrderDetaljer( --övr
    [OrderID] INT FOREIGN KEY REFERENCES Ordrar(ID),
    [BokID] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN13),
    [Antal] INT NOT NULL CHECK ([Antal] > 0),
    [Kostnad] DECIMAL(10, 2), --lägg till automatiskt i insert query sen
    PRIMARY KEY ([OrderID], [BokID])
);