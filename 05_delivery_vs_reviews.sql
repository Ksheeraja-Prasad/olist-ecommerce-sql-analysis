-- 05. On-time vs late deliveries and their effect on review scores
-- Late = delivered after the estimated delivery date.

WITH order_reviews AS (
  SELECT
    o.order_id,
    CASE
      WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On time'
      ELSE 'Late'
    END AS delivery_status,
    SAFE_CAST(r.review_score AS INT64) AS review_score
  FROM olist.orders o
  JOIN olist.reviews r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
  delivery_status,
  COUNT(*) AS orders,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS order_share_pct,
  ROUND(AVG(review_score), 2) AS avg_review_score,
  ROUND(100 * COUNTIF(review_score <= 2) / COUNT(*), 1) AS pct_low_reviews
FROM order_reviews
GROUP BY delivery_status
ORDER BY delivery_status DESC;
