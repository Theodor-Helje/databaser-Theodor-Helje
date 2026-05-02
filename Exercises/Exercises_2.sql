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


SELECT
    Region,
    Country,
    City,
    COUNT(Id) AS Customers
FROM everyloop.company.customers
WHERE COUNT(Id) >= 2
GROUP BY City;