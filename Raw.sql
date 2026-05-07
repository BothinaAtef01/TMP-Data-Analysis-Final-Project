CREATE DATABASE Raw_Superstore;
USE Raw_Superstore;

CREATE TABLE Customers (
    CustomerID NVARCHAR(50) PRIMARY KEY,
    CustomerName NVARCHAR(255) NOT NULL,
    Segment NVARCHAR(50)
);

CREATE TABLE Products (
    ProductID NVARCHAR(50) PRIMARY KEY,
    ProductName NVARCHAR(MAX),
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100)
);

CREATE TABLE Geography (
    PostalCode NVARCHAR(20) PRIMARY KEY,
    City NVARCHAR(100),
    State NVARCHAR(100),
    Region NVARCHAR(50),
    Country NVARCHAR(50)
);

CREATE TABLE Orders (
    RowID INT PRIMARY KEY,
    OrderID NVARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode NVARCHAR(50),
    CustomerID NVARCHAR(50),
    ProductID NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Sales DECIMAL(18, 4),
    Quantity INT,
    Discount DECIMAL(18, 4),
    Profit DECIMAL(18, 4),
    
    CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_Geo FOREIGN KEY (PostalCode) REFERENCES Geography(PostalCode)
);


INSERT INTO Products (ProductID, ProductName, Category, SubCategory)
SELECT [Product_ID], MAX([Product_Name]), MAX([Category]), MAX([Sub_Category])
FROM sample_superstore
GROUP BY [Product_ID]; 

INSERT INTO Customers (CustomerID, CustomerName, Segment)
SELECT [Customer_ID], MAX([Customer_Name]), MAX([Segment])
FROM sample_superstore
GROUP BY [Customer_ID];

INSERT INTO Geography (PostalCode, City, State, Region, Country)
SELECT [Postal_Code], MAX([City]), MAX([State]), MAX([Region]), MAX([Country])
FROM sample_superstore
GROUP BY [Postal_Code];

INSERT INTO Orders (RowID, OrderID, OrderDate, ShipDate, ShipMode, CustomerID, ProductID, PostalCode, Sales, Quantity, Discount, Profit)
SELECT 
    [Row_ID], [Order_ID], [Order_Date], [Ship_Date], [Ship_Mode], 
    [Customer_ID], [Product_ID], [Postal_Code], [Sales], [Quantity], [Discount], [Profit]
FROM sample_superstore;



-- Quires
SELECT * FROM Orders;

--top 10 product names according to the sum of profit
SELECT TOP 10 p.ProductName, SUM(o.Sales) as TotalSales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;

-- order occure with first class ship mode
SELECT OrderID, OrderDate, CustomerID 
   FROM Orders 
   WHERE ShipMode = 'First Class';

--sum of profit for each state
SELECT g.State, SUM(o.Profit) as TotalProfit
FROM Orders o
JOIN Geography g ON o.PostalCode = g.PostalCode
GROUP BY g.State
ORDER BY TotalProfit DESC;

-- products gets no profits
SELECT p.ProductName, SUM(o.Profit) as TotalLoss
   FROM Orders o
   JOIN Products p ON o.ProductID = p.ProductID
   GROUP BY p.ProductName
   HAVING SUM(o.Profit) < 0;
   
--most product category demanded by quantity
SELECT p.Category, SUM(o.Quantity) as TotalQuantity
   FROM Orders o
   JOIN Products p ON o.ProductID = p.ProductID
   GROUP BY p.Category;