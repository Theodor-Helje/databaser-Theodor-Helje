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
    [UserName] AS [UserName],
    COUNT([UserName]) AS [Number of instances]
FROM [everyloop].[dbo].[NewUsers]
GROUP BY [UserName]
HAVING COUNT([UserName]) > 1
ORDER BY COUNT([UserName]) DESC;

GO

WITH [UserNameDoubles] AS (
    SELECT
        [UserName] AS [UserName],
        COUNT([UserName]) AS [Number of instances]
    FROM [everyloop].[dbo].[NewUsers]
    GROUP BY [UserName]
    HAVING COUNT([UserName]) > 1
)
UPDATE users
SET users.[UserName] = LOWER(CONCAT(
    LEFT(oldUsers.[FirstName], 2), 
    LEFT(oldUsers.[LastName], 2),
    RIGHT(CAST(users.[ID] AS varchar(MAX)), 2)))
FROM [everyloop].[dbo].[NewUsers] users
JOIN [UserNameDoubles] doubles
    ON users.[UserName] = doubles.[UserName]
JOIN [everyloop].[dbo].[Users] oldUsers
    ON doubles.[UserName] = oldUsers.[UserName];

GO

-- id är nvarchar
DELETE FROM [everyloop].[dbo].[NewUsers]
WHERE CAST(LEFT([ID], 2) AS int) < 70 
    AND CAST(LEFT([ID], 2) AS int) > 26
    AND [Gender] = 'Female';

GO

INSERT INTO [everyloop].[dbo].[NewUsers]
VALUES ('050305-1111', 'thehel', '-', 'Theodor Helje', 'Theodor.Helje@proton.me', '-', 'Male');

GO

SELECT
    users.[Gender],
    AVG(
        DATEDIFF(YEAR, users.[Birthday], GETDATE()) -
        CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, users.[Birthday], GETDATE()), users.[Birthday]) > GETDATE()
                THEN 1 ELSE 0
        END
    ) AS [Average age]
FROM (
    SELECT
        [Gender],
        DATEFROMPARTS(
            CASE 
                WHEN CAST(left([ID], 2) AS int) < 26 THEN 
                    CAST('20' + LEFT([ID], 2) AS int)
                ELSE 
                     CAST('19' + LEFT([ID], 2) AS int)
            END,
            CAST(SUBSTRING([ID], 3, 2) AS int),
            CAST(SUBSTRING([ID], 5, 2) AS int)) AS [Birthday]
    FROM [everyloop].[dbo].[NewUsers]
) users
GROUP BY users.[Gender];

GO

SELECT
    products.[ID],
    products.[ProductName] AS [Product],
    suppliers.[CompanyName] AS [Supplier],
    categories.[CategoryName] AS [Category]
FROM [everyloop].[company].[products] products
JOIN [everyloop].[company].[suppliers] suppliers
    ON products.[SupplierId] = suppliers.[Id]
JOIN [everyloop].[company].[categories] categories
    ON products.[CategoryId] = categories.[Id];

GO

SELECT --work in progress
    COUNT(DISTINCT(employee.[Employeeid])) AS [Employees],
    regions.[RegionDescription] AS [Region]
FROM [everyloop].[company].[employee_territory] employee
JOIN [everyloop].[company].[territories] territories
    ON employee.[TerritoryId] = territories.[ID]
JOIN [everyloop].[company].[regions] regions
    ON territories.[RegionId] = regions.[Id]
JOIN [everyloop].[company].[employees] names
    ON employee.[EmployeeId] = names.[Id]
GROUP BY regions.[RegionDescription]