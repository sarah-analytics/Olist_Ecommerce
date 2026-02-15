/* =========================================================
   KPI #12 — Repeat Purchase Retention (30/60/90D)

   Type         : Derived
   Description  : % of customers who repeat within N days of first order
   Numerator    : Customers with second_order_ts < first_order_ts + window_days
   Denominator  : Cohort customers with observable window
   Grain        : 1 row per window_days
   Time Basis   : first_order_ts
   Date Filter  : first_order_ts ∈ [start_ts, end_ts)
   Valid Orders : Delivered orders only (int_valid_orders)
   Output       : window_days, cohort_customers, retained_customers, retention_pct

   Notes        : Uses second_order_ts for exact repeat detection
   ========================================================= */
WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
windows AS (
    SELECT 30 AS window_days
    UNION ALL SELECT 60
    UNION ALL SELECT 90
),
ordered AS (
    SELECT
        v.customer_unique_id,
        v.order_ts,
        LEAD(v.order_ts) OVER (
            PARTITION BY v.customer_unique_id
            ORDER BY v.order_ts
        ) AS next_order_ts,
        ROW_NUMBER() OVER (
            PARTITION BY v.customer_unique_id
            ORDER BY v.order_ts
        ) AS rn
    FROM int_valid_orders v
),
cohort AS (
    SELECT
        o.customer_unique_id,
        o.order_ts      AS first_order_ts,
        o.next_order_ts AS second_order_ts
    FROM ordered o
    JOIN params prm
      ON o.order_ts >= prm.start_ts
     AND o.order_ts <  prm.end_ts
    WHERE o.rn = 1
)

SELECT
    w.window_days,
    COUNT(*) AS cohort_customers,
    SUM(
        CASE
            WHEN c.second_order_ts IS NOT NULL
             AND c.second_order_ts < c.first_order_ts + INTERVAL w.window_days DAY
            THEN 1 ELSE 0
        END
    ) AS retained_customers,
    SUM(
        CASE
            WHEN c.second_order_ts IS NOT NULL
             AND c.second_order_ts < c.first_order_ts + INTERVAL w.window_days DAY
            THEN 1 ELSE 0
        END
    ) / NULLIF(COUNT(*), 0) * 100.0 AS retention_pct
FROM windows w
JOIN cohort c
  ON c.first_order_ts < (SELECT end_ts FROM params) - INTERVAL w.window_days DAY
GROUP BY w.window_days
ORDER BY w.window_days;
