

-- 1. Retrieve all customer records
SELECT * FROM Sales.Customer;

-- 2. Customers where the company name ends with 'N'
SELECT * FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

-- 3. Customers residing in Berlin or London
SELECT * FROM Person.Address a
WHERE City IN ('Berlin', 'London');

-- 4. Customers located in UK or USA based on region code
SELECT * FROM Person.Address a
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode IN ('GB', 'US');

-- 5. List all products sorted alphabetically by name
SELECT * FROM Production.Product ORDER BY Name;

-- 6. Products with names starting with 'A'
SELECT * FROM Production.Product WHERE Name LIKE 'A%';

-- 7. Customers who have placed at least one order
SELECT DISTINCT c.* FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID;

-- 8. London-based customers who purchased 'Chai' (Product name match assumed)
SELECT DISTINCT c.* FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID
JOIN Person.Address a ON c.CustomerID = a.AddressID
WHERE a.City = 'London' AND p.Name LIKE '%Chai%';

-- 9. Customers who have never placed an order
SELECT * FROM Sales.Customer c
WHERE NOT EXISTS (
  SELECT 1 FROM Sales.SalesOrderHeader h WHERE c.CustomerID = h.CustomerID
);

-- 10. Customers who purchased 'Tofu'
SELECT DISTINCT c.* FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID
WHERE p.Name LIKE '%Tofu%';

-- 11. The very first order by order date
SELECT TOP 1 * FROM Sales.SalesOrderHeader ORDER BY OrderDate;

-- 12. Order with the highest total due amount
SELECT TOP 1 * FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC;

-- 13. Average quantity per order
SELECT SalesOrderID, AVG(OrderQty) AS AvgQty
FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

-- 14. Minimum and maximum quantity in each order
SELECT SalesOrderID, MIN(OrderQty) AS MinQty, MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

-- 15. Managers and the number of employees they manage
SELECT e.ManagerID, COUNT(e.BusinessEntityID) AS NumEmployees
FROM HumanResources.Employee e
WHERE e.ManagerID IS NOT NULL
GROUP BY e.ManagerID;

-- 16. Orders with a combined quantity above 300
SELECT SalesOrderID, SUM(OrderQty) AS TotalQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- 17. Orders placed on or after a specific date
SELECT * FROM Sales.SalesOrderHeader WHERE OrderDate >= '1996-12-31';

-- 18. Orders shipped to Canada using country code
SELECT * FROM Sales.SalesOrderHeader WHERE ShipToAddressID IN (
  SELECT AddressID FROM Person.Address WHERE CountryRegionCode = 'CA'
);

-- 19. Orders where the total amount due exceeds 200
SELECT * FROM Sales.SalesOrderHeader WHERE TotalDue > 200;

-- 20. Total sales grouped by country shipped to
SELECT ShipToCountryRegion AS Country, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY ShipToCountryRegion;

-- 21. Customer name and count of orders placed
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(h.SalesOrderID) AS Orders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
GROUP BY p.FirstName, p.LastName;

-- 22. Customers who have placed more than three orders
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(h.SalesOrderID) AS Orders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(h.SalesOrderID) > 3;

-- 23. Discontinued products ordered between two dates
SELECT DISTINCT p.ProductID, p.Name
FROM Production.Product p
JOIN Sales.SalesOrderDetail d ON p.ProductID = d.ProductID
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL
  AND h.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. Employee names along with their supervisor's names
SELECT e.BusinessEntityID, p.FirstName, p.LastName,
       sup.BusinessEntityID AS SupervisorID, pSup.FirstName AS SupFirst, pSup.LastName AS SupLast
FROM HumanResources.Employee e
LEFT JOIN HumanResources.Employee sup ON e.ManagerID = sup.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Person.Person pSup ON sup.BusinessEntityID = pSup.BusinessEntityID;

-- 25. Total sales by employee (salesperson)
SELECT h.SalesPersonID, SUM(h.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader h
GROUP BY h.SalesPersonID;

-- 26. Employees whose first name contains the letter 'a'
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE '%a%';

-- 27. Managers who manage more than four employees
SELECT e.ManagerID, COUNT(e.BusinessEntityID) AS Reportees
FROM HumanResources.Employee e
WHERE e.ManagerID IS NOT NULL
GROUP BY e.ManagerID
HAVING COUNT(e.BusinessEntityID) > 4;

-- 28. Orders and corresponding product names and quantities
SELECT h.SalesOrderID, p.Name AS ProductName, d.OrderQty
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID;

-- 29. Orders placed by the top-spending customer
;WITH Spend AS (
  SELECT CustomerID, SUM(TotalDue) AS TotalSpent
  FROM Sales.SalesOrderHeader
  GROUP BY CustomerID
), TopCustomer AS (
  SELECT TOP 1 CustomerID FROM Spend ORDER BY TotalSpent DESC
)
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID = (SELECT CustomerID FROM TopCustomer);

-- 30. Orders from customers without a fax number
SELECT h.*
FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.Fax IS NULL OR p.Fax = '';

-- 31. Postal codes where the product 'Tofu' was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID
JOIN Person.Address a ON h.ShipToAddressID = a.AddressID
WHERE p.Name LIKE '%Tofu%';

-- 32. Product names that were shipped to France
SELECT DISTINCT p.Name
FROM Production.Product p
JOIN Sales.SalesOrderDetail d ON p.ProductID = d.ProductID
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN Person.Address a ON h.ShipToAddressID = a.AddressID
WHERE a.CountryRegionCode = 'FR';

-- 33. Products and categories for vendor 'Specialty Biscuits, Ltd.'
SELECT p.Name, pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

-- 34. Products that have never been ordered
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail d ON p.ProductID = d.ProductID
WHERE d.SalesOrderID IS NULL;

-- 35. Products with stock level < 10 and no pending orders
SELECT ProductID, Name, SafetyStockLevel, ReorderPoint
FROM Production.Product
WHERE SafetyStockLevel < 10 AND ReorderPoint = 0;

-- 36. Top 10 countries based on total sales
SELECT TOP 10 ShipToCountryRegion AS Country, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY ShipToCountryRegion
ORDER BY TotalSales DESC;

-- 37. Orders handled by employees for customers with account numbers between A and AO
SELECT h.SalesPersonID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
WHERE c.AccountNumber BETWEEN 'A' AND 'AO'
GROUP BY h.SalesPersonID;

-- 38. Date of the highest-value order
SELECT TOP 1 OrderDate FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC;

-- 39. Product names and their total revenue
SELECT p.Name, SUM(d.LineTotal) AS TotalRevenue
FROM Production.Product p
JOIN Sales.SalesOrderDetail d ON p.ProductID = d.ProductID
GROUP BY p.Name;

-- 40. Top 10 customers based on total spending
SELECT TOP 10 c.CustomerID, p.FirstName + ' ' + p.LastName AS Name, SUM(h.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSpent DESC;

-- 41. Total revenue generated by the company
SELECT SUM(TotalDue) AS TotalRevenue FROM Sales.SalesOrderHeader;
