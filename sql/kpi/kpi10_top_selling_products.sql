/* KPI #10 — Top Selling Products
   Purpose: top-selling products by total quantity sold */

SELECT
    p.product_category_name AS category,          -- category
    p.product_id,                                 -- product id
    COUNT(*) AS total_sold                        -- quantity sold
FROM order_items AS oi
JOIN products AS p
      ON oi.product_id = p.product_id
GROUP BY p.product_category_name, p.product_id
ORDER BY total_sold DESC
LIMIT 10;
