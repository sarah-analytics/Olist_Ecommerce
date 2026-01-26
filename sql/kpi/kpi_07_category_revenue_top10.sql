/* =========================================================
   KPI #07 — Category Revenue Top 10 (Allocation, LEFT JOIN Fix)

   Type         : Base
   Description  : Identify the top 10 product categories by total revenue
   Numerator    : Revenue allocated to each category
   Denominator  : Not applicable (KPI is absolute revenue, not a rate)
   Grain        : 1 row per category
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders in range with recorded payments + items
   Output       : category, revenue
   Notes        : Order-level payments are proportionally allocated to categories
                  based on each category’s item-value share within the order.

                  Allocation ratio uses:
                  Part  = category_item_value
                  Base  = order_item_value_total

                  LEFT JOIN to products retains items with missing product metadata,
                  assigning them to 'unknown' so that allocation remains complete
                  and category revenue sums back to total order revenue.
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
orders_in_range AS (
    -- base orders within time range
    SELECT
        o.order_id,
        o.order_purchase_timestamp
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
order_item_total AS (
    -- 1 row per order: total item-value (allocation base)
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_item_value_total
    FROM order_items AS oi
    GROUP BY
        oi.order_id
),
order_item_values AS (
    -- 1 row per order per category: item-value inside the order
    -- LEFT JOIN keeps items even if product dimension lookup is missing
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
allocated_category_revenue AS (
    -- allocate order-level revenue to categories by item-value share
    SELECT
        iv.category,
        pt.order_revenue
            * (iv.category_item_value / NULLIF(it.order_item_value_total, 0))
            AS allocated_revenue
    FROM orders_in_range AS o
    JOIN order_payment_total AS pt
      ON o.order_id = pt.order_id            -- must have payments
    JOIN order_item_total AS it
      ON o.order_id = it.order_id            -- must have items
    JOIN order_item_values AS iv
      ON o.order_id = iv.order_id
)

SELECT
    a.category,
    SUM(a.allocated_revenue) AS revenue
FROM allocated_category_revenue AS a
GROUP BY
    a.category
ORDER BY
    revenue DESC
LIMIT 10;
