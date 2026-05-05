USE everyloop;
GO


--1a
SELECT DISTINCT
    orders.ShipCity AS [City],
    details.ProductId AS [Product ID]
FROM everyloop.company.orders orders
JOIN everyloop.company.order_details details
    ON orders.id = details.OrderId
WHERE orders.ShipCity = 'London';

SELECT CAST(41.0 / 77 * 100 AS decimal(3, 1)) AS [Percentage of distinct products shipped to London];

/*
Orders innehöll städer och id,
rimligt nästa steg var att kolla i order_details.
Order details innehöll product id och samma id som orders.
Använde data från båda tabellerna för att ta fram alla distinkta kombinationer av stad och product id där stad = London
*/


--1b
SELECT DISTINCT
    orders.ShipCity AS [City],
    COUNT(details.ProductId) AS [distinct products shipped]
FROM everyloop.company.orders orders
JOIN everyloop.company.order_details details
    ON orders.id = details.OrderId
GROUP BY orders.ShipCity
ORDER BY COUNT(details.ProductId) DESC;

/*
återanvände query från 1a
grupperade på city och gjorde count på distinkta city-product kombinationer för varje stad
sorterade

SVAR: Boise, 69 distinct products shipped
*/


--1c
WITH [orders] as (
    SELECT
        orders.ShipCity AS [City],
        details.ProductId AS [Product ID],
        details.OrderId AS [Order ID],
        products.UnitPrice *  (1 - details.Discount) AS [Sold for]
    FROM everyloop.company.orders orders
    JOIN everyloop.company.order_details details
        ON orders.id = details.OrderId
    JOIN everyloop.company.products products
        ON details.ProductId = products.Id
    WHERE orders.ShipCountry = 'Germany' 
        AND products.Discontinued = 1
)
SELECT CAST(ROUND(SUM([Sold for]), 1) AS decimal(4, 1)) AS [Total price of all discontinued products sold to Germany]
FROM [orders];

/*
återanvände delar av query från 1a
JOIN med orders, order details och products för att få all data
räknade ut priset med discounts för alla varor där discontinued = 1
skrev ut summan av alla priser, avrundat till en decimal

SVAR: 532.1
*/


--1d
SELECT
    CategoryId,
    sum(UnitPrice) AS Value,
    COUNT(UnitsInStock) AS Units
FROM everyloop.company.products
GROUP BY CategoryId
ORDER BY sum(UnitPrice) DESC

/*
select alla relevanta data ur products
group by catrgory
enkel sum för att få fram värde
sortera

SVAR: category 1
*/


--1e
SELECT
    MAX(suppliers.CompanyName) AS [Company],
    COUNT(orders.Id) AS [Number of orders]
FROM everyloop.company.orders orders
JOIN everyloop.company.suppliers suppliers
    ON orders.ShipVia = suppliers.Id
WHERE orders.OrderDate >= '2013-06-01'
  AND orders.OrderDate < '2013-09-01'
GROUP BY orders.ShipVia
ORDER BY COUNT(orders.Id) DESC;

/*
select
join på shipping id
sortera bor allt som inte är sommar 2013
gruppera på företag
sortera efter flest orders

SVAR: New Orleans Cajun Delights
*/