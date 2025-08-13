-- 1. View first 10 rows 
SELECT * FROM consumer_complaints.`p9-consumercomplaints`
LIMIT 10;

-- 2.Retrieve all complaints related to "Debt collection" product. 
SELECT Issue FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE `Product Name` = 'Debt Collection';

-- 3.  Count total complaints per product
SELECT `Product Name`, COUNT(*) AS No_of_Complaints FROM `consumer_complaints`.`p9-consumercomplaints`
GROUP BY `Product Name`;

-- 4. Find complaints submitted via "Web" in 2015.
SELECT Issue FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE `Submitted via`='Web' AND YEAR(`Date Received`)=2015

-- 5. List all unique product names
SELECT DISTINCT(`Product Name`) FROM `consumer_complaints`.`p9-consumercomplaints`;

-- 6. Find earliest and latest complaint date.
SELECT MIN(`Date Received`), MAX(`Date Received`) FROM `consumer_complaints`.`p9-consumercomplaints`;

-- 7.  Get all complaints from a specific state (e.g., 'California').
SELECT Issue FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE `State Name`='CA';

-- 8.List all complaints where "Consumer Disputed" = 'Yes'. 
SELECT Issue FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE `Consumer Disputed`='Yes';

-- 9. Find complaints with missing consumer narratives
SELECT *
FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE `Consumer Complaint Narrative` IS NULL
   OR TRIM(`Consumer Complaint Narrative`) = '';

-- 10. Count complaints per state sorted by most complaints.
SELECT `State Name`, COUNT(*) AS No_of_Complaints FROM `consumer_complaints`.`p9-consumercomplaints`
GROUP BY `State Name`
ORDER BY No_of_Complaints DESC;

-- 11. List top 5 companies with the most complaints.
SELECT Company, COUNT(Issue) AS Most_Complaints FROM `consumer_complaints`.`p9-consumercomplaints`
GROUP BY Company, Issue
ORDER BY COUNT(Issue) DESC
LIMIT 5;

-- 12. Monthly trend of complaints for a given year. 
SELECT 
    DATE_FORMAT(`Date Received`, '%b') AS Month_Name,
    COUNT(*) AS Complaint_Count
FROM `consumer_complaints`.`p9-consumercomplaints`
WHERE YEAR(`Date Received`) = 2014
GROUP BY Month_Name, MONTH(`Date Received`)
ORDER BY MONTH(`Date Received`);

-- 13. Complaints per submission channel (phone, email, etc.)
SELECT `Submitted via` AS `Submission Channel`, COUNT(Issue) AS Complaints FROM `consumer_complaints`.`p9-consumercomplaints` 
GROUP BY `Submission Channel`;

-- 14. Search narratives containing specific keywords (e.g., "fraud", "billing error"). 
SELECT Issue AS `Narratives` FROM `consumer_complaints`.`p9-consumercomplaints` 
WHERE Issue LIKE '%fraud%' OR '%Transaction issue%';

-- 15. Count narratives mentioning “scam” per year. 
SELECT COUNT(Issue) AS `No. of Scams per year`, YEAR(`Date Received`) AS Years FROM `consumer_complaints`.`p9-consumercomplaints` 
WHERE Issue LIKE '%scam%' 
GROUP BY Years

-- 16. Group by Sub-Product and show average complaint count per company.
SELECT 
    `Sub Product`,
    COUNT(DISTINCT Company) AS Distinct_Companies,
    AVG(complaint_count) AS Avg_Complaints_Per_Company
FROM (
    SELECT 
        `Sub Product`,
        `Company`,
        COUNT(*) AS complaint_count
    FROM `consumer_complaints`.`p9-consumercomplaints`
    GROUP BY `Sub Product`, `Company`
) sub
GROUP BY `Sub Product`
ORDER BY Avg_Complaints_Per_Company DESC;

-- 17. Replace null sub-issue values with 'Not Provided'. 
UPDATE `consumer_complaints`.`p9-consumercomplaints` 
SET `Sub Issue`='Not Provided' 
WHERE `Sub Issue` IS NULL OR TRIM(`Sub Issue`) = '';

-- 18. Average time between Date Received and Date Sent to Company.
SELECT AVG(DATEDIFF(`Date Sent to Company`, `Date Received`)) AS Average_Time FROM `consumer_complaints`.`p9-consumercomplaints`;

-- 19.  Rank companies by total complaints per product
SELECT 
    Company,
    `Product Name`,
    complaint_count,
    DENSE_RANK() OVER(
        PARTITION BY `Product Name` 
        ORDER BY complaint_count DESC
    ) AS Rank_in_Product
FROM (
    SELECT 
        Company,
        `Product Name`,
        COUNT(*) AS complaint_count
    FROM `consumer_complaints`.`p9-consumercomplaints`
    GROUP BY Company, `Product Name`
) AS counts
ORDER BY `Product Name`, Rank_in_Product;

-- 20. Percentage of timely responses by company.
SELECT
	Company,
    (SUM(CASE WHEN `Timely Response` = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(`Timely Response`) AS `Response Time Percentage`
FROM `consumer_complaints`.`p9-consumercomplaints`
GROUP BY Company;

-- 21. Top sub-issue for each product
WITH Counts AS (
	SELECT 
		`Product Name`,
		`Sub Issue`,
		COUNT(*) AS No_of_SubIssues
    FROM `consumer_complaints`.`p9-consumercomplaints`
    GROUP BY `Product Name`, `Sub Issue`
)
SELECT 
	`Product Name`,
    `Sub Issue`,
	No_of_SubIssues,
    ROW_NUMBER() OVER(PARTITION BY `Product Name` ORDER BY No_of_SubIssues DESC) Ranks
FROM Counts
ORDER BY `Product Name`, Ranks;

-- NORMALIZATION OF DATA FROM UNORGANIZED TO 3NF FORM (Note that we will perform these operations for only a few records)
-- 1. Remove Repeated Groups (1NF) : Ensure each column contains atomic values (no lists, no comma-separated items) and no repeating columns.
-- Make sure Tags (if multiple tags are stored in one cell) are split into a separate table:
-- Table: Complaint_Tags → Complaint_ID, Tag
USE consumer_complaints
CREATE TABLE Complaint_Tags (
	Complaint_ID INT PRIMARY KEY,
    Tag VARCHAR(50) DEFAULT NULL
    )
INSERT INTO Complaint_Tags (Complaint_ID, Tag)
VALUES
    (468882, NULL),
    (468889, 'Older American'),
    (468904, 'Older American'),
    (469252, 'Servicemember'),
    (475777, 'Servicemember'),
    (469525, 'Older American');

-- 2. Remove Partial Dependencies (2NF) : No attribute should depend only on part of a composite primary key. 
-- Here: 
-- Products Table: Product_ID, Product_Name
-- Sub_Products Table: SubProduct_ID, SubProduct_Name, Product_ID
-- Issues Table: Issue_ID, Issue_Name
-- Sub_Issues Table: SubIssue_ID, SubIssue_Name, Issue_ID

CREATE TABLE Products (
	Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50) 
    )

CREATE TABLE Sub_Products (
	SubProduct_ID INT,
    SubProduct_Name VARCHAR(50) ,
    Product_ID INT,
    PRIMARY KEY(SubProduct_ID),
    FOREIGN KEY(Product_ID) REFERENCES Products(Product_ID)
    )
    
CREATE TABLE Issues (
	Issue_ID INT,
    Issue_Name VARCHAR(50),
    PRIMARY KEY(Issue_ID)
    )

CREATE TABLE Sub_Issues (
	SubIssue_ID INT,
    SubIssue_Name VARCHAR(50),
    Issue_ID INT,
    PRIMARY KEY(SubIssue_ID),
    FOREIGN KEY(Issue_ID) REFERENCES Issues(Issue_ID)
    )
    
-- 3. Remove Transitive Dependencies (3NF) : Non-key attributes should not depend on other non-key attributes.
-- State Name and Zip Code → put into a Location Table: Location_ID, State_Name, Zip_Code
-- Company Public Response could be tied to Company_ID in a Companies Table: Company_ID, Company_Name, Public_Response
-- Submitted via → put into a Channels Table: Channel_ID, Channel_Name

CREATE TABLE Location (
	Location_ID INT PRIMARY KEY,
	State_Name VARCHAR(50),
    Zip_Code INT
    )
    
CREATE TABLE Companies (
	Company_ID INT PRIMARY KEY,
	Company_Name VARCHAR(50),
    Public_Response VARCHAR(100)
    )
    
CREATE TABLE Channels (
	Channel_ID INT PRIMARY KEY,
	Channel_Name VARCHAR(50)
    )
    





    



    






    

    
    



	
    


















 




