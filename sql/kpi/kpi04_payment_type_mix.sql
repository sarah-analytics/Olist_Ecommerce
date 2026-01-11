/* =========================================================
   KPI #04 — Payment Type Mix

   Type         : Derived
   Description  : Analyze revenue composition by payment method
   Numerator    : Revenue by payment type
   Denominator  : Total revenue
   Grain        : 1 row per payment_type
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders with recorded payments
   Output       : payment_type, revenue, revenue_pct
   Notes        : Mix analysis KPI; percentage is the primary interpretation
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
payment_type_revenue AS (
    SELECT
        p.payment_type               AS payment_type,   -- grain
        SUM(p.payment_value)         AS revenue         -- numerator
    FROM orders AS o
    JOIN order_payments AS p
      ON o.order_id = p.order_id                       -- payments define revenue
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
    GROUP BY
        p.payment_type
),
total_revenue AS (
    SELECT
        SUM(revenue) AS total_revenue                   -- denominator (single row)
    FROM payment_type_revenue
)

SELECT
    r.payment_type,
    r.revenue,
    r.revenue / NULLIF(t.total_revenue, 0) * 100.0      AS revenue_pct
FROM payment_type_revenue AS r
CROSS JOIN total_revenue AS t
ORDER BY
    r.revenue DESC,
    r.payment_type;
