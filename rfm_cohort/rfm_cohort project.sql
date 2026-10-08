/*
===============================================================================
PROJECT: E-Commerce Cohort Retention & Customer RFM Segmentation
DATASET: Online Retail II (412k+ Valid Transactions | 4,338 Unique Buyers)
AUTHOR: Data Analyst Portfolio Project

BUSINESS PROBLEM:
"Acquiring new customers costs 5x more than keeping existing ones, yet most 
businesses have no idea which customers are driving profits and which are 
silently slipping away."

This project solves three critical questions for business leaders:
1. LEAKY BUCKET: How many new buyers actually come back after their first month?
2. REVENUE RISK: How much revenue is locked inside churn-risk customers?
3. VIP CONCENTRATION: Who are our top 10% buyers, and how much revenue do they protect?

KEY STEPS IN THIS SCRIPT:
- Step 1A: Clean raw sales logs and establish a 1-year baseline (v_clean_retail_2011).
- Step 1B: Track monthly customer retention using Cohort Analysis math.
- Step 1C: Segment buyers into Champions, Loyal, At-Risk, and Lost tiers using RFM.
===============================================================================

*/create database RFM_Cohort_Project;
use RFM_Cohort_Project;

CREATE TABLE online_retail_II (
    Invoice VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    Price DECIMAL(10,2),
    `Customer ID` VARCHAR(50),
    Country VARCHAR(50)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_II.csv'
INTO TABLE online_retail_II
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) FROM online_retail_II;









-- ============================================================================
-- STEP 1A: DATA CLEANING & BASE VIEW CREATION
-- Dataset: Online Retail II (Filtered for 2010-12-01 to 2011-12-09)
-- Purpose: Remove invalid transactions, handle data types, and establish 1-year baseline.
-- ============================================================================

CREATE OR REPLACE VIEW v_clean_retail_2011 AS
SELECT 
-- Cast Customer ID to integer to fix text import formatting
CAST(`Customer ID` AS UNSIGNED) AS customer_id,
Invoice AS invoice,
InvoiceDate AS invoice_date,
Quantity AS quantity,
Price AS price,
-- Compute total transaction value
(Quantity * Price) AS total_amount,
-- Truncate transaction date to the 1st of the month for cohort grouping
DATE_FORMAT(InvoiceDate, '%Y-%m-01') AS invoice_month
FROM online_retail_II
WHERE `Customer ID` IS NOT NULL 
AND `Customer ID` != ''              -- Remove blank customer IDs
AND Invoice NOT LIKE 'C%'             -- Exclude order cancellations/returns
AND Quantity > 0                      -- Keep valid purchase quantities
AND Price > 0                         -- Exclude zero-price adjusted rows
AND InvoiceDate >= '2010-12-01'       -- Analysis Start Date
AND InvoiceDate <= '2011-12-09 23:59:59'; -- Analysis End Date










-- ============================================================================
-- STEP 1B: COHORT RETENTION ANALYSIS QUERY
-- Purpose: Identify first-time purchase month per customer and compute month-indexed retention.
-- ============================================================================

WITH customer_first_purchase AS (
-- Step A: Find the initial join/acquisition month for every customer
SELECT 
customer_id,
MIN(invoice_month) AS cohort_month
FROM v_clean_retail_2011
GROUP BY customer_id
),

cohort_transactions AS (
-- Step B: Join transactions to cohort month and calculate monthly index offset
SELECT DISTINCT
c.customer_id,
cc.cohort_month,
c.invoice_month,
-- Calculate month offset (0 = Month of Join, 1 = Month 1, etc.)
PERIOD_DIFF(
DATE_FORMAT(c.invoice_month, '%Y%m'), 
DATE_FORMAT(cc.cohort_month, '%Y%m')
) AS cohort_index
FROM v_clean_retail_2011 c
JOIN customer_first_purchase cc ON c.customer_id = cc.customer_id
)

-- Step C: Aggregate unique active customer count per cohort month and month index
SELECT 
cohort_month,
cohort_index,
COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_transactions
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;









-- ============================================================================
-- STEP 1C: RFM (RECENCY, FREQUENCY, MONETARY) SEGMENTATION QUERY
-- Reference Date: 2011-12-10 (Day after final transaction)
-- ============================================================================

WITH rfm_raw AS (
-- Step A: Calculate raw Recency, Frequency, and Monetary metrics per customer
SELECT 
customer_id,
-- Recency: Days since last order relative to dataset end date
DATEDIFF('2011-12-10', MAX(invoice_date)) AS recency,
-- Frequency: Total distinct order invoices placed
COUNT(DISTINCT invoice) AS frequency,
-- Monetary Value: Total net spend across all purchases
ROUND(SUM(total_amount), 2) AS monetary
FROM v_clean_retail_2011
GROUP BY customer_id
),

rfm_scores AS (
-- Step B: Assign quartile scores (1 to 4) using NTILE window functions
SELECT 
customer_id,
recency,
frequency,
monetary,
-- Recency: Fewer days elapsed = higher score (4 is most recent)
NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
-- Frequency & Monetary: Higher value = higher score (4 is highest volume/spend)
NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_raw
),

rfm_segmented AS (
-- Step C: Combine scores into RFM cells and map to strategic business segments
SELECT 
customer_id,
recency,
frequency,
monetary,
r_score,
f_score,
m_score,
CONCAT(r_score, f_score, m_score) AS rfm_cell,
CASE 
WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
WHEN r_score >= 3 AND f_score < 3 THEN 'Recent / Promising'
WHEN r_score = 2 AND f_score >= 2 THEN 'At Risk'
WHEN r_score = 1 AND f_score = 1 THEN 'Lost'
ELSE 'Needs Attention'
END AS rfm_segment
        
FROM rfm_scores
)

-- Step D: Final output table detailing overall customer counts and spend contribution by segment
SELECT 
rfm_segment,
COUNT(customer_id) AS total_customers,
ROUND(SUM(monetary), 2) AS total_revenue,
ROUND(AVG(monetary), 2) AS avg_spend_per_customer,
ROUND(AVG(recency), 0) AS avg_recency_days
FROM rfm_segmented
GROUP BY rfm_segment
ORDER BY total_revenue DESC;






/*
===============================================================================
PROJECT SUMMARY & KEY FINDINGS:
-------------------------------------------------------------------------------
1. CLEAN DATASET STATS:
- Total Clean Transactions: 412,389 valid rows
- Unique Active Customers:  4,338 distinct buyers
- Total Net Revenue:        $9,223,303.90

2. COHORT RETENTION INSIGHTS:
- Initial Retention: Dec 2010 cohort started strong with a 36.6% Month-1 retention rate.
- Holiday Peak: Retention spiked to 50.3% in Month 11 (Nov 2011) due to holiday shopping.

3. RFM SEGMENTATION BREAKDOWN:
- Champions (Top 11.5% of buyers): Generated $4.64M (50.3% of total company sales).
- At Risk & Needs Attention: 1,631 buyers ($1.78M historical revenue) haven't purchased in ~100 days.
- Lost Customers: 539 buyers ($111K spend) are fully churned (260+ days inactive).
===============================================================================
*/