USE bokhandel;
GO


DROP TABLE IF EXISTS [bokhandel].[dbo].[Böcker];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Författare];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Butiker];



CREATE TABLE Författare(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Förnamn] NVARCHAR(MAX),
    [Efternamn] NVARCHAR(MAX),
    [Födelsedatum] DATE
);


CREATE TABLE Böcker(
    [ISBN13] CHAR(13) PRIMARY KEY,
    [Titel] VARCHAR(MAX) NOT NULL,
    [Språk] VARCHAR(MAX) NOT NULL,
    [Pris] DECIMAL(8, 2),
    [Utgivningsdatum] DATE NOT NULL,
    [FörfattareID] INT FOREIGN KEY REFERENCES Författare(ID)
);


CREATE TABLE Butiker(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Butiksnamn] VARCHAR(MAX) NOT NULL,
    [Land] VARCHAR(MAX) NOT NULL,
    [STAD] VARCHAR NOT NULL,
    [Adress] VARCHAR(MAX) NOT NULL,
    [Postnummer] VARCHAR(MAX) NOT NULL
);


CREATE TABLE LagerSaldo(
    [ButikId] INT FOREIGN KEY REFERENCES Butiker(ID),
    [ISBN] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN13),
    [Antal] INT CHECK ([Antal] >= 0) DEFAULT 0,
    PRIMARY KEY ([ButikId], [ISBN])
);