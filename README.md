# 📊 Supply Chain & Fulfillment Analytics SQL Project

## 👋 About

**KR/EN bilingual Supply Chain & Inventory Operations professional with practical SQL skills demonstrated through production-style operational KPI development projects.**

This project builds **production-style operational KPIs** to monitor fulfillment performance, delivery reliability, order failures, revenue trends, and inventory performance.

Built using the public **Olist e-commerce dataset**, simulating real-world order, payment, inventory, and fulfillment workflows.

---

## 🚀 Key Capabilities

- Built **14 production-grade SQL KPIs** covering fulfillment, delivery, revenue, and retention
- Designed **operational fulfillment metrics** including Fulfillment Rate and Order Failure Rate (stockout proxy)
- Implemented **cohort-based retention analysis (30/60/90 day windows)**
- Applied **revenue allocation logic** to ensure financial accuracy across categories
- Structured using **production-style layered architecture (INT → KPI → MART)**
- Ensured metric consistency using **single source of truth (SSOT) definitions**
- Designed for **real-world supply chain, fulfillment, and operational analytics use cases**

---

## 📦 Supply Chain & Fulfillment Highlights

Core operational KPIs:

- **Fulfillment Rate** — % of finalized orders successfully fulfilled  
- **Order Failure Rate** — proxy metric for fulfillment or stockout issues  
- **Delivery On-time Rate** — % of orders delivered within estimated delivery date  
- **Average Delivery Days** — fulfillment cycle time  

These KPIs help identify fulfillment risks, delivery delays, and operational performance bottlenecks.

---

## 📁 Project Structure

```bash
sql/
├── int/     # intermediate tables (cleaned and standardized)
├── kpi/     # production KPI queries
├── mart/    # dashboard-ready tables
└── tests/   # validation and integrity checks
```
---

## 🧾 KPI Index

### 📦 Supply Chain & Fulfillment Performance

**KPI #05 — Delivery On-time Rate**  
File: `kpi_05_delivery_on_time_rate.sql`  
Output: `on_time_rate_pct`

**KPI #06 — Average Delivery Days**  
File: `kpi_06_average_delivery_days.sql`  
Output: `avg_delivery_days`

**KPI #13 — Fulfillment Rate**  
File: `kpi_13_fulfillment_rate.sql`  
Output:  
`order_date, fulfilled_orders, finalized_orders, fulfillment_rate_pct`

**KPI #14 — Order Failure Rate (Stockout Proxy)**  
File: `kpi_14_shortage_rate.sql`  
Output:  
`order_date, shortage_orders, finalized_orders, shortage_rate_pct`

---

### 📈 Volume & Revenue

**KPI #01 — Daily Order Count**  
File: `kpi01_daily_order_count.sql`  
Output: `order_date, daily_orders`

**KPI #02 — Daily Revenue**  
File: `kpi02_daily_revenue.sql`  
Output: `order_date, daily_revenue`

**KPI #03 — Weekly Revenue Trend (WoW%)**  
File: `kpi03_weekly_revenue_trend.sql`  
Output:  
`week_start_date, revenue, wow_pct`

---

### 📊 Product & Order Analysis

**KPI #07 — Category Revenue Top 10**  
File: `kpi_07_category_revenue_top10_allocated.sql`  
Output:  
`category, category_revenue`

**KPI #08 — Units Sold by Product**  
File: `kpi_08_units_sold_by_product_ranked.sql`  
Output:  
`product_id, units_sold`

---

### 📊 Supporting KPIs

**KPI #04 — Payment Type Mix**  
File: `kpi04_payment_type_mix.sql`

**KPI #09 — Order Mix by Price Bucket**  
File: `kpi_09_order_mix_by_price_bucket.sql`

**KPI #10 — Revenue Mix by Price Bucket**  
File: `kpi_10_revenue_mix_by_price_bucket.sql`

**KPI #11 — AOV by Price Bucket**  
File: `kpi_11_aov_by_price_bucket.sql`

---

### 🔁 Customer Retention

**KPI #12 — Repeat Purchase Retention (30/60/90D)**  
File: `kpi_12_repeat_purchase_retention_30_60_90d.sql`  
Output:  
`window_days, cohort_customers, retained_customers, retention_pct`

---

## 📝 Notes

- All KPIs use **consistent SQL logic and metric definitions**
- Revenue is based on **recorded payments (SSOT definition)**
- Queries follow **production-style SQL structure**
- Designed for **fulfillment, delivery, and operational performance analysis**

---

## 📩 Contact

📧 **Email:** sarahj0514@gmail.com
💻 **GitHub:** https://github.com/sarah-analytics/Olist_Ecommerce
