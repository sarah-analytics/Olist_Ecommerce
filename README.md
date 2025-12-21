# Olist E-commerce Analytics Project

## 👋 About
KR/EN bilingual analyst with strengths in clean SQL,
marketplace analytics, and concise, insight-driven dashboards.

---

## 📌 Project Overview
This project analyzes Brazilian e-commerce transaction data from Olist.
The goal is to design **operationally reliable KPIs**, structure them using
a **dbt-ish SQL layering approach**, and visualize insights through Tableau.

This repository emphasizes:
- Metric definition before implementation
- Reusable SQL models
- Dashboard-aligned KPI design
- Reproducible analytics workflows

---

## 📂 Dataset
- Source: Olist Brazilian E-commerce Dataset
- Core tables:
  - orders
  - order_items
  - products
  - order_payments
  - customers
- Time range: 2017-01-01 ~ 2018-01-01

---

## 📊 KPIs (Dashboard-aligned)

The KPIs are organized to match the Tableau dashboard flow.
Each KPI is numbered based on operational priority and analytical depth.

### 1) Overview
- KPI #01 — Daily Orders  
- KPI #02 — Daily Revenue  
- KPI #03 — Weekly Revenue Trend  
- KPI #04 — Payment Type Mix  

---

### 2) Operations
- KPI #05 — Delivery On-time Rate  
- KPI #06 — Average Delivery Days  

---

### 3) Merchandising
- KPI #07 — Category Revenue Top 10  
- KPI #08 — Best-selling Products  

**Price Buckets (Derived KPIs)**
- KPI #09 — Order Mix by Price Bucket  
- KPI #10 — Revenue Mix by Price Bucket  
- KPI #11 — AOV by Price Bucket  

---

### 4) Customer
- KPI #12 — 30-Day Repeat Purchase Retention  

> The customer domain focuses on retention as the primary health metric.  
> Additional customer KPIs (e.g., frequency, LTV) are intentionally excluded  
> to avoid overfitting given the dataset time horizon.

---

## KPI Metric Contracts

> All KPIs follow the **Absolute DateTime Law**  
> Date filter rule: `>= start_date AND < end_date`

Metric Contracts define KPI logic **before SQL implementation**
and serve as the single source of truth for metric definitions.

---

### KPI #XX — [Human-readable Name]

- Description:
- Numerator:
- Denominator:
- Timestamp Basis:
- Date Filter Rule:
- Grain:
- Exclusions / Filters:
- Source Tables:
- Notes:

---

## 📈 Tableau Dashboard

The dashboard is structured to reflect the KPI hierarchy and operational flow.
Each view corresponds directly to the KPI groups defined above.

### Overview
- KPI #01 — Daily Orders  
- KPI #02 — Daily Revenue  
- KPI #03 — Weekly Revenue Trend  
- KPI #04 — Payment Type Mix  

### Operations
- KPI #05 — Delivery On-time Rate  
- KPI #06 — Average Delivery Days  

### Merchandising
- KPI #07 — Category Revenue Top 10  
- KPI #08 — Best-selling Products  
- KPI #09 — Order Mix by Price Bucket  
- KPI #10 — Revenue Mix by Price Bucket  
- KPI #11 — AOV by Price Bucket  

### Customer
- KPI #12 — 30-Day Repeat Purchase Retention  

[Tableau Public / Workbook link here]  
[Dashboard screenshots here]

---

## 🔍 Insights
Key analytical findings derived from the KPIs and dashboard.

---

## ▶️ How to Reproduce

### 1) Database Setup
- MySQL 8.x
- Import CSV files into a dedicated schema (e.g., `olist_db`)

### 2) SQL Execution Order
/sql/int   → intermediate reusable models  
/sql/mart  → final KPI queries (SELECT only)  
/sql/tests → data validation checks  

### 3) Dashboard
- Connect Tableau to mart views or tables
- Refresh using defined KPI date parameters

---

## 📩 Contact
📧 sarahj0514@gmail.com  
🔗 LinkedIn:  
🌐 Portfolio:
