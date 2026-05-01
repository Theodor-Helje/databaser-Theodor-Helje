USE everyloop;
GO


--a
SELECT
    Title,
    CONCAT(
    'S' + FORMAT(Season, '00'),
    'E' + Format(EpisodeInSeason, '00')
    ) as FormattedEpisodes
FROM everyloop.dbo.GameOfThrones;


--b
DROP TABLE IF EXISTS everyloop.dbo.UsersCopy;

SELECT *
INTO everyloop.dbo.UsersCopy
FROM everyloop.dbo.Users;

UPDATE everyloop.dbo.UsersCopy
SET UserName = 
    CONCAT(
        SUBSTRING(FirstName, 1, 2),
        SUBSTRING(LastName, 1, 2)
    );


--c
DROP TABLE IF EXISTS everyloop.dbo.AirportsCopy;

SELECT *
INTO everyloop.dbo.AirportsCopy
FROM everyloop.dbo.Airports;

UPDATE everyloop.dbo.AirportsCopy
SET
    Time = COALESCE(Time, '-'),
    DST = COALESCE(DST, '-');


--d
DROP TABLE IF EXISTS everyloop.dbo.ElementsCopy;

SELECT *
INTO everyloop.dbo.ElementsCopy
FROM everyloop.dbo.Elements;

DELETE FROM everyloop.dbo.ElementsCopy
WHERE Name in ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium')
    OR LEFT(Name, 1) IN ('d', 'k', 'm', 'o', 'u');



--e
SELECT
    Symbol,
    Name,
    CASE
        WHEN SUBSTRING(Name, 1, LEN(Symbol)) = Symbol THEN 'Yes'
        ELSE 'No'
    END as SameName
FROM everyloop.dbo.Elements


--f
DROP TABLE IF EXISTS everyloop.dbo.ColorsCopy;

SELECT Name, Red, Green, Blue
INTO everyloop.dbo.ColorsCopy
FROM everyloop.dbo.Colors;

ALTER TABLE everyloop.dbo.ColorsCopy
ADD HexCode as
    CONCAT(
        '#',
        RIGHT('00' + FORMAT(Red, 'X'), 2),
        RIGHT('00' + FORMAT(Green, 'X'), 2),
        RIGHT('00' + FORMAT(Blue, 'X'), 2)
    );


--g
DROP TABLE IF EXISTS everyloop.dbo.TypesCopy;

SELECT Integer, String
INTO everyloop.dbo.TypesCopy
FROM everyloop.dbo.Types;

SELECT
Integer,
Integer * 0.01 as Float,
String,
DATETIMEFROMPARTS(2019, 1, 1, 9, Integer, 0, 0) as DateTime,
Integer % 2 as Bool
FROM everyloop.dbo.TypesCopy