/* =========================================================
   KPI #09 — Order Mix by Price Bucket

   Type         : Derived
   Description  : Analyze distribution of orders across price ranges
   Numerator    : Number of orders in each price bucket
   Denominator  : Total number of orders
   Grain        : 1 row per price_bucket
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : All valid orders
   Output       : price_bucket, order_pct
   Notes        : Derived segmentation KPI for order composition
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
orders_in_range AS (
    SELECT
        o.order_id,
        o.order_purchase_timestamp
    FROM orders AS o
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
),
order_value AS (
    -- 1 row per order: use item value (price + freight) as order value proxy for bucketing
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM order_items AS oi
    GROUP BY
        oi.order_id
),
bucketed_orders AS (
    -- 1 row per order with price bucket label
    SELECT
        o.order_id,
        CASE
            WHEN v.order_value <  50 THEN '<50'
            WHEN v.order_value < 100 THEN '50-99'
            WHEN v.order_value < 200 THEN '100-199'
            WHEN v.order_value < 500 THEN '200-499'
            ELSE '500+'
        END AS price_bucket
    FROM orders_in_range AS o
    JOIN order_value AS v
      ON o.order_id = v.order_id
),
bucket_counts AS (
    -- 1 row per bucket
    SELECT
        b.price_bucket,
        COUNT(DISTINCT b.order_id) AS orders_in_bucket
    FROM bucketed_orders AS b
    GROUP BY
        b.price_bucket
),
total_orders AS (
    -- single row denominator
    SELECT
        SUM(c.orders_in_bucket) AS total_orders
    FROM bucket_counts AS c
)

SELECT
    c.price_bucket,
    c.orders_in_bucket / NULLIF(t.total_orders, 0) * 100.0 AS order_pct
FROM bucket_counts AS c
CROSS JOIN total_orders AS t
ORDER BY
    CASE c.price_bucket
        WHEN '<50'      THEN 1
        WHEN '50-99'    THEN 2
        WHEN '100-199'  THEN 3
        WHEN '200-499'  THEN 4
        WHEN '500+'     THEN 5
        ELSE 999
    END;


