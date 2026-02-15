# 📊 Olist E-commerce Analytics Project

👋 About

KR/EN bilingual data analyst with strengths in clean, production-style SQL,
marketplace analytics, and concise, insight-driven dashboards.

This repository serves as an analytics portfolio project demonstrating how
e-commerce KPIs are designed, standardized, and implemented using MySQL.
The focus is on clear metric definitions, consistent logic, and
analysis-ready outputs for BI and stakeholder reporting.

---

## 📦 Olist E-commerce KPI Pack (MySQL)

This folder contains a production-style KPI SQL pack built on the
Olist Brazilian e-commerce dataset.
All queries are written for MySQL and designed to be reusable,
consistent, and portfolio-ready.

---

## 🗂 Dataset & Schema

Shortened table names are used throughout the project for readability:

- `orders`
- `order_items`
- `order_payments`
- `products`
- `int_customer_first_purchase`
- `int_valid_orders_tbl`

---

## 📁 Project Structure

All SQL files are organized under the `sql/` directory using a layered, production-style approach:

- **`sql/int/`** : canonical intermediate tables shared across KPIs  
- **`sql/kpi/`** : business KPI queries  
- **`sql/mart/`** : consumption-ready summary tables for dashboards  
- **`sql/tests/`** : data quality checks and validation queries  
- **`sql/ddl/`** : physical schema definitions (indexes, constraints)  
  - **`sql/ddl/indexes/`** : performance indexes for common access patterns (e.g. retention, time-range lookups)

---

## 🧭 KPI Design Principles

- Time filters follow the pattern `>= start_ts` and `< end_ts`
  to avoid overlapping date ranges.
- All rate-based KPIs use the formula  
  `rate = target / NULLIF(base, 0) * 100.0`
  to ensure numerical stability.
- Each KPI explicitly defines its grain (day, week, bucket, product, customer),
  and the grain is fixed early in the query to prevent duplication from joins.

---

## 🧾 KPI Index

### 📈 Volume & Revenue (Baseline)

1. **KPI #01 — Daily Order Count**  
   File: `kpi01_daily_order_count.sql`  
   Output: `order_date, daily_orders`  
   Tracks the number of distinct orders placed per day.

2. **KPI #02 — Daily Revenue**  
   File: `kpi02_daily_revenue.sql`  
   Output: `order_date, daily_revenue`  
   Revenue is defined using **recorded payments** from `order_payments`.

3. **KPI #03 — Weekly Revenue Trend (WoW%)**  
   File: `kpi03_weekly_revenue_trend.sql`  
   Output: `week_start_date, revenue, wow_pct`  
   Weekly revenue trend using Monday-based weeks with week-over-week change.

---

### 💳 Payment & Mix

4. **KPI #04 — Payment Type Mix**  
   File: `kpi04_payment_type_mix.sql`  
   Output: `payment_type, revenue, revenue_pct`  
   Analyzes revenue composition by payment method.

---

### 🚚 Logistics & Delivery Performance

5. **KPI #05 — Delivery On-time Rate**  
   File: `kpi_05_delivery_on_time_rate.sql`  
   Output: `on_time_rate_pct`  
   Measures delivery reliability using delivered orders only.

6. **KPI #06 — Average Delivery Days**  
   File: `kpi_06_average_delivery_days.sql`  
   Output: `avg_delivery_days`  
   Diagnostic KPI measuring average time from purchase to delivery.

---

### 🛍 Merchandising (Category & Product)

7. **KPI #07 — Category Revenue Top 10 (Allocated)**  
   File: `kpi_07_category_revenue_top10_allocated.sql`  
   Output: `category, category_revenue`
   Revenue per category is computed using order-level revenue allocation.
   Total order payments are proportionally distributed to categories based on their item-value share     within each order, ensuring a consistent revenue definition (SSOT) across all revenue KPIs.
   Validation:
   `SUM(allocated_category_revenue) = SUM(order_revenue)`

8. **KPI #08 — Units Sold by Product (Ranked)**  
   File: `kpi_08_units_sold_by_product_ranked.sql`  
   Output: `product_id, units_sold`  
   Volume-based KPI listing all products with their units sold in the selected period, sorted by         sales volume, independent of revenue or price effects.
   
---

### 🧮 Price Bucket Analysis (Set KPIs: #09–#11)

These KPIs share the **same price bucket definition** and are designed
to be interpreted together:

- #09 shows where orders concentrate
- #10 shows where revenue concentrates
- #11 shows efficiency (AOV) within each segment

9. **KPI #09 — Order Mix by Price Bucket**  
   File: `kpi_09_order_mix_by_price_bucket.sql`  
   Output: `price_bucket, order_pct`

10. **KPI #10 — Revenue Mix by Price Bucket**  
    File: `kpi_10_revenue_mix_by_price_bucket.sql`  
    Output: `price_bucket, revenue_pct`

11. **KPI #11 — AOV by Price Bucket**  
    File: `kpi_11_aov_by_price_bucket.sql`  
    Output: `price_bucket, aov`

---

### 🔁 Customer Retention

12. **KPI #12 — Repeat Purchase Retention (30/60/90D)**  
    File: `kpi_12_repeat_purchase_retention_30_60_90d.sql`  
    Output: `window_days, cohort_customers, retained_customers, retention_pct`

Retention is calculated using a cohort defined by first delivered purchase, with repeat detection based on the second order timestamp.

- Denominator: customers whose first delivered purchase falls within the cohort window and have sufficient observation period
- Numerator: customers whose second delivered purchase occurs within the specified window after first_order_ts  

---

## 📝 Notes for Reviewers

- KPI definitions are consistent across time, revenue, and mix analyses.
- Revenue is always anchored to recorded payments.
- Price bucket KPIs are intentionally separated but designed as a single analytical set.
- Retention is consolidated into one query to avoid duplicated logic.

---

## 📩 Contact

📧 **Email:** sarahj0514@gmail.com  
🔗 **LinkedIn:** https://www.linkedin.com/in/your-linkedin  
💻 **GitHub:** https://github.com/your-username
