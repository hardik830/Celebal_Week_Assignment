
-- ========================================
-- TABLE CREATION FOR TESTING TRIGGERS
-- ========================================

-- Drop and recreate Products table
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
GO
CREATE TABLE Products (
    ProductID INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(100),
    UnitsInStock INT,
    UnitPrice DECIMAL(10, 2)
);
GO

-- Drop and recreate Orders table
IF OBJECT_ID('Orders', 'U') IS NOT NULL DROP TABLE Orders;
GO
CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    CustomerID NVARCHAR(5),
    OrderDate DATETIME
);
GO

-- Drop and recreate Order Details table
IF OBJECT_ID('[Order Details]', 'U') IS NOT NULL DROP TABLE [Order Details];
GO
CREATE TABLE [Order Details] (
    OrderDetailID INT IDENTITY PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    UnitPrice DECIMAL(10, 2),
    Quantity SMALLINT,
    Discount REAL
);
GO

-- ========================================
-- TRIGGER 1: INSTEAD OF DELETE ON Orders
-- ========================================
CREATE TRIGGER trg_InsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM DELETED);

    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM DELETED);
END;
GO

-- ========================================
-- TRIGGER 2: INSTEAD OF INSERT ON Order Details
-- ========================================
CREATE TRIGGER trg_CheckStockBeforeInsert
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity SMALLINT, @UnitsInStock INT;

    SELECT @ProductID = ProductID, @Quantity = Quantity
    FROM INSERTED;

    SELECT @UnitsInStock = UnitsInStock
    FROM Products
    WHERE ProductID = @ProductID;

    IF @UnitsInStock >= @Quantity
    BEGIN
        INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
        SELECT OrderID, ProductID, UnitPrice, Quantity, Discount FROM INSERTED;

        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        RAISERROR('Insufficient stock to fulfill the order.', 16, 1);
    END
END;
GO

-- ========================================
-- SAMPLE DATA & TRIGGER TESTING
-- ========================================

-- Insert sample product
INSERT INTO Products (ProductName, UnitsInStock, UnitPrice)
VALUES ('Gaming Mouse', 50, 25.99);

-- Insert a new order
INSERT INTO Orders (CustomerID, OrderDate)
VALUES ('C001', GETDATE());

-- View current orders and products
SELECT * FROM Products;
SELECT * FROM Orders;
GO

-- Test: Insert Order Detail (Sufficient Stock)
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (1, 1, 25.99, 10, 0.0);  -- Should succeed and reduce stock to 40

-- Check updated stock
SELECT * FROM Products;
SELECT * FROM [Order Details];
GO

-- Test: Insert Order Detail (Insufficient Stock)
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (1, 1, 25.99, 100, 0.0);  -- Should fail with 'Insufficient stock' error
GO

--  Test: Delete order (should cascade delete order details too)
DELETE FROM Orders WHERE OrderID = 1;

-- Confirm deletion
SELECT * FROM Orders;
SELECT * FROM [Order Details];
GO
