
-- ========================================
-- ✅ View 1: vwCustomerOrders
-- ========================================
IF OBJECT_ID('vwCustomerOrders', 'V') IS NOT NULL
    DROP VIEW vwCustomerOrders;
GO

CREATE VIEW vwCustomerOrders AS
SELECT 
    s.Name AS CompanyName,
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    od.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    od.OrderQty * od.UnitPrice AS TotalPrice
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product p ON od.ProductID = p.ProductID
JOIN Sales.Customer c ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID;
GO

-- ========================================
-- ✅ View 2: vwCustomerOrders_Yesterday
-- ========================================
IF OBJECT_ID('vwCustomerOrders_Yesterday', 'V') IS NOT NULL
    DROP VIEW vwCustomerOrders_Yesterday;
GO

CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    s.Name AS CompanyName,
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    od.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    od.OrderQty * od.UnitPrice AS TotalPrice
FROM Sales.SalesOrderHeader o
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product p ON od.ProductID = p.ProductID
JOIN Sales.Customer c ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE CAST(o.OrderDate AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
GO

-- ========================================
-- ✅ View 3: MyProducts
-- ========================================
IF OBJECT_ID('MyProducts', 'V') IS NOT NULL
    DROP VIEW MyProducts;
GO

CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Size + ' ' + ISNULL(p.WeightUnitMeasureCode, '') AS QuantityPerUnit,
    p.ListPrice AS UnitPrice,
    v.Name AS CompanyName,
    c.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE p.DiscontinuedDate IS NULL;
GO
