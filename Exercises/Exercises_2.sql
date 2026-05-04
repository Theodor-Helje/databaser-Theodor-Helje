USE everyloop;
GO


--a
SELECT
    Period,
    MIN(Number) AS [From],
    MAX(Number) AS [to],
    COALESCE(ROUND(AVG(Stableisotopes), 2), '-') AS [Average stable isotopes],
    STRING_AGG(Symbol, ',') AS [Symbols]
FROM everyloop.dbo.Elements
GROUP BY Period;


--b
SELECT
    Region,
    Country,
    City,
    COUNT(Id) AS Customers
FROM everyloop.company.customers
GROUP BY 
    Region, 
    Country,
    City
HAVING COUNT(Id) >= 2;


--c
DECLARE @text VARCHAR(MAX) = '';

SELECT @text = @text +
    'Säsong ' + CAST([Season] AS VARCHAR) +
    ' sändes från ' + FORMAT(MIN([Original air date]), 'MMMM', 'sv') +
    ' till ' + FORMAT(MAX([Original air date]), 'MMMM yyyy', 'sv') +
    '. Totalt sändes ' + CAST(COUNT([EpisodeInSeason]) AS VARCHAR)  +
    ' avsnitt, som i genomsnitt sågs av ' + CAST(ROUND(AVG([U.S. viewers(millions)]), 2) AS VARCHAR) +
    ' miljoner människor i USA' + CHAR(13) + CHAR(10)
FROM everyloop.dbo.GameOfThrones
GROUP BY [Season];

PRINT @text;


--d, ålder och kön finns inte i data
SELECT
    [FirstName] + ' ' + [LastName] as [Namn]
FROM everyloop.dbo.Users
ORDER BY [FirstName], [lastName];


--e
SELECT
    Region,
    COUNT([Country]) AS [Countries],
    SUM(CAST([Population] AS bigint)) AS [Population],
    SUM([Area (sq# mi#)]) AS [AREA],
    ROUND(AVG(TRY_CAST(REPLACE([Pop# Density (per sq# mi#)], ',', '.') AS float)), 2) AS [Population density],
    ROUND(AVG(TRY_CAST(REPLACE([Infant mortality (per 1000 births)], ',', '.') AS float)) * 10, 0) AS [Infant mortality per 100.000]
FROM everyloop.dbo.Countries
GROUP BY Region;


--f
SELECT
    CASE
        WHEN CHARINDEX(',', REVERSE([Location served])) - 2 > 0 THEN
            RIGHT([Location served], CHARINDEX(',', REVERSE([Location served])) - 2)
        ELSE
            [Location served]
        END AS [Country],
    COUNT([IATA]) AS [Number of airports],
    SUM(CASE WHEN [ICAO] IS NULL THEN 1 ELSE 0 END) AS [Number of null ICAO codes],
    CAST(ROUND(100.0 * SUM(CASE WHEN [ICAO] IS NULL THEN 1 ELSE 0 END) / COUNT([IATA]), 1) AS decimal(4, 1)) AS [Amount of airports without ICAO codes (%)]
FROM everyloop.dbo.Airports
GROUP BY
    CASE
        WHEN CHARINDEX(',', REVERSE([Location served])) - 2 > 0 THEN
            RIGHT([Location served], CHARINDEX(',', REVERSE([Location served])) - 2)
        ELSE
            [Location served]
        END;