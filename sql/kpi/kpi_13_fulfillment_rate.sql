/* =========================================================
   KPI #13 — Fulfillment Rate (Order-Level)

   Type         : Base
   Description  : Percentage of finalized orders that were successfully fulfilled.
                  Fulfillment success is defined as orders with 'delivered' status.

   Numerator    : Orders with order_status = 'delivered'
   Denominator  : Finalized orders with status IN ('delivered', 'canceled', 'unavailable')

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Output       : order_date, fulfilled_orders, finalized_orders, fulfillment_rate_pct

   Notes        :
     - Uses final order outcome to measure fulfillment performance.
     - Excludes in-progress statuses (created, approved, invoiced, processing, shipped).
     - fulfillment_rate_pct = fulfilled_orders / finalized_orders * 100
   ========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,  -- day grain

    -- Numerator: successfully fulfilled orders
    COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END)
        AS fulfilled_orders,

    -- Denominator: finalized orders only
    COUNT(*) AS finalized_orders,

    -- Fulfillment rate (%)
    COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END)
        / NULLIF(COUNT(*), 0) * 100.0 AS fulfillment_rate_pct

FROM orders AS o

-- Apply date filter
WHERE o.order_purchase_timestamp >= (SELECT start_ts FROM params)
  AND o.order_purchase_timestamp <  (SELECT end_ts   FROM params)

-- Keep only finalized outcomes
  AND o.order_status IN ('delivered', 'canceled', 'unavailable')

GROUP BY DATE(o.order_purchase_timestamp)
ORDER BY order_date;
