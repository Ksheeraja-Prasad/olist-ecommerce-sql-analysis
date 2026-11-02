-- Business question: "How big is this business? How many orders, customers and how much revenue, and what's the average order value?"
-- Query 1: Business overview (delivered orders only)
SELECT
  COUNT(DISTINCT o.order_id) AS total_orders,
  COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
  ROUND(CAST(SUM(oi.price) AS NUMERIC), 2) AS total_revenue,
  ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM olist.orders AS o
JOIN olist.order_items AS oi ON o.order_id = oi.order_id
JOIN olist.customers  AS c  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';
