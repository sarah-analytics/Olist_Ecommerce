/* =========================================================
   KPI #13 — Fulfillment Rate (Order-Level)

   Type         : Base
   Description  : Percentage of finalized orders successfully fulfilled.
                  Fulfillment success is defined as orders with 'delivered' status.

   Numerator    : Orders with order_status = 'delivered'
   Denominator  : Finalized orders with status IN ('delivered', 'canceled', 'unavailable')

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Output       : order_date, fulfilled_orders, finalized_orders, fulfillment_rate_pct

   Notes        :
     - Order-level fulfillment proxy based on final order outcome.
     - Excludes in-progress statuses: created, approved, invoiced, processing, shipped
     - fulfillment_rate_pct = fulfilled_orders / finalized_orders * 100
   ========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
finalized_orders AS (
    -- Finalized orders only (success or failure outcome known)
    SELECT
        DATE(order_purchase_timestamp) AS order_date,
        order_id,
        order_status
    FROM orders
    WHERE order_purchase_timestamp >= (SELECT start_ts FROM params)
      AND order_purchase_timestamp <  (SELECT end_ts   FROM params)
      AND order_status IN ('delivered', 'canceled', 'unavailable')
),
daily AS (
    SELECT
        order_date,

        -- Numerator: fulfilled orders
        COUNT(CASE WHEN order_status = 'delivered' THEN 1 END)
            AS fulfilled_orders,

        -- Denominator: finalized orders
        COUNT(*) AS finalized_orders

    FROM finalized_orders
    GROUP BY order_date
)
SELECT
    order_date,
    fulfilled_orders,
    finalized_orders,

    -- Fulfillment rate (%)
    fulfilled_orders / NULLIF(finalized_orders, 0) * 100.0
        AS fulfillment_rate_pct

FROM daily
ORDER BY order_date;
