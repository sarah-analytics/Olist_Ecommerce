/* =========================================================
   MART — Daily KPI Summary

   Grain       : 1 row per day
   Description : Daily operational KPI summary for monitoring
   Source      : orders, order_payments
   ========================================================= */

WITH daily_orders AS (
    SELECT
        DATE(order_purchase_timestamp) AS order_date,
        COUNT(DISTINCT order_id) AS daily_orders
    FROM orders
    GROUP BY
        DATE(order_purchase_timestamp)
),
daily_revenue AS (
    SELECT
        DATE(o.order_purchase_timestamp) AS order_date,
        SUM(p.payment_value) AS daily_revenue
    FROM orders AS o
    JOIN order_payments AS p
      ON o.order_id = p.order_id
    GROUP BY
        DATE(o.order_purchase_timestamp)
),
delivery_metrics AS (
    SELECT
        DATE(order_purchase_timestamp) AS order_date,
        SUM(
            CASE
                WHEN order_delivered_customer_date <= order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0) * 100.0 AS on_time_rate_pct,
        AVG(
            DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)
        ) AS avg_delivery_days
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY
        DATE(order_purchase_timestamp)
)

SELECT
    d.order_date,
    d.daily_orders,
    r.daily_revenue,
    m.on_time_rate_pct,
    m.avg_delivery_days
FROM daily_orders AS d
LEFT JOIN daily_revenue AS r
  ON d.order_date = r.order_date
LEFT JOIN delivery_metrics AS m
  ON d.order_date = m.order_date
ORDER BY
    d.order_date;
