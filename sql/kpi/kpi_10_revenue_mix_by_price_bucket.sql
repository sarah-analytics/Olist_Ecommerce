/* =========================================================
   KPI #10 — Revenue Mix by Price Bucket

   Type         : Derived
   Description  : Analyze revenue contribution by price range
   Numerator    : Revenue in each price bucket
   Denominator  : Total revenue
   Grain        : 1 row per price_bucket
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders with recorded payments
   Output       : price_bucket, revenue_pct
   Notes        : Highlights revenue concentration by order value
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
    -- 1 row per order with price bucket
    SELECT
        o.order_id,
        r.order_revenue,
        CASE
            WHEN v.order_value <  50 THEN '<50'
            WHEN v.order_value < 100 THEN '50-99'
            WHEN v.ord
