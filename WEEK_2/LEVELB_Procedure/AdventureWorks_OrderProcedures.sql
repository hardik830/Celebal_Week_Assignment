
-- ========================================
-- Procedure 1: InsertOrderDetails
-- ========================================
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @OrderQty SMALLINT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStock INT, @ReorderLevel INT, @DefaultUnitPrice MONEY;

    SELECT @CurrentStock = p.SafetyStockLevel,  -- assuming as stock
           @ReorderLevel = p.ReorderPoint,
           @DefaultUnitPrice = p.ListPrice
    FROM Production.Product p
    WHERE p.ProductID = @ProductID;

    IF @CurrentStock IS NULL
    BEGIN
        PRINT 'Invalid ProductID';
        RETURN;
    END

    IF @CurrentStock < @OrderQty
    BEGIN
        PRINT 'Not enough stock available. Order aborted.';
        RETURN;
    END

    SET @UnitPrice = ISNULL(@UnitPrice, @DefaultUnitPrice);

    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount)
    VALUES (@OrderID, @ProductID, @OrderQty, @UnitPrice, @Discount);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Production.Product
    SET SafetyStockLevel = SafetyStockLevel - @OrderQty
    WHERE ProductID = @ProductID;

    IF EXISTS (
        SELECT 1 FROM Production.Product
        WHERE ProductID = @ProductID AND SafetyStockLevel < ReorderPoint
    )
    BEGIN
        PRINT 'Warning: Stock below reorder level for product ID ' + CAST(@ProductID AS VARCHAR);
    END
END;
GO

-- ========================================
-- Procedure 2: UpdateOrderDetails
-- ========================================
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @OrderQty SMALLINT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQty INT;

    SELECT @OldQty = OrderQty
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQty IS NULL
    BEGIN
        PRINT 'Order or Product not found.';
        RETURN;
    END

    UPDATE Sales.SalesOrderDetail
    SET
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        OrderQty = ISNULL(@OrderQty, OrderQty),
        UnitPriceDiscount = ISNULL(@Discount, UnitPriceDiscount)
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OrderQty IS NOT NULL
    BEGIN
        DECLARE @QtyDiff INT = @OldQty - @OrderQty;
        UPDATE Production.Product
        SET SafetyStockLevel = SafetyStockLevel + @QtyDiff
        WHERE ProductID = @ProductID;
    END
END;
GO

-- ========================================
-- Procedure 3: GetOrderDetails
-- ========================================
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END

    SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID;
END;
GO

-- ========================================
-- Procedure 4: DeleteOrderDetails
-- ========================================
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Invalid parameters: Either OrderID or ProductID is incorrect.';
        RETURN -1;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail deleted successfully.';
END;
GO
