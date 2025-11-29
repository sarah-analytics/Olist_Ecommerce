/* KPI #05 — Weekly Revenue + Monthly Percentage
   Purpose: weekly revenue & % share within each month */

WITH base AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,  -- YYYY-MM
        WEEK(o.order_purchase_timestamp, 1)
          - WEEK(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'), 1)
          + 1 AS week,                                             -- week number in month
        p.payment_value
    FROM orders AS o
    JOIN order_payments AS p
          ON o.order_id = p.order_id
),
weekly_rev AS (
    SELECT
        month,
        week,
        ROUND(SUM(payment_value), 2) AS revenue                     -- weekly revenue
    FROM base
    GROUP BY month, week
)
SELECT
    month,
    week,
    revenue,
    ROUND(
        revenue * 100.0 
        / SUM(revenue) OVER (PARTITION BY month),                  -- % of monthly total
        2
    ) AS pct
FROM weekly_rev
ORDER BY month, week;
