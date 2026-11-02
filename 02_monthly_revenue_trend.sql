-- Business question: "How did revenue change month by month, and how fast was it growing?"
-- Query 2: Monthly revenue trend with month-over-month growth
WITH monthly AS (
  SELECT
    FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id)                            AS orders,
    ROUND(CAST(SUM(oi.price) AS NUMERIC), 2)              AS revenue
  FROM olist.orders AS o
  JOIN olist.order_items AS oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
  GROUP BY order_month
)
SELECT
  order_month,
  orders,
  revenue,
  ROUND(100 * SAFE_DIVIDE(revenue - LAG(revenue) OVER (ORDER BY order_month),
                          LAG(revenue) OVER (ORDER BY order_month)), 1) AS mom_growth_pct
FROM monthly
ORDER BY order_month;
