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
DECLARE @text VARCHAR(MAX) = ''

SELECT @text = @text +
    'Säsong ' + CAST([Season] AS VARCHAR) +
    ' sändes från ' + FORMAT(MIN([Original air date]), 'MMMM', 'sv') +
    ' till ' + FORMAT(MAX([Original air date]), 'MMMM yyyy', 'sv') +
    '. Totalt sändes ' + CAST(COUNT([EpisodeInSeason]) AS VARCHAR)  +
    ' avsnitt, som i genomsnitt sågs av ' + CAST(ROUND(AVG([U.S. viewers(millions)]), 2) AS VARCHAR) +
    ' miljoner människor i USA' + CHAR(13) + CHAR(10)
FROM everyloop.dbo.GameOfThrones
GROUP BY [Season]

PRINT @text