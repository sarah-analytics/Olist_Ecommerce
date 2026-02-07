/* =========================================================
   DDL — Indexes for INT Customer First Purchase

   Purpose  : Optimize cohort filtering and time-based joins
              for retention and repeat purchase KPIs
   Target   : int_customer_first_purchase
   ========================================================= */

ALTER TABLE int_customer_first_purchase
  ADD PRIMARY KEY (customer_unique_id),
  ADD INDEX idx_first_order_ts (first_order_ts);
