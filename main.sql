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