/* =========================================================
   KPI #06 — Average Delivery Days

   Type         : Diagnostic
   Description  : Measure average delivery duration from purchase to delivery
   Numerator    : Total delivery days
   Denominator  : Number of delivered orders
   Grain        : 1 row (overall average)
   Time Basis   : orders.order_delivered_customer_date
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Delivered orders only
   Output       : avg_delivery_days
   Notes        : Used to contextualize delivery performance and delays
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
delivered_base AS (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date
    FROM orders AS o
    JOIN params AS prm
      ON o.order_delivered_customer_date >= prm.start_ts
     AND o.order_delivered_customer_date <  prm.end_ts
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
)

SELECT
    AVG(
        DATEDIFF(
            delivered_base.order_delivered_customer_date,
            delivered_base.order_purchase_timestamp
        )
    ) AS avg_delivery_days
FROM delivered_base;
