CREATE DATABASE OnlineRetailDB;
USE OnlineRetailDB;

CREATE TABLE online_retail_staging (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100)
);


import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="NewPassword123!",
    database="OnlineRetailDB"
)

cursor = conn.cursor()

SHOW TABLES;

SELECT COUNT(*) AS total_rows
FROM online_retail_staging;


SELECT
    COUNT(*) AS total_rows,
    COUNT(InvoiceNo) AS invoice_no_filled,
    COUNT(StockCode) AS stock_code_filled,
    COUNT(Description) AS description_filled,
    COUNT(Quantity) AS quantity_filled,
    COUNT(InvoiceDate) AS invoice_date_filled,
    COUNT(UnitPrice) AS unit_price_filled,
    COUNT(CustomerID) AS customer_id_filled,
    COUNT(Country) AS country_filled
FROM online_retail_staging;

SELECT
    COUNT(*)-COUNT(InvoiceNo) AS invoice_no_filled,
	COUNT(*)-COUNT(StockCode) AS stock_code_filled,
      COUNT(*)-COUNT(Description) AS description_filled,
     COUNT(*)-COUNT(Quantity) AS quantity_filled,
      COUNT(*)-COUNT(InvoiceDate) AS invoice_date_filled,
      COUNT(*)-COUNT(UnitPrice) AS unit_price_filled,
      COUNT(*)-COUNT(CustomerID) AS customer_id_filled,
      COUNT(*)-COUNT(Country) AS country_filled
FROM online_retail_staging;

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country) AS unique_rows
FROM online_retail_staging;

SELECT COUNT(*) AS cancellation
FROM online_retail_staging
WHERE InvoiceNo Like 'C%';

SELECT COUNT(*) AS negative_quantity
FROM online_retail_staging
WHERE Quantity < 0;

SELECT COUNT(*) AS zero_price
FROM online_retail_staging
WHERE UnitPrice = 0;

SELECT COUNT(*) AS invalid_dates
FROM online_retail_staging
WHERE InvoiceDate IS NULL;

SELECT COUNT(*) AS missing_customer_id
FROM online_retail_staging
WHERE CustomerID IS NULL;

SELECT COUNT(*) AS missing_description
FROM online_retail_staging
WHERE Description IS NULL;

SELECT COUNT(*) AS missing_unit_price
FROM online_retail_staging
WHERE UnitPrice IS NULL;

SELECT COUNT(*) AS missing_quantity
FROM online_retail_staging
WHERE Quantity IS NULL;

SELECT COUNT(*) AS missing_invoice_no
FROM online_retail_staging
WHERE InvoiceNo IS NULL;

SELECT COUNT(*) AS missing_stock_code
FROM online_retail_staging
WHERE StockCode IS NULL;

SELECT COUNT(*) AS missing_country
FROM online_retail_staging
WHERE Country IS NULL;

SELECT COUNT(*) AS negative_price
FROM online_retail_staging
WHERE UnitPrice < 0;

SELECT COUNT(*) AS blank_stock_code
FROM online_retail_staging
WHERE TRIM(StockCode) = '';

SELECT COUNT(*) AS blank_description
FROM online_retail_staging
WHERE TRIM(Description) = '';

SELECT COUNT(*) AS negative_not_cancelled
FROM online_retail_staging
WHERE InvoiceNo NOT LIKE 'C%'
AND Quantity < 0;

SELECT COUNT(*) AS invalid_customer_id
FROM online_retail_staging
WHERE CustomerID <= 0;

SELECT
    MIN(UnitPrice) AS minimum_price,
    MAX(UnitPrice) AS maximum_price
FROM online_retail_staging;

SELECT *
FROM online_retail_staging
WHERE UnitPrice < 0;

SELECT *
FROM online_retail_staging
WHERE UnitPrice = 38970.00;

SELECT Country, COUNT(*) AS transactions
FROM online_retail_staging
GROUP BY Country
ORDER BY transactions DESC;

SELECT InvoiceNo, StockCode, COUNT(*) AS records
FROM online_retail_staging
GROUP BY InvoiceNo, StockCode
HAVING COUNT(*) > 1
LIMIT 20;

CREATE TABLE online_retail_cleaned AS
SELECT *
FROM online_retail_staging
WHERE InvoiceNo NOT LIKE 'C%'
  AND UnitPrice >= 0
  AND NOT (
      Description = 'Manual'
      AND UnitPrice = 38970.00
  );
  
  SELECT COUNT(*) AS cleaned_rows
FROM online_retail_cleaned;

CREATE TABLE online_retail_excluded AS
SELECT *
FROM online_retail_staging
WHERE InvoiceNo LIKE 'C%'
   OR UnitPrice < 0
   OR (
       Description = 'Manual'
       AND UnitPrice = 38970.00
   );
   
SELECT COUNT(*) AS excluded_rows
FROM online_retail_excluded;

SELECT
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS Revenue
FROM online_retail_cleaned;


SELECT
    SUM(Quantity * UnitPrice) AS TotalRevenue
FROM online_retail_cleaned;

SELECT
    COUNT(*) AS negative_quantity_rows,
    SUM(Quantity) AS negative_quantity
FROM online_retail_cleaned
WHERE Quantity < 0;

CREATE TABLE data_quality_findings (
    issue VARCHAR(100),
    column_name VARCHAR(100),
    issue_count INT,
    observation VARCHAR(500),
    action_taken VARCHAR(500)
);

INSERT INTO data_quality_findings
(issue, column_name, issue_count, observation, action_taken)
VALUES
('Missing values', 'Description', 1454, 'Description is missing', 'Kept in staging'),
('Missing values', 'CustomerID', 135080, 'Customer ID is missing', 'Kept in staging'),
('Cancellations', 'InvoiceNo', 9288, 'InvoiceNo starts with C', 'Excluded from cleaned table'),
('Negative quantity', 'Quantity', 10624, 'Negative quantities exist', 'Kept unless excluded by cancellation rule'),
('Zero price', 'UnitPrice', 2519, 'Unit price is zero', 'Kept for further investigation'),
('Zero quantity', 'Quantity', 2519, 'Quantity is zero', 'Kept for further investigation'),
('Negative price', 'UnitPrice', 2, 'Negative unit prices found', 'Excluded from cleaned table'),
('Negative quantity not cancelled', 'Quantity', 1336, 'Negative quantities without C invoice number', 'Kept for return analysis'),
('Duplicate combinations', 'All columns', 140305, 'Rows are not unique combinations', 'Not automatically removed'),
('Missing dates', 'InvoiceDate', 0, 'No missing invoice dates', 'No action required'),
('Missing InvoiceNo', 'InvoiceNo', 0, 'No missing invoice numbers', 'No action required'),
('Missing StockCode', 'StockCode', 0, 'No missing stock codes', 'No action required'),
('Missing Quantity', 'Quantity', 0, 'No missing quantities', 'No action required'),
('Missing UnitPrice', 'UnitPrice', 0, 'No missing unit prices', 'No action required'),
('Missing Country', 'Country', 0, 'No missing countries', 'No action required');

SELECT *
FROM data_quality_findings;