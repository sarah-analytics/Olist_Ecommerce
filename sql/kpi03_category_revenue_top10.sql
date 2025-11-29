/* KPI #03 — Category Revenue Top 10
   Purpose: top categories by revenue */

SELECT
    p.product_category_name AS category,         -- category
    ROUND(SUM(pay.payment_value), 2) AS revenue  -- total revenue
FROM order_items AS oi
JOIN products AS p
      ON oi.product_id = p.product_id
JOIN order_payments AS pay
      ON oi.order_id = pay.order_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;
