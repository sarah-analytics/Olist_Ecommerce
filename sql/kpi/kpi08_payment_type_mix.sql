/* KPI #08 — Payment Type Mix
   Purpose: % share of each payment method */

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS pct
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;
