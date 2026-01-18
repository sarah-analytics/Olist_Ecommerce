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
weekly_revenue AS (
    SELECT
        DATE_SUB(
            DATE(o.order_purchase_timestamp),
            INTERVAL WEEKDAY(o.order_purchase_timestamp) DAY
        ) AS week_start_date,                 -- Monday-based week start (YYYY-MM-DD)
        SUM(p.payment_value) AS revenue       -- weekly total revenue
    FROM orders AS o
    JOIN order_payments AS p
      ON o.order_id = p.order_id              -- payments define revenue
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
    GROUP BY
        DATE_SUB(
            DATE(o.order_purchase_timestamp),
            INTERVAL WEEKDAY(o.order_purchase_timestamp) DAY
        )
)

SELECT
    w.week_start_date,
    w.revenue,
    (w.revenue - LAG(w.revenue) OVER (ORDER BY w.week_start_date))
        / NULLIF(LAG(w.revenue) OVER (ORDER BY w.week_start_date), 0) * 100.0
        AS wow_pct
FROM weekly_revenue AS w
ORDER BY
    w.week_start_date;
