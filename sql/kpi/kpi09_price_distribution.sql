SELECT
    CASE
        WHEN price < 50 THEN '<50'
        WHEN price < 100 THEN '50-99'
        WHEN price < 200 THEN '100-199'
        WHEN price < 500 THEN '200-499'
        ELSE '500+'
    END AS price_bucket,
    COUNT(*) AS product_count
FROM order_items
GROUP BY price_bucket
ORDER BY
    FIELD(price_bucket, '<50', '50-99', '100-199', '200-499', '500+');

