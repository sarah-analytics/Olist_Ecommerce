/* =========================================================
   KPI #03 — Weekly Revenue Trend (Canonical)

   Goal      : Track weekly revenue trend over time
   Grain     : 1 row per week_start (Monday-based)
   Revenue   : SUM(order_payments.payment_value)
   Time Rule : Absolute DateTime Law  [>= start_ts, < end_ts)

   Output
     - week_start_date : Monday-based week bucket start date
     - week_end_date   : week_start_date + 6 days (display only)
     - revenue         : weekly revenue
     - wow_pct         : week-over-week % change (NULL for first week)
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

    ROUND(revenue, 2) AS revenue,

    -- WoW % change (Absolute Ratio Law)
    ROUND(
        (revenue - prev_week_revenue)
        / NULLIF(prev_week_revenue, 0) * 100.0,
        2
    ) AS wow_pct
FROM final
ORDER BY week_start_date;
