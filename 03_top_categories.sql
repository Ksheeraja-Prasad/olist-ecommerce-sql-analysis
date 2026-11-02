-- 03. Top 10 product categories by revenue, with revenue share and rank
-- Note: the category translation table loaded without a header, so its columns are
-- string_field_0 (Portuguese name) and string_field_1 (English name).

WITH category_revenue AS (
  SELECT
    COALESCE(t.string_field_1, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(CAST(SUM(oi.price) AS NUMERIC), 2) AS revenue
  FROM olist.orders o
  JOIN olist.order_items oi
    ON o.order_id = oi.order_id
  JOIN olist.products p
    ON oi.product_id = p.product_id
  LEFT JOIN olist.category_translation t
    ON p.product_category_name = t.string_field_0
  WHERE o.order_status = 'delivered'
  GROUP BY category
)
SELECT
  category,
  orders,
  revenue,
  ROUND(100 * revenue / SUM(revenue) OVER (), 1) AS revenue_share_pct,
  RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM category_revenue
ORDER BY revenue DESC
LIMIT 10;
