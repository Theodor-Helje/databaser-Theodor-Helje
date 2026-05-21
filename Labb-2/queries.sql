USE bokhandel;
GO


DROP PROCEDURE IF EXISTS [FlyttaBok];
DROP VIEW IF EXISTS [TitlarPerFörfattare];
DROP TABLE IF EXISTS [bokhandel].[dbo].[OrderDetaljer]; --övr
DROP TABLE IF EXISTS [bokhandel].[dbo].[Ordrar]; --övr
DROP TABLE IF EXISTS [bokhandel].[dbo].[Anställda]; --övr
DROP TABLE IF EXISTS [bokhandel].[dbo].[LagerSaldo];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Böcker];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Butiker];
DROP TABLE IF EXISTS [bokhandel].[dbo].[Kunder]; --övr
DROP TABLE IF EXISTS [bokhandel].[dbo].[Förlag]; --övr
DROP TABLE IF EXISTS [bokhandel].[dbo].[Författare];
GO



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
GO



CREATE VIEW TitlarPerFörfattare AS
SELECT
    CONCAT([f].[Förnamn], ' ', [f].[Efternamn]) AS [Namn],
    DATEDIFF(YEAR, [f].[Födelsedatum], GETDATE()) -
        CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, [f].[Efternamn], GETDATE()), [f].[Födelsedatum]) > GETDATE()
                THEN 1 ELSE 0
        END AS [Ålder],
    COUNT([b].[Titel]) AS [Titlar],
    SUM([b].[pris] * [l].[Antal]) AS [Lagervärde]
FROM [bokhandel].[dbo].[Författare] [f]
JOIN [bokhandel].[dbo].[Böcker] [b]
    ON [f].[ID] = [b].[FörfattareID]
JOIN [bokhandel].[dbo].[LagerSaldo] [l]
    ON [l].[ISBN] = [b].[ISBN13]
GROUP BY [f].[ID], [f].[Efternamn], [f].[Förnamn], [f].[Födelsedatum];
GO



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