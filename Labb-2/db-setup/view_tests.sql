USE bokhandel;
GO


SELECT * FROM TitlarPerFörfattare;
GO

SELECT * FROM BeställningsData;
GO

SELECT * FROM BokSök;
GO

SELECT SERVERPROPERTY('IsIntegratedSecurityOnly'); --server is in windows auth only mode