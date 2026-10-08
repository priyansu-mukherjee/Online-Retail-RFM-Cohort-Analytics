# 🚀 Online Retail II — E-Commerce RFM & Cohort Analytics

> **Transforming 500k+ raw retail transactions into actionable customer retention strategies and revenue risk insights using SQL, Power BI, and Generative AI.**

---

## ⚡ Executive Summary

* **$1.59M At-Risk Revenue Identified:** Mapped unengaged customer segments to highlight immediate retention targets.
* **500k+ Records Processed:** Built a robust SQL pipeline to clean return anomalies and compute baseline RFM metrics.
* **GenAI-Accelerated Workflow:** Leveraged LLM prompt engineering to optimize complex DAX logic and generate executive summaries.

---

## 📊 Dashboard Previews

### 1. Executive Overview
![Executive Overview](executive_overview.png)

### 2. Cohort Retention Matrix
![Cohort Retention Matrix](cohort_retention.png)

### 3. RFM Customer Segmentation
![RFM Customer Segmentation](rfm_segmentation.png)

---

## ⚙️ Technical Highlights

* **SQL Data Engineering (`rfm_cohort project.sql`):** Wrote CTEs and window functions (`NTILE`, `ROW_NUMBER`) to clean transactions, handle returns, and compute RFM scores.
* **Power BI & DAX (`rfm_cohort_project.pbix`):** Modeled dynamic cohort retention matrices and RFM customer tiers (*Champions*, *Loyal*, *At Risk*, *Lost*).
* **GenAI Optimization:** Applied prompt engineering to debug DAX calculations and synthesize automated churn risk summaries.
