-- ============================================================
-- E-COMMERCE SALES ANALYTICS PROJECT
-- Full Implementation in One MySQL File
-- ============================================================

-- Drop old DB if exists
DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

-- ======================
-- 1. Create Tables
-- ======================

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Country VARCHAR(100)
);

CREATE TABLE Products (
    StockCode VARCHAR(20) PRIMARY KEY,
    Description VARCHAR(255),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE Orders (
    InvoiceNo VARCHAR(20),
    CustomerID INT,
    InvoiceDate DATETIME,
    StockCode VARCHAR(20),
    Quantity INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StockCode) REFERENCES Products(StockCode)
);

-- ======================
-- 2. Insert Sample Data
-- (Demo only; replace with CSV import later)
-- ======================

-- Customers
INSERT INTO Customers VALUES
(1001, 'United Kingdom'),
(1002, 'Germany'),
(1003, 'France'),
(1004, 'Netherlands');

-- Products
INSERT INTO Products VALUES
('P001', 'White Mug', 3.50),
('P002', 'Black T-Shirt', 12.00),
('P003', 'Blue Notebook', 2.00),
('P004', 'Headphones', 25.00),
('P005', 'Laptop Bag', 45.00);

-- Orders
INSERT INTO Orders VALUES
('INV001', 1001, '2025-09-01 10:00:00', 'P001', 10),
('INV002', 1001, '2025-09-02 11:30:00', 'P002', 2),
('INV003', 1002, '2025-09-03 09:15:00', 'P004', 1),
('INV004', 1003, '2025-09-05 14:00:00', 'P003', 20),
('INV005', 1004, '2025-09-05 16:45:00', 'P005', 3),
('INV006', 1002, '2025-09-06 12:10:00', 'P001', 5),
('INV007', 1001, '2025-09-07 15:25:00', 'P004', 2),
('INV008', 1003, '2025-09-07 17:40:00', 'P002', 1);

-- ======================
-- 3. Example Queries
-- ======================

-- 3.1 Top 10 Best-Selling Products
CREATE OR REPLACE VIEW TopProducts AS
SELECT p.Description, SUM(o.Quantity) AS TotalSold
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalSold DESC
LIMIT 10;

-- 3.2 Revenue by Country
CREATE OR REPLACE VIEW RevenueByCountry AS
SELECT c.Country, ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS Revenue
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY c.Country
ORDER BY Revenue DESC;

-- 3.3 Monthly Sales Trend
CREATE OR REPLACE VIEW MonthlySales AS
SELECT DATE_FORMAT(o.InvoiceDate, '%Y-%m') AS Month,
       ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS MonthlyRevenue
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY Month
ORDER BY Month;

-- 3.4 Customer Lifetime Value (CLV)
CREATE OR REPLACE VIEW CustomerValue AS
SELECT o.CustomerID,
       ROUND(SUM(o.Quantity * p.UnitPrice), 2) AS TotalSpent
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY o.CustomerID
ORDER BY TotalSpent DESC;

-- 3.5 RFM Analysis
CREATE OR REPLACE VIEW CustomerRFM AS
SELECT CustomerID,
       MAX(InvoiceDate) AS LastPurchase,
       COUNT(DISTINCT InvoiceNo) AS Frequency,
       ROUND(SUM(Quantity * UnitPrice), 2) AS Monetary
FROM Orders o
JOIN Products p ON o.StockCode = p.StockCode
GROUP BY CustomerID;

-- ======================
-- 4. Test the Views
-- ======================
SELECT * FROM TopProducts;
SELECT * FROM RevenueByCountry;
SELECT * FROM MonthlySales;
SELECT * FROM CustomerValue;
SELECT * FROM CustomerRFM;
