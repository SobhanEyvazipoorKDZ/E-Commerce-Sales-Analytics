-- ============================================================
-- E-COMMERCE SALES ANALYTICS PROJECT 
-- ============================================================

-- Drop old DB if exists
IF DB_ID('Ecommerce') IS NOT NULL
    DROP DATABASE Ecommerce;
GO

CREATE DATABASE Ecommerce;
GO
USE Ecommerce;
GO

-- ======================
-- 1. Create Tables
-- ======================

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Country NVARCHAR(100)
);

CREATE TABLE Products (
    StockCode NVARCHAR(20) PRIMARY KEY,
    Description NVARCHAR(255),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE Orders (
    InvoiceNo NVARCHAR(20),
    CustomerID INT,
    InvoiceDate DATETIME,
    StockCode NVARCHAR(20),
    Quantity INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StockCode) REFERENCES Products(StockCode)
);
GO

-- ======================
-- 2. Insert Sample Data
-- ======================

INSERT INTO Customers VALUES
(1001, N'United Kingdom'),
(1002, N'Germany'),
(1003, N'France'),
(1004, N'Netherlands');
GO

INSERT INTO Products VALUES
(N'P001', N'White Mug', 3.50),
(N'P002', N'Black T-Shirt', 12.00),
(N'P003', N'Blue Notebook', 2.00),
(N'P004', N'Headphones', 25.00),
(N'P005', N'Laptop Bag', 45.00);
GO

INSERT INTO Orders VALUES
(N'INV001', 1001, '2025-09-01 10:00:00', N'P001', 10),
(N'INV002', 1001, '2025-09-02 11:30:00', N'P002', 2),
(N'INV003', 1002, '2025-09-03 09:15:00', N'P004', 1),
(N'INV004', 1003, '2025-09-05 14:00:00', N'P003', 20),
(N'INV005', 1004, '2025-09-05 16:45:00', N'P005', 3),
(N'INV006', 1002, '2025-09-06 12:10:00', N'P001', 5),
(N'INV007', 1001, '2025-09-07 15:25:00', N'P004', 2),
(N'INV008', 1003, '2025-09-07 17:40:00', N'P002', 1);
GO

-- ======================
-- 3. Create Views
-- ======================

-- 3.1 Top 10 Best-Selling Products
IF OBJECT_ID('TopProducts', 'V') IS NOT NULL DROP VIEW TopProducts;
GO
CREATE VIEW TopProducts AS
SELECT TOP 10 
    p.Description,
    SUM(o.Quantity) AS TotalSold
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalSold DESC;
GO

-- 3.2 Revenue by Country
IF OBJECT_ID('RevenueByCountry', 'V') IS NOT NULL DROP VIEW RevenueByCountry;
GO
CREATE VIEW RevenueByCountry AS
SELECT 
    c.Country,
    ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS Revenue
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY c.Country
ORDER BY Revenue DESC;
GO

-- 3.3 Monthly Sales Trend
IF OBJECT_ID('MonthlySales', 'V') IS NOT NULL DROP VIEW MonthlySales;
GO
CREATE VIEW MonthlySales AS
SELECT 
    FORMAT(o.InvoiceDate, 'yyyy-MM') AS Month,
    ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS MonthlyRevenue
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY FORMAT(o.InvoiceDate, 'yyyy-MM')
ORDER BY Month;
GO

-- 3.4 Customer Lifetime Value (CLV)
IF OBJECT_ID('CustomerValue', 'V') IS NOT NULL DROP VIEW CustomerValue;
GO
CREATE VIEW CustomerValue AS
SELECT 
    o.CustomerID,
    ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS TotalSpent
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY o.CustomerID
ORDER BY TotalSpent DESC;
GO

-- 3.5 RFM Analysis
IF OBJECT_ID('CustomerRFM', 'V') IS NOT NULL DROP VIEW CustomerRFM;
GO
CREATE VIEW CustomerRFM AS
SELECT 
    o.CustomerID,
    MAX(o.InvoiceDate) AS LastPurchase,
    COUNT(DISTINCT o.InvoiceNo) AS Frequency,
    ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS Monetary
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY o.CustomerID;
GO

-- ======================
-- 4. Test the Views
-- ======================
SELECT * FROM TopProducts;
SELECT * FROM RevenueByCountry;
SELECT * FROM MonthlySales;
SELECT * FROM CustomerValue;
SELECT * FROM CustomerRFM;
GO
