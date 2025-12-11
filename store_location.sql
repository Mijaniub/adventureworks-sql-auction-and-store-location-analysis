USE AdventureWorks;
GO

-- Step 1: Get top 30 store customers by total sales
WITH StoreCustomerSales AS (
    SELECT 
        c.CustomerID,
        a.City,
        a.StateProvinceID,
        SUM(soh.TotalDue) AS TotalSales
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = c.PersonID
    JOIN Person.Address a ON a.AddressID = bea.AddressID
    WHERE c.StoreID IS NOT NULL
    GROUP BY c.CustomerID, a.City, a.StateProvinceID
),
Top30StoreCities AS (
    SELECT TOP 30 City, StateProvinceID
    FROM StoreCustomerSales
    ORDER BY TotalSales DESC
)

-- Step 2: Get individual (non-store) customer sales grouped by city
, IndividualCustomerSales AS (
    SELECT 
        a.City,
        a.StateProvinceID,
        SUM(soh.TotalDue) AS TotalSales
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
    JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = c.PersonID
    JOIN Person.Address a ON a.AddressID = bea.AddressID
    JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
    WHERE c.StoreID IS NULL AND p.PersonType = 'IN'
    GROUP BY a.City, a.StateProvinceID
)

-- Step 3: Filter out cities that are in the top 30 store customer list
SELECT TOP 10
    ics.City,
    sp.Name AS State,
    ics.TotalSales
FROM IndividualCustomerSales ics
JOIN Person.StateProvince sp ON sp.StateProvinceID = ics.StateProvinceID
WHERE NOT EXISTS (
    SELECT 1
    FROM Top30StoreCities tsc
    WHERE tsc.City = ics.City AND tsc.StateProvinceID = ics.StateProvinceID
)
ORDER BY ics.TotalSales DESC;
