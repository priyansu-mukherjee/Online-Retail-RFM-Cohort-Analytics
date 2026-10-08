# 🚀 Online Retail II — E-Commerce RFM & Cohort Analytics

> **Transforming 500k+ raw, uncleaned retail transactions into actionable customer retention strategies and revenue risk insights using SQL, Power BI, and Generative AI.**

---

## ⚡ Executive Summary & Key Results

Instead of just presenting sales numbers, this end-to-end analytics project digs into **customer retention decay** and **churn vulnerability**:

* **$1.59M Revenue At-Risk Identified:** Mapped unengaged customer segments to highlight immediate retention targets.
* **500k+ Raw Records Processed:** Built a robust SQL data engineering pipeline to clean return anomalies, filter nulls, and engineer custom RFM features.
* **GenAI-Accelerated Workflow:** Leveraged LLM prompt engineering to optimize complex DAX logic and automate executive summary generation.

---

## 📸 Dashboard Previews

### 1. Executive Overview
![executive overview](images/page1.png)

### 2. Cohort Retention Matrix
![cohort retention](images/page2.png)

### 3. RFM Customer Segmentation
![RFM segmentation](images/page3.png)

---
### 1. SQL Data Engineering (`sql/`)
* Wrote complex CTEs and window functions (`NTILE`, `ROW_NUMBER`) to calculate Recency, Frequency, and Monetary (RFM) values at the customer grain.
* Cleaned dataset anomalies including negative quantities, cancellation transactions, and missing customer identifiers.

### 2. Power BI & DAX Modeling (`pbix/`)
* **Cohort Retention Matrix:** Built dynamic date logic to track month-over-month customer churn across acquisition cohorts.
* **RFM Segmentation:** Grouped customer bases into actionable tiers (*Champions*, *Loyal*, *At Risk*, *Lost*) using dynamic DAX measures.
* **UI/UX Polish:** Designed a custom Navy & Slate theme (`#0F172A`, `#1E293B`) with semantic RFM segment coloring and cross-page button navigation.

### 3. GenAI Integration
* Applied prompt engineering to rapidly debug DAX measures, streamline SQL query runtime, and generate automated narrative summaries for stakeholders.

---

## 💡 Business Impact & Strategic Recommendations
* **Focus Retention Efforts on "At Risk":** Target the 600+ at-risk customers responsible for $1.59M in past revenue with win-back email campaigns.
* **Reward "Champions":** Protect the top customer tier ($3.94M revenue contribution) through VIP loyalty programs.

## 🛠️ End-to-End Technical Architecture
