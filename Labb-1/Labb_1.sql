USE everyloop;
GO


DROP TABLE IF EXISTS [everyloop].[dbo].[SuccessfulMissions];

SELECT
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
INTO [everyloop].[dbo].[SuccessfulMissions]
FROM [everyloop].[dbo].[MoonMissions]
WHERE [Outcome] = 'Successful';

GO

UPDATE [everyloop].[dbo].[SuccessfulMissions]
SET [Operator] = TRIM('   ' FROM [Operator])

GO

UPDATE [everyloop].[dbo].[SuccessfulMissions]
SET Spacecraft = LEFT(Spacecraft, CHARINDEX(' (', Spacecraft))
WHERE CHARINDEX(' (', Spacecraft) > 0;

GO

SELECT
    [Operator],
    [Mission type],
    COUNT([Mission type]) AS [Mission count]
FROM [everyloop].[dbo].[SuccessfulMissions]
GROUP BY [Operator], [Mission type]
HAVING COUNT([Mission type]) > 1
ORDER BY [Operator], [Mission type];

GO

DROP TABLE IF EXISTS [everyloop].[dbo].[NewUsers];

SELECT
    [ID],
    [UserName],
    [Password],
    [FirstName] + ' ' + [LastName] AS [Name],
    [Email],
    [Phone],
    CASE
        WHEN CAST(RIGHT(ID, 1) AS int) % 2 = 0 THEN 'Female'
        ELSE 'Male'
    END AS [Gender]
INTO [everyloop].[dbo].[NewUsers]
FROM [everyloop].[dbo].[Users];

GO

SELECT
    [UserName],
    COUNT([UserName])
FROM [everyloop].[dbo].[NewUsers]
GROUP BY [UserName]
HAVING COUNT([UserName]) > 1
ORDER BY COUNT([UserName]) DESC;

GO

