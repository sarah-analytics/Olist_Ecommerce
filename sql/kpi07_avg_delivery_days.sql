/* KPI #07 — Average Delivery Days
   Purpose: average days from purchase to delivery */

SELECT
    ROUND(
        AVG(
            DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
