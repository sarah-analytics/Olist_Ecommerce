/* =========================================================
   KPI #11 — AOV by Price Bucket

   Type         : Derived
   Description  : Measure average order value within each price bucket
   Numerator    : Total revenue per bucket
   Denominator  : Number of orders per bucket
   Grain        : 1 row per price_bucket
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders with recorded payments
   Output       : price_bucket, aov
   Notes        : Used to compare spending behavior across segments
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
    -- 1 row per order: item-value used only for price bucketing
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM order_items AS oi
    GROUP BY
        oi.order_id
),
order_revenue AS (
    -- 1 row per order: actual paid revenue
    SELECT
        p.order_id,
        SUM(p.payment_value) AS order_revenue
    FROM order_payments AS p
    GROUP BY
        p.order_id
),
bucketed_orders AS (
    -- 1 row per paid order with bucket + revenue
    SELECT
        o.order_id,
        r.order_revenue,
        CASE
            WHEN v.order_value <  50 THEN '<50'
            WHEN v.order_value < 100 THEN '50-99'
            WHEN v.order_value < 200 THEN '100-199'
            WHEN v.order_value < 500 THEN '200-499'
            ELSE '500+'
        END AS price_bucket
    FROM orders_in_range AS o
    JOIN order_value   AS v ON o.order_id = v.order_id
    JOIN order_revenue AS r ON o.order_id = r.order_id   -- Valid Orders: recorded payments
),
bucket_stats AS (
    -- 1 row per bucket: orders + revenue
    SELECT
        b.price_bucket,
        COUNT(DISTINCT b.order_id) AS orders_cnt,
        SUM(b.order_revenue)       AS revenue
    FROM bucketed_orders AS b
    GROUP BY
        b.price_bucket
)

SELECT
    s.price_bucket,
    s.revenue / NULLIF(s.orders_cnt, 0) AS aov
FROM bucket_stats AS s
ORDER BY
    CASE s.price_bucket
        WHEN '<50'      THEN 1
        WHEN '50-99'    THEN 2
        WHEN '100-199'  THEN 3
        WHEN '200-499'  THEN 4
        WHEN '500+'     THEN 5
        ELSE 999
    END;
