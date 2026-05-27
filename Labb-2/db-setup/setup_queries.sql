USE bokhandel;
GO


-- BARA TESTSYFTE, TA BORT VID RIKTIG ANVÄNDNING
DROP PROCEDURE IF EXISTS [FlyttaBok];
DROP VIEW IF EXISTS [BokSök];
DROP VIEW IF EXISTS [TitlarPerFörfattare];
DROP VIEW IF EXISTS [BeställningsData];
DROP TABLE IF EXISTS [dbo].[OrderDetaljer]; --övr
DROP TABLE IF EXISTS [dbo].[Ordrar]; --övr
DROP TABLE IF EXISTS [dbo].[Anställda]; --övr
DROP TABLE IF EXISTS [dbo].[LagerSaldo];
DROP TABLE IF EXISTS [dbo].[FörfattareBokJunktion]; --junktion
DROP TABLE IF EXISTS [dbo].[Böcker];
DROP TABLE IF EXISTS [dbo].[Butiker];
DROP TABLE IF EXISTS [dbo].[Adresser]; --övr
DROP TABLE IF EXISTS [dbo].[Kunder]; --övr
DROP TABLE IF EXISTS [dbo].[Förlag]; --övr
DROP TABLE IF EXISTS [dbo].[Författare];
GO



-- skapande av tabeller
CREATE TABLE Författare(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Förnamn] NVARCHAR(100),
    [Efternamn] NVARCHAR(100),
    [Födelsedatum] DATE
);


CREATE TABLE Förlag( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Namn] NVARCHAR(100) NOT NULL
);


CREATE TABLE Kunder( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY, --identity tills kund-id-standard är bestämd
    [UserName] NVARCHAR(100) NOT NULL,
    [EmailAdress] NVARCHAR(100) CHECK ([EmailAdress] LIKE '%@%')
);


CREATE TABLE Adresser(
    [Postnummer] NVARCHAR(20) PRIMARY KEY,
    [LAND] NVARCHAR(100),
    [Stad] NVARCHAR(100)
);


CREATE TABLE Butiker(
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Butiksnamn] NVARCHAR(100) NOT NULL,
    [Adress] NVARCHAR(200) NOT NULL,
    [Postnummer] NVARCHAR(20) FOREIGN KEY REFERENCES Adresser(Postnummer)
);


CREATE TABLE Böcker(
    [ISBN] CHAR(13) PRIMARY KEY,
    [Titel] NVARCHAR(100) NOT NULL,
    [Språk] NVARCHAR(100) NOT NULL,
    [Pris] DECIMAL(8, 2),
    [Utgivningsdatum] DATE NOT NULL,
    [FörlagID] INT FOREIGN KEY REFERENCES Förlag(ID)
);


CREATE TABLE FörfattareBokJunktion(
    [FörfattareID] INT FOREIGN KEY REFERENCES Författare(ID),
    [ISBN] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN),
    PRIMARY KEY ([FörfattareID], [ISBN])
);


CREATE TABLE LagerSaldo(
    [ButikId] INT FOREIGN KEY REFERENCES Butiker(ID),
    [ISBN] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN),
    [Antal] INT CHECK ([Antal] >= 0) DEFAULT 0,
    PRIMARY KEY ([ButikId], [ISBN])
);


CREATE TABLE Anställda( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Förnamn] NVARCHAR(100) NOT NULL,
    [Efternamn] NVARCHAR(100) NOT NULL,
    [Arbetstitel] NVARCHAR(100) NOT NULL,
    [ButikId] INT FOREIGN KEY REFERENCES Butiker(ID)
);


CREATE TABLE Ordrar( --övr
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [KundID] INT FOREIGN KEY REFERENCES Kunder(ID),
    [AnställdID] INT FOREIGN KEY REFERENCES Anställda(ID),
    [ButikID] INT FOREIGN KEY REFERENCES Butiker(ID),
    [Adress] NVARCHAR(200) NOT NULL,
    [Beställt] DATE NOT NULL,
    [Skickat] DATE
);


CREATE TABLE OrderDetaljer( --övr
    [OrderID] INT FOREIGN KEY REFERENCES Ordrar(ID),
    [BokID] CHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN),
    [Antal] INT NOT NULL CHECK ([Antal] > 0),
    [Kostnad] DECIMAL(10, 2), --lägg till automatiskt i insert query sen
    PRIMARY KEY ([OrderID], [BokID])
);
GO



-- vy, titlar per författare enligt uppgift
CREATE VIEW TitlarPerFörfattare AS
SELECT
    CONCAT([f].[Förnamn], ' ', [f].[Efternamn]) AS [Namn],
    DATEDIFF(YEAR, [f].[Födelsedatum], GETDATE()) -
        CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, [f].[Födelsedatum], GETDATE()), [f].[Födelsedatum]) > GETDATE()
                THEN 1 ELSE 0
        END AS [Ålder],
    COUNT([b].[Titel]) AS [Titlar],
    SUM([b].[pris] * [l].[Antal]) AS [Lagervärde]
