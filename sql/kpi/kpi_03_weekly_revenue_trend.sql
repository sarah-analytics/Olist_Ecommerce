/* =========================================================
   KPI #03 — Weekly Revenue Trend

   Type         : Base
   Description  : Analyze revenue movement over time on a weekly basis
   Numerator    : Weekly total revenue
   Denominator  : Not applicable (trend KPI)
   Grain        : 1 row per week
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders with recorded payments
   Output       : week_start_date, revenue, wow_pct
   Notes        : WoW % is a derived reference metric for trend interpretation
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),

/* ---------------------------------------------------------
   weekly_revenue
   - Grain : 1 row per week (Monday-based)
   - Revenue is defined by payment records
--------------------------------------------------------- */
weekly_revenue AS (
    SELECT
        DATE_SUB(
            DATE(o.order_purchase_timestamp),
            INTERVAL WEEKDAY(o.order_purchase_timestamp) DAY
        ) AS week_start_date,                 -- Monday-based week start
        SUM(p.payment_value) AS revenue       -- weekly total revenue
    FROM orders AS o
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
    JOIN order_payments AS p
      ON o.order_id = p.order_id              -- 1 order : N payments (summed)
    GROUP BY
        week_start_date
),

/* ---------------------------------------------------------
   weekly_with_prev
   - Attach previous week's revenue for WoW calculation
--------------------------------------------------------- */
weekly_with_prev AS (
    SELECT
        week_start_date,
        revenue,
        LAG(revenue) OVER (ORDER BY week_start_date ASC) AS prev_revenue
    FROM weekly_revenue
)
SELECT
    week_start_date,
    revenue,
    (revenue - prev_revenue)
        / NULLIF(prev_revenue, 0) * 100.0     AS wow_pct
FROM weekly_with_prev
ORDER BY
    week_start_date;
