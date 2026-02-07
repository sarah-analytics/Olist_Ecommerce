/* =========================================================
   DDL — Indexes for INT Valid Orders

   Purpose  : Optimize customer-based time-range lookups
              used by retention and customer KPIs
   Target   : int_valid_orders_tbl
   ========================================================= */

ALTER TABLE int_valid_orders_tbl
  ADD PRIMARY KEY (order_id),
  ADD INDEX idx_valid_orders_cust_ts (customer_unique_id, order_purchase_timestamp);
