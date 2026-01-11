/* =========================================================
   KPI #12 — Repeat Purchase Retention (30/60/90D)

   Type         : Derived
   Description  : Measure customer repeat purchase within N days of first order
   Numerator    : Customers with ≥1 repeat order within N days
   Denominator  : Customers with a first purchase (cohort window)
   Grain        : 1 row per window_days
   Time Basis   : first_order_timestamp
   Date Filter  : Cohort-based (first purchase window)
   Valid Orders : Completed (delivered) orders only
   Output       : window_days, retention_pct
   Notes        : Same logic across windows; N ∈ {30, 60, 90}
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
base_first AS (
    SELECT
        f.customer_unique_id,
        f.first_order_ts
    FROM int_customer_first_purchase AS f
    JOIN params AS p
      ON f.first_order_ts >= p.start_ts
     AND f.first_order_ts <  p.end_ts
),
retention_flags AS (
    -- 1 row per customer per window
    SELECT
        w.window_days,
        b.customer_unique_id,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM int_valid_orders_tbl AS v
                WHERE v.customer_unique_id = b.customer_unique_id
                  AND v.order_status = 'delivered'
                  AND v.order_purchase_timestamp >= b.first_order_ts + INTERVAL 1 DAY
                  AND v.order_purchase_timestamp <  b.first_order_ts + INTERVAL (w.window_days + 1) DAY
            )
            THEN 1 ELSE 0
        END AS is_retained
    FROM windows AS w
    CROSS JOIN base_first AS b
)

SELECT
    r.window_days,
    SUM(r.is_retained) / NULLIF(COUNT(*), 0) * 100.0 AS retention_pct
FROM retention_flags AS r
GROUP BY
    r.window_days
ORDER BY
    r.window_days;
