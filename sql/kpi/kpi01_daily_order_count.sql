/* =========================================================
   KPI #01 — Daily Order Count

   Type         : Base
   Grain        : 1 row per day
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : None
   Valid Orders : orders table (no additional filtering)

   Output       : order_date, order_count
   Notes        : Overall daily volume trend / sanity check
   ========================================================= */

SELECT
    CAST(o.order_purchase_timestamp AS DATE) AS order_date,  -- calendar date
    COUNT(*) AS order_count                                  -- orders per day
FROM orders o
GROUP BY order_date
ORDER BY order_date;