FROM [dbo].[Författare] [f]
JOIN [dbo].[FörfattareBokJunktion] [junktion]
    ON [junktion].[FörfattareID] = [f].[ID]
JOIN [dbo].[Böcker] [b]
    ON [b].[ISBN] = [junktion].[ISBN]
JOIN [dbo].[LagerSaldo] [l]
    ON [l].[ISBN] = [b].[ISBN]
GROUP BY [f].[ID], [f].[Efternamn], [f].[Förnamn], [f].[Födelsedatum];
GO



-- procedure for att säkert flytta bok från ett lager till ett annat
CREATE PROCEDURE FlyttaBok(
    @IdFrån INT,
    @IdTill INT,
    @ISBN CHAR(13),
    @Antal INT = 1
)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

            IF @IdFrån = @IdTill 
                BEGIN
                    ;THROW 50000, 'cannot move books to the same store', 1;
                END

            IF @Antal <= 0 
                BEGIN
                    ;THROW 50000, 'cannot move less than 1 book', 2;
                END

            IF NOT EXISTS (SELECT 1 FROM [Butiker] WHERE [ID] = @IdFrån) 
                BEGIN
                    ;THROW 50000, 'cannot move book from non existant store', 3;
                END

            IF NOT EXISTS (SELECT 1 FROM [Butiker] WHERE [ID] = @IdTill) 
                BEGIN
                    ;THROW 50000, 'cannot move book to non existant store', 4;
                END

            IF NOT EXISTS (SELECT 1 FROM [LagerSaldo] WITH (XLOCK, ROWLOCK) WHERE [ISBN] = @ISBN AND [Antal] >= @Antal AND [ButikId] = @IdFrån) 
                BEGIN
                    ;THROW 50000, 'cannot move books that dont exist', 5;
                END

            --begin transaction

            UPDATE [LagerSaldo]
            SET [Antal] = [Antal] - @Antal
            WHERE [ButikId] = @IdFrån
                AND [ISBN] = @ISBN;


            UPDATE [LagerSaldo]
            SET [Antal] = [Antal] + @Antal
            WHERE [ButikId] = @IdTill
                AND [ISBN] = @ISBN;

            IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO [LagerSaldo] ([ButikId], [ISBN], [Antal])
                    VALUES (@IdTill, @ISBN, @Antal);
                END
            
            DELETE FROM LagerSaldo
            WHERE ButikID = @IdFrån
                AND ISBN = @ISBN
                AND Antal = 0;

        COMMIT TRANSACTION;
    
    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    
    END CATCH

END
GO



-- Övrig vy: 
-- Ger bokhandeln / kedjan av bokhandlar inblick i hur olika butiker presterar när det kommer till beställningar vilket är klart viktigt i analys av en butiks prestation
CREATE VIEW BeställningsData AS
SELECT
    [b].[Butiksnamn] AS [Butik],
    SUM([od].[Antal]) AS [Antal böcker],
    SUM([od].[Kostnad]) AS [intäkter],
    COUNT(DISTINCT [o].[KundID]) AS [Antal kunder]
FROM [dbo].[Ordrar] [o]
JOIN [dbo].[butiker] [b]
    ON [b].[ID] = [o].[ButikID]
JOIN [dbo].[OrderDetaljer] [od]
    ON [od].[OrderID] = [o].[ID]
GROUP BY [b].[Butiksnamn];
GO



-- vy för sök-program
CREATE VIEW BokSök AS
SELECT
    [b].[ISBN],
    [b].[Titel],
    [s].[Butiksnamn],
    [l].[Antal]
FROM [dbo].[Böcker] [b]
JOIN [dbo].[LagerSaldo] [l]
    ON [b].[ISBN] = [l].[ISBN]
JOIN [dbo].[Butiker] [s]
    ON [s].[ID] = [l].[ButikId];
GO



-- skapa user med roll och login
USE master;
GO

IF EXISTS (SELECT 1 FROM [sys].[server_principals] WHERE name = 'BokSökUser')
    DROP LOGIN BokSökUser;
GO

CREATE LOGIN BokSökUser
WITH PASSWORD = 'ABC123!';
GO


USE bokhandel;
GO

DROP USER IF EXISTS BokSökUser;
GO

DROP ROLE IF EXISTS BokSökRoll;
GO

CREATE USER BokSökUser FOR LOGIN BokSökUser;
GO

CREATE ROLE BokSökRoll;
GO

GRANT SELECT ON [dbo].[BokSök] TO BokSökRoll;
GO

ALTER ROLE BokSökRoll ADD MEMBER BokSökUser;
GO