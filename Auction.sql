-- ===============================================
-- Script: auction.sql
-- Purpose: Extend AdventureWorks schema to support auctions
-- ===============================================

-- Ensure script is idempotent
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Auction')
    EXEC('CREATE SCHEMA Auction');
GO

-- ===============================================
-- Configuration Table
-- ===============================================
IF OBJECT_ID('Auction.Configuration', 'U') IS NULL
BEGIN
    CREATE TABLE Auction.Configuration (
        ConfigKey NVARCHAR(50) PRIMARY KEY,
        ConfigValue MONEY NOT NULL
    );

    INSERT INTO Auction.Configuration (ConfigKey, ConfigValue)
    VALUES
        ('MinBidIncrement', 0.05),
        ('MaxBidCapFactor', 1.00);
END
GO

-- ===============================================
-- ProductAuction Table
-- ===============================================
IF OBJECT_ID('Auction.ProductAuction', 'U') IS NULL
BEGIN
    CREATE TABLE Auction.ProductAuction (
        ProductID INT PRIMARY KEY,
        StartDate DATETIME NOT NULL DEFAULT GETDATE(),
        ExpireDate DATETIME NOT NULL,
        InitialBidPrice MONEY NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_ProductAuction_Product FOREIGN KEY (ProductID)
            REFERENCES Production.Product(ProductID)
    );
END
GO

-- ===============================================
-- Bid Table
-- ===============================================
IF OBJECT_ID('Auction.Bid', 'U') IS NULL
BEGIN
    CREATE TABLE Auction.Bid (
        BidID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        CustomerID INT NOT NULL,
        BidAmount MONEY NOT NULL,
        BidTime DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Bid_Product FOREIGN KEY (ProductID) REFERENCES Auction.ProductAuction(ProductID),
        CONSTRAINT FK_Bid_Customer FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID)
    );
END
GO

-- ===============================================
-- Stored Procedure: uspAddProductToAuction
-- ===============================================
IF OBJECT_ID('Auction.uspAddProductToAuction', 'P') IS NULL
    EXEC('CREATE PROCEDURE Auction.uspAddProductToAuction AS RETURN');
GO

ALTER PROCEDURE Auction.uspAddProductToAuction
    @ProductID INT,
    @ExpireDate DATETIME = NULL,
    @InitialBidPrice MONEY = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Auction.ProductAuction WHERE ProductID = @ProductID AND IsActive = 1)
            THROW 50001, 'Product is already listed in an active auction.', 1;

        DECLARE @ListPrice MONEY, @MakeFlag BIT;

        SELECT @ListPrice = ListPrice, @MakeFlag = MakeFlag
        FROM Production.Product
        WHERE ProductID = @ProductID AND SellEndDate IS NULL AND DiscontinuedDate IS NULL;

        IF @ListPrice IS NULL
            THROW 50002, 'Invalid or discontinued product.', 1;

        IF @InitialBidPrice IS NULL
            SET @InitialBidPrice = @ListPrice * (CASE WHEN @MakeFlag = 0 THEN 0.75 ELSE 0.5 END);

        IF @ExpireDate IS NULL
            SET @ExpireDate = DATEADD(DAY, 7, GETDATE());

        INSERT INTO Auction.ProductAuction (ProductID, ExpireDate, InitialBidPrice)
        VALUES (@ProductID, @ExpireDate, @InitialBidPrice);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ===============================================
-- Stored Procedure: uspTryBidProduct
-- ===============================================
IF OBJECT_ID('Auction.uspTryBidProduct', 'P') IS NULL
    EXEC('CREATE PROCEDURE Auction.uspTryBidProduct AS RETURN');
GO

ALTER PROCEDURE Auction.uspTryBidProduct
    @ProductID INT,
    @CustomerID INT,
    @BidAmount MONEY = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @InitialBid MONEY, @CurrentMax MONEY, @Increment MONEY, @Cap MONEY;

        SELECT @InitialBid = InitialBidPrice
        FROM Auction.ProductAuction
        WHERE ProductID = @ProductID AND IsActive = 1;

        IF @InitialBid IS NULL
            THROW 50003, 'Product is not available for bidding.', 1;

        SELECT @CurrentMax = MAX(BidAmount)
        FROM Auction.Bid
        WHERE ProductID = @ProductID;

        SELECT @Increment = ConfigValue FROM Auction.Configuration WHERE ConfigKey = 'MinBidIncrement';
        SELECT @Cap = @InitialBid FROM Auction.Configuration WHERE ConfigKey = 'MaxBidCapFactor';

        SET @Cap = @Cap * (SELECT ListPrice FROM Production.Product WHERE ProductID = @ProductID);

        IF @BidAmount IS NULL
            SET @BidAmount = ISNULL(@CurrentMax, @InitialBid) + @Increment;

        IF @BidAmount > @Cap
            THROW 50004, 'Bid amount exceeds maximum allowed bid.', 1;

        INSERT INTO Auction.Bid (ProductID, CustomerID, BidAmount)
        VALUES (@ProductID, @CustomerID, @BidAmount);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ===============================================
