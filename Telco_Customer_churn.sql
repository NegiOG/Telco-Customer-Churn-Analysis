-- Creating table to import data from CSV --

CREATE TABLE telco_customers (
    CustomerID VARCHAR(500) PRIMARY KEY,
    Gender VARCHAR(100),
    SeniorCitizen TINYINT, -- 0 = No, 1 = Yes
    Partner VARCHAR(300), -- Yes/No
    Dependents VARCHAR(300), -- Yes/No
    Tenure INT, -- Months the customer has been with the company
    PhoneService VARCHAR(30), -- Yes/No
    MultipleLines VARCHAR(100), -- Yes, No, No phone service
    InternetService VARCHAR(100), -- DSL, Fiber optic, No
    OnlineSecurity VARCHAR(150), -- Yes, No, No internet service
    OnlineBackup VARCHAR(150), -- Yes, No, No internet service
    DeviceProtection VARCHAR(150), -- Yes, No, No internet service
    TechSupport VARCHAR(150), -- Yes, No, No internet service
    StreamingTV VARCHAR(150), -- Yes, No, No internet service
    StreamingMovies VARCHAR(150), -- Yes, No, No internet service
    Contract VARCHAR(150), -- Month-to-month, One year, Two year
    PaperlessBilling VARCHAR(300), -- Yes/No
    PaymentMethod VARCHAR(300), -- Electronic check, Mailed check, Bank transfer, Credit card
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn VARCHAR(3) -- Yes/No
);

SELECT * FROM telco_customers;
-- Checking for duplicates --

SELECT COUNT(*) FROM telco_customers;
SELECT DISTINCT customerID FROM telco_customers;
-- No Duplicates --

-- Standardize categorical values to 1 if YES , 0 for NO --

UPDATE telco_customers
SET Partner = IF(Partner = 'Yes', 1, 0),
 Dependents = IF(Dependents = 'Yes', 1, 0),
 PhoneService = IF(PhoneService = 'Yes', 1, 0),
 MultipleLines = IF(MultipleLines = 'Yes', 1, 0),
 OnlineSecurity = IF(OnlineSecurity = 'Yes', 1, 0),
Onlinebackup = IF(Onlinebackup = 'Yes', 1, 0),
DeviceProtection = IF(DeviceProtection = 'Yes', 1, 0),
Techsupport = IF(Techsupport = 'Yes', 1, 0),
StreamingTV = IF(StreamingTV = 'Yes', 1, 0),
Streamingmovies = IF(Streamingmovies = 'Yes', 1, 0),
paperlessbilling = IF(paperlessbilling = 'Yes', 1, 0);

UPDATE telco_customers
SET Churn = CASE
		WHEN churn = 'Yes' THEN 1
                ELSE 0
		END;

SELECT * FROM telco_customers;

-- Creating categorical Bins on the basis of Tenure --

ALTER TABLE telco_customers
ADD COLUMN Tenure_terms VARCHAR(15);


-- Accirding to tenure Categorizing customers into Short,Mid or Long Term --
UPDATE telco_customers
SET tenure_terms = 
CASE
	WHEN Tenure <=12 THEN 'Short Term'
    WHEN Tenure BETWEEN 13 AND 24 THEN 'Mid Term'
    WHEN Tenure >24 THEN 'Long Term'
	ELSE 'Others'
END;

SELECT * FROM telco_customers;

-- Customer Retention & Churn Analysis --

ALTER TABLE telco_customers
MODIFY COLUMN Churn INT;

--  total customers, retained customers, and churned customers--

SELECT COUNT(customerID) AS total_customers
 FROM telco_customers;
 
SELECT COUNT(*) AS retained_customers
FROM telco_customers
WHERE Churn = 0
;

SELECT SUM(Churn) AS churned_customers
FROM telco_customers;

-- Customer Retention Rate --

-- Customer Retained/Customer Churned --

WITH Retained_Customers AS(SELECT COUNT(*) as retained_cus
FROM telco_customers
WHERE Churn = 0),
total_customers AS(SELECT COUNT(*) AS total_cus FROM telco_customers)

SELECT (retained_cus/total_cus) *100 AS CRR
FROM retained_customers,total_customers;

-- Churn Rates --

SELECT DISTINCT Contract FROM telco_customers;


-- total cus by contract --
SELECT Contract, COUNT(*) AS total_cus_by_contract
FROM telco_customers
GROUP BY Contract;

-- churned customers by contract --
SELECT Contract , COUNT(*) AS total_cus_by_contract
FROM telco_customers
WHERE churn = 1
GROUP BY Contract;

-- Alternate Way --
SELECT Contract , SUM(Churn) AS total_cus_by_contract
FROM telco_customers
GROUP BY Contract;

-- Churn Rate by contract --

SELECT contract,
	COUNT(*) AS total_customer,
   	SUM(churn) AS churned_customer,
    	SUM(Churn)*100/COUNT(*)  AS CRR
    
FROM telco_customers
GROUP BY contract;

-- Churn Rate By Tenure --

SELECT Tenure_terms,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) *100/ COUNT(*) ,2) AS CRR
FROM telco_customers
GROUP BY Tenure_terms;

-- Churn Prediction Insights --

-- customers by Rank --

SELECT *,
	RANK() OVER (ORDER BY TotalCharges DESC) AS ranking
 FROM telco_customers;
 
 -- Customers who are more likly to churn --
 
 SELECT 
    InternetService,
    PhoneService,
    StreamingTV,
    StreamingMovies,
    COUNT(*) AS Total_Customers,
    SUM(Churn) AS Churned_Customers,
    ROUND((SUM(Churn) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
FROM telco_customers
GROUP BY InternetService, PhoneService, StreamingTV, StreamingMovies
ORDER BY Churn_Rate_Percentage DESC;

 










