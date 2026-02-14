/* =========================================================
   KPI #12 — Repeat Purchase Retention (30/60/90D)

   Type         : Derived
   Description  : Measure customer repeat purchase within N days of first order
   Numerator    : Customers with ≥1 repeat order within N days
   Denominator  : Customers with a first purchase in cohort window
   Grain        : 1 row per window_days
   Time Basis   : cohort_first.first_order_ts
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Delivered orders only
   Output       : window_days, cohort_customers, retained_customers, retention_pct
   Notes        : Cohort defined by first_order_ts; repeat must occur after first_order_ts
                  and before first_order_ts + INTERVAL window_days DAY
   ========================================================= */
WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
windows AS (
    SELECT 30 AS window_days UNION ALL
    SELECT 60 UNION ALL
    SELECT 90
),
cohort_first AS (
    -- 1 row per customer_unique_id (cohort anchor)
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_ts
    FROM orders AS o
    JOIN customers AS c
      ON o.customer_id = c.customer_id
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_unique_id
),
repeat_flag AS (
    -- 1 row per (customer_unique_id, window_days) where repeat exists
    SELECT DISTINCT
        f.customer_unique_id,
        w.window_days
    FROM cohort_first AS f
    CROSS JOIN windows AS w
    JOIN customers AS c
      ON c.customer_unique_id = f.customer_unique_id
    JOIN orders AS o
      ON o.customer_id = c.customer_id
     AND o.order_status = 'delivered'
     AND o.order_purchase_timestamp >  f.first_order_ts
     AND o.order_purchase_timestamp <  f.first_order_ts + INTERVAL w.window_days DAY
)
SELECT
    w.window_days,
    COUNT(DISTINCT f.customer_unique_id) AS cohort_customers,
    COUNT(DISTINCT rf.customer_unique_id) AS retained_customers,
    COUNT(DISTINCT rf.customer_unique_id) / NULLIF(COUNT(DISTINCT f.customer_unique_id), 0) * 100.0 AS retention_pct
FROM windows AS w
CROSS JOIN cohort_first AS f
LEFT JOIN repeat_flag AS rf
  ON rf.customer_unique_id = f.customer_unique_id
 AND rf.window_days = w.window_days
GROUP BY
    w.window_days
ORDER BY
    w.window_days;
