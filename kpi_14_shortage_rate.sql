/* =========================================================
   KPI #14 — Shortage Rate (Order Failure Rate)

   Type         : Base
   Description  : Percentage of finalized orders that failed due to cancellation
                  or unavailability. This is an order-outcome based operational KPI.

   Numerator    : Orders with status IN ('canceled', 'unavailable')
   Denominator  : Finalized orders with status IN ('delivered', 'canceled', 'unavailable')

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Output       : order_date, shortage_orders, finalized_orders, shortage_rate_pct

   Notes        :
     - This is NOT a true inventory discrepancy metric (no inventory table in Olist).
     - It is a defensible operational proxy using final order outcomes.
     - Excludes in-progress statuses: created, approved, invoiced, processing, shipped
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

        -- Numerator: shortage/failure orders
        COUNT(CASE WHEN order_status IN ('canceled', 'unavailable') THEN 1 END)
            AS shortage_orders,

        -- Denominator: finalized orders
        COUNT(*) AS finalized_orders

    FROM finalized_orders
    GROUP BY order_date
)
SELECT
    order_date,
    shortage_orders,
    finalized_orders,

    -- Shortage rate (%)
    shortage_orders / NULLIF(finalized_orders, 0) * 100.0
        AS shortage_rate_pct

FROM daily
ORDER BY order_date;
