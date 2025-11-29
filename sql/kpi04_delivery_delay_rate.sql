/* KPI #04 — Delivery Delay Rate
   Purpose: percentage of late deliveries */

SELECT
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
             THEN 'late'
        ELSE 'on_time'
    END AS delivery_status,                             -- status

    COUNT(*) AS order_count,                            -- count by status

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),        -- delay rate %
        2
    ) AS pct
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;
