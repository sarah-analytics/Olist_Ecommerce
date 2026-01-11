/* =========================================================
   KPI #03 — Weekly Revenue Trend

   Type         : Derived
   Grain        : 1 row per week_start_date (Monday-based)
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : orders joined with order_payments (no additional filtering)

   Output       : week_start_date, week_end_date, revenue, wow_pct
   Notes        : Week-over-week revenue trend
   ========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),

base_payments AS (
    SELECT
        -- Monday-based week start (DATE)
        DATE_SUB(
            DATE(o.order_purchase_timestamp),
            INTERVAL WEEKDAY(o.order_purchase_timestamp) DAY
        ) AS week_start_date,

        -- Payment amount (can be multiple rows per order_id; SUM is intended)
        p.payment_value
    FROM orders AS o
    JOIN order_payments AS p
      ON p.order_id = o.order_id
    JOIN params AS x
      ON o.order_purchase_timestamp >= x.start_ts
     AND o.order_purchase_timestamp <  x.end_ts
),

weekly_rev AS (
    SELECT
        week_start_date,
        SUM(payment_value) AS revenue
    FROM base_payments
    GROUP BY week_start_date
),

final AS (
    SELECT
        week_start_date,
        revenue,

        -- Previous week's revenue for WoW calculation
        LAG(revenue) OVER (ORDER BY week_start_date) AS prev_week_revenue
    FROM weekly_rev
)

SELECT
    week_start_date,
    DATE_ADD(week_start_date, INTERVAL 6 DAY) AS week_end_date,
    revenue,
   
    -- WoW % change (Absolute Ratio Law)
    ROUND(
        (revenue - prev_week_revenue)
        / NULLIF(prev_week_revenue, 0) * 100.0,
        2
    ) AS wow_pct
FROM final
ORDER BY week_start_date;
