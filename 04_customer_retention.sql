-- 04. Customer retention: one-time vs repeat customers and their revenue share
-- customer_unique_id identifies the same person across orders (customer_id changes per order).

WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.price) AS revenue
  FROM olist.orders o
  JOIN olist.customers c
    ON o.customer_id = c.customer_id
  JOIN olist.order_items oi
    ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT
  CASE
    WHEN num_orders = 1 THEN '1 order'
    WHEN num_orders = 2 THEN '2 orders'
    ELSE '3+ orders'
  END AS customer_segment,
  COUNT(*) AS customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct,
  ROUND(CAST(SUM(revenue) AS NUMERIC), 2) AS revenue,
  ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct
FROM customer_orders
GROUP BY customer_segment
ORDER BY customer_segment;
