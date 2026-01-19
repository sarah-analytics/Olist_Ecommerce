/* =========================================================
   TEST — KPI #07 Allocation Balance Check

   Purpose     : Validate revenue allocation logic
   Assertion   : SUM(allocated_revenue) == order_revenue
   Grain       : 1 row per order
   Expected    : No rows returned (diff ≈ 0)
   Notes       : Ensures allocation completeness and
                 prevents revenue leakage due to joins
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
orders_in_range AS (
    SELECT
        o.order_id
    FROM orders AS o
    JOIN params AS prm
      ON o.order_purchase_timestamp >= prm.start_ts
     AND o.order_purchase_timestamp <  prm.end_ts
),
order_payment_total AS (
    -- 1 row per order: total paid amount (revenue pool)
    SELECT
        p.order_id,
        SUM(p.payment_value) AS order_revenue
    FROM order_payments AS p
    GROUP BY
        p.order_id
),
order_item_values AS (
    -- LEFT JOIN keeps items even if product lookup is missing
    SELECT
        oi.order_id,
        COALESCE(pr.product_category_name, 'unknown') AS category,
        SUM(oi.price + oi.freight_value) AS category_item_value
    FROM order_items AS oi
    LEFT JOIN products AS pr
      ON oi.product_id = pr.product_id
    GROUP BY
        oi.order_id,
        COALESCE(pr.product_category_name, 'unknown')
),
order_item_total AS (
    -- 1 row per order: total item-value (allocation base)
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_item_value_total
    FROM order_items AS oi
    GROUP BY
        oi.order_id
),
allocation_category_value AS (
    -- order-level allocation rows (order_id, category)
    SELECT
        o.order_id,
        iv.category,
        pt.order_revenue
          * (iv.category_item_value / NULLIF(it.order_item_value_total, 0))
          AS allocated_revenue
    FROM orders_in_range AS o
    JOIN order_payment_total AS pt
      ON o.order_id = pt.order_id
    JOIN order_item_total AS it
      ON o.order_id = it.order_id
    JOIN order_item_values AS iv
      ON o.order_id = iv.order_id
),
order_level_check AS (
    SELECT
        a.order_id,
        MAX(pt.order_revenue)                    AS order_revenue,
        SUM(a.allocated_revenue)                 AS allocated_revenue_sum,
        SUM(a.allocated_revenue) - MAX(pt.order_revenue) AS diff
    FROM allocation_category_value AS a
    JOIN order_payment_total AS pt
      ON a.order_id = pt.order_id
    GROUP BY
        a.order_id
)

SELECT
    order_id,
    order_revenue,
    allocated_revenue_sum,
    diff
FROM order_level_check
WHERE ABS(diff) > 0.01      
ORDER BY ABS(diff) DESC
LIMIT 100;
