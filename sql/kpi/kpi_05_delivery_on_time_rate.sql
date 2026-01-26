/* =========================================================
   KPI #05 — Delivery On-time Rate

   Type         : Derived
   Description  : Analyze the rate of delivered orders that were on time (i.e., delivered on or before the estimated delivery date).
   Numerator    : Count of delivered orders that were on time
   Denominator  : Total delivered orders
   Grain        : 1 row (overall rate for the period)
   Time Basis   : orders.order_delivered_customer_date
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Delivered orders only
   Output       : Percentage of orders delivered on time (on_time_rate)
   Notes        : Tracks operational reliability.
   ========================================================= */

WITH params AS (
    -- Define the start and end dates for the analysis period
    SELECT 
        timestamp('2017-01-01 00:00:00') AS start_ts,
        timestamp('2018-01-01 00:00:00') AS end_ts
),
delivered_base AS (
    -- Select all orders delivered within the specified time range
    SELECT 
        o.order_id, 
        o.order_delivered_customer_date, 
        o.order_estimated_delivery_date
    FROM orders AS o
    JOIN params AS prm
        ON o.order_delivered_customer_date >= prm.start_ts
        AND o.order_delivered_customer_date < prm.end_ts
    WHERE o.order_status = 'delivered'  -- Only include delivered orders
),
delivered_on_time_base AS (
    -- Calculate if the order was delivered on time
    SELECT 
        order_id,
        CASE 
            WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1  -- On-time delivery
            ELSE 0  -- Late delivery
        END AS on_time_flag
    FROM delivered_base
)

-- Calculate the overall on-time delivery rate
SELECT 
    SUM(on_time_flag) / NULLIF(COUNT(*), 0) * 100.0 AS on_time_rate  -- Calculate the percentage of on-time deliveries
FROM delivered_on_time_base;
