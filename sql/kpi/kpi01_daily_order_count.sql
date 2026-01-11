/* =========================================================
   KPI #01 — Daily Orders

   Type         : Base
   Description  : Track the number of orders placed per day
   Numerator    : Count of distinct orders
   Denominator  : Not applicable (absolute count)
   Grain        : 1 row per day
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : All orders with valid order records
   Output       : order_date, daily_orders
   Notes        : Baseline volume KPI for overall business activity
   ========================================================= */

SELECT
    CAST(o.order_purchase_timestamp AS DATE) AS order_date,  -- calendar date
    COUNT(*) AS order_count                                  -- orders per day
FROM orders o
GROUP BY order_date
ORDER BY order_date;
