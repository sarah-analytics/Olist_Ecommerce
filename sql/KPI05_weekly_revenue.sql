/* =========================================================
   KPI #05 — Weekly Revenue & Monthly % Share

   - Week is defined by week_start (Monday-based)
   - Weekly revenue is aggregated by week_start
   - week_in_month is a display label for readability
   ========================================================= */

WITH base AS (
    SELECT
        -- YYYY-MM (monthly bucket)
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,

        -- Monday-based week start date
        DATE_SUB(
            DATE(o.order_purchase_timestamp),
            INTERVAL WEEKDAY(o.order_purchase_timestamp) DAY
        ) AS week_start,

        -- payment amount (one row per payment record)
        p.payment_value
    FROM orders o
    JOIN order_payments p
      ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-01-01'
),

weekly_rev AS (
    SELECT
        month,
        week_start,
        SUM(payment_value) AS revenue
    FROM base
    GROUP BY month, week_start
)

SELECT
    month,

    -- Week number within month (label only)
    DENSE_RANK() OVER (
        PARTITION BY month
        ORDER BY week_start
    ) AS week_in_month,

    week_start,

    -- Weekly revenue
    ROUND(revenue, 2) AS revenue,

    -- % share of weekly revenue within the month
    ROUND(
        revenue * 100.0
        / SUM(revenue) OVER (PARTITION BY month),
        2
    ) AS pct
FROM weekly_rev
ORDER BY month, week_start;
