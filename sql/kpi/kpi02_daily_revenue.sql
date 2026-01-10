/* =========================================================
   KPI #02 — Daily Revenue

   Type         : Base
   Grain        : 1 row per day
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : None
   Valid Orders : orders joined with order_payments (no additional filtering)

   Output       : order_date, daily_revenue
   Notes        : Gross revenue based on payment_value
   ========================================================= */

SELECT
    CAST(o.order_purchase_timestamp AS DATE) AS order_date,  -- order date
    SUM(p.payment_value) AS daily_revenue                    -- gross revenue
FROM orders o
JOIN order_payments p
  ON o.order_id = p.order_id
GROUP BY order_date
ORDER BY order_date;
