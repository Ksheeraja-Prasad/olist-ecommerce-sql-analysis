-- 06. State-level performance: revenue, delivery days, late %, review score
-- Revenue and reviews are summarised per order first to avoid double-counting (fan-out).

WITH order_revenue AS (
  SELECT order_id, SUM(price) AS revenue
  FROM olist.order_items
  GROUP BY order_id
),
order_review AS (
  SELECT order_id, AVG(SAFE_CAST(review_score AS INT64)) AS review_score
  FROM olist.reviews
  GROUP BY order_id
),
order_level AS (
  SELECT
    c.customer_state AS state,
    o.order_id,
    r.revenue,
    TIMESTAMP_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS delivery_days,
    o.order_delivered_customer_date > o.order_estimated_delivery_date AS is_late,
    rv.review_score
  FROM olist.orders o
  JOIN olist.customers c
    ON o.customer_id = c.customer_id
  JOIN order_revenue r
    ON o.order_id = r.order_id
  LEFT JOIN order_review rv
    ON o.order_id = rv.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
  state,
  COUNT(*) AS orders,
  ROUND(CAST(SUM(revenue) AS NUMERIC), 2) AS revenue,
  ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
  ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
  ROUND(100 * COUNTIF(is_late) / COUNT(*), 1) AS late_pct,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM order_level
GROUP BY state
ORDER BY revenue DESC;