-- Stored Procedure: uspRemoveProductFromAuction
-- ===============================================
IF OBJECT_ID('Auction.uspRemoveProductFromAuction', 'P') IS NULL
    EXEC('CREATE PROCEDURE Auction.uspRemoveProductFromAuction AS RETURN');
GO

ALTER PROCEDURE Auction.uspRemoveProductFromAuction
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Auction.ProductAuction
        SET IsActive = 0
        WHERE ProductID = @ProductID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ===============================================
-- Stored Procedure: uspListBidsOffersHistory
-- ===============================================
IF OBJECT_ID('Auction.uspListBidsOffersHistory', 'P') IS NULL
    EXEC('CREATE PROCEDURE Auction.uspListBidsOffersHistory AS RETURN');
GO

ALTER PROCEDURE Auction.uspListBidsOffersHistory
    @CustomerID INT,
    @StartTime DATETIME,
    @EndTime DATETIME,
    @Active BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT B.BidID, B.ProductID, P.Name, B.BidAmount, B.BidTime, A.IsActive
        FROM Auction.Bid B
        JOIN Production.Product P ON B.ProductID = P.ProductID
        JOIN Auction.ProductAuction A ON A.ProductID = B.ProductID
        WHERE B.CustomerID = @CustomerID
            AND B.BidTime BETWEEN @StartTime AND @EndTime
            AND (@Active = 0 OR A.IsActive = 1);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- ===============================================
-- Stored Procedure: uspUpdateProductAuctionStatus
-- ===============================================
IF OBJECT_ID('Auction.uspUpdateProductAuctionStatus', 'P') IS NULL
    EXEC('CREATE PROCEDURE Auction.uspUpdateProductAuctionStatus AS RETURN');
GO

ALTER PROCEDURE Auction.uspUpdateProductAuctionStatus
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Auction.ProductAuction
        SET IsActive = 0
        WHERE IsActive = 1 AND ExpireDate <= GETDATE();
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

------------------------------------------------ PROCEDURES TEST ------------------------------------------------

-- Query for Sellable Products
SELECT 
    ProductID,
    Name,
    ListPrice,
    SellStartDate,
    SellEndDate,
    DiscontinuedDate
FROM 
    Production.Product
WHERE 
    DiscontinuedDate IS NULL
    AND (SellEndDate IS NULL OR SellEndDate > GETDATE());



-- Replace with a valid ProductID that is active
DECLARE @ProductID INT = 907;  -- Example ProductID
EXEC Auction.uspAddProductToAuction
    @ProductID = @ProductID;
-- Check product auction status
SELECT * FROM Auction.ProductAuction WHERE ProductID = 907;


-- Replace with a valid ProductID from ProductAuction and an existing CustomerID
DECLARE @ProductID INT = 907;
DECLARE @CustomerID INT = 11000;

EXEC Auction.uspTryBidProduct
    @ProductID = @ProductID,
    @CustomerID = @CustomerID;
-- View all bids for a product
SELECT * FROM Auction.Bid WHERE ProductID = 907;


-- Replace with a valid ProductID that is active in Auction.ProductAuction
DECLARE @ProductID INT = 907;
EXEC Auction.uspRemoveProductFromAuction @ProductID = @ProductID;
-- Verify the result
SELECT ProductID, IsActive
FROM Auction.ProductAuction
WHERE ProductID = 907;


-- Replace with a valid CustomerID and adjust time range as needed
DECLARE @CustomerID INT = 11000;
DECLARE @StartTime DATETIME = DATEADD(DAY, -30, GETDATE());
DECLARE @EndTime DATETIME = GETDATE();

EXEC Auction.uspListBidsOffersHistory
    @CustomerID = @CustomerID,
    @StartTime = @StartTime,
    @EndTime = @EndTime,
    @Active = 1;  -- Set to 0 for all bids, 1 for only active auctions


--Test for Auction.uspUpdateProductAuctionStatus

---- Declare current datetime in a variable
DECLARE @Now DATETIME = GETDATE();
DECLARE @ProductID INT = 907; -- Replace with an actual ProductID from your data

---- Force auction expiration to a past date
UPDATE Auction.ProductAuction
SET ExpireDate = DATEADD(DAY, -1, @Now), IsActive = 1
WHERE ProductID = @ProductID;

---- Execute the update procedure
EXEC Auction.uspUpdateProductAuctionStatus;

---- Verify the auction is now inactive
SELECT ProductID, IsActive, ExpireDate
FROM Auction.ProductAuction
WHERE ProductID = @ProductID;