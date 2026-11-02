# E-commerce Sales & Customer Analysis (SQL, Google BigQuery)

SQL analysis of the **Olist Brazilian E-Commerce** public dataset (about 100K orders, 2016–2018) to answer practical business questions on growth, product mix, customer retention, delivery performance and regional performance.

**Tools:** Google BigQuery (SQL), joins across up to 4 tables, CTEs, window functions (`LAG`, `RANK`, `SUM() OVER()`), conditional aggregation (`CASE`, `COUNTIF`), `SAFE_CAST`, `TIMESTAMP_DIFF`.

---

## Business questions

1. How large is the business: orders, customers, revenue, average order value?
2. How did revenue grow month by month?
3. Which product categories drive revenue?
4. How many customers come back, and what are repeat customers worth?
5. Do late deliveries affect customer reviews?
6. How do revenue, delivery speed, lateness and ratings vary by state?

---

## Data

- **Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)
- **Tables used (8):** orders, customers, order_items, payments, products, sellers, category_translation, reviews
- **Scope:** delivered orders only. Revenue = item price (excluding freight), in Brazilian reais (R$).

### Data preparation notes

- Loaded the raw CSV files into BigQuery (header row skipped, quoted newlines allowed).
- The **reviews** file contains multi-line text, so it was loaded with jagged rows allowed, and `review_score` is converted with `SAFE_CAST`.
- The **category translation** table loaded without column names (`string_field_0` = Portuguese name, `string_field_1` = English name); queries join on these columns and fall back to the original name with `COALESCE`.
- Validated row counts for all 8 tables after loading.
- Monthly trends use **complete months only** (Jan 2017 – Aug 2018), because the 2016 data is sparse.
- Olist creates a new `customer_id` for every order, so repeat customers are identified with `customer_unique_id`.
- In the state analysis, revenue and reviews are summarised **per order first**, to avoid double-counting when joining.

---

## Key findings

| # | Analysis | Insight |
|---|---|---|
| 1 | Business overview | **96,478 delivered orders** from **93,358 unique customers**, R$13.22M revenue, average order value **R$137.04**, roughly **1.03 orders per customer** |
| 2 | Monthly trend | Revenue grew from R$112K (Jan 2017) to a **Black Friday peak of R$988K in Nov 2017** (+52.4% MoM, followed by −26.5% in Dec), then levelled off at R$0.83–0.98M per month in 2018. Jan–Aug 2018 revenue (R$7.22M) was **~141% higher** than Jan–Aug 2017 (R$2.99M). |
| 3 | Top categories | The **top 10 categories drive ~62% of revenue**. Volume and value differ: *bed_bath_table* has the most orders but ranks #3 by revenue, while *watches_gifts* earns the most per order. |
| 4 | Retention | **97% of customers ordered only once.** Repeat customers spend **1.8× (2 orders) to 3× (3+ orders)** more than one-time customers. |
| 5 | Delivery vs reviews | Late deliveries are **8% of orders** but cause **~34% of all 1–2 star reviews**. Average rating drops from **4.29 (on time) to 2.57 (late)**. |
| 6 | State performance | SP is **38% of revenue** with the fastest delivery (8.3 days). **RJ, the #2 market, has more than double SP's late rate** (13.5% vs 5.9%) and lower ratings. Remote states with long but realistic delivery estimates (e.g., AP, AM) still rate well, so **lateness against the promised date matters more than raw speed**. |

---

## Recommendations

1. **Retention is the biggest untapped lever.** With 97% one-time buyers, post-purchase follow-ups, loyalty offers and personalised recommendations could lift revenue from the existing customer base. Doubling the repeat rate (about 3% → 6%) would add roughly R$300K, around a 2% revenue lift.
2. **Fix delivery reliability, especially in RJ and the North-East.** RJ is a large market with a high late rate, putting a significant share of revenue at risk.
3. **Set realistic delivery estimates.** Customers judge delivery against the promise, so accurate estimates can protect ratings even where delivery is slow.
4. **Grow value in high-volume categories.** Bundling or upselling in categories like *bed_bath_table* could raise revenue per order.

---

## Repository structure

```
sql/
  01_business_overview.sql
  02_monthly_revenue_trend.sql
  03_top_categories.sql
  04_customer_retention.sql
  05_delivery_vs_reviews.sql
  06_state_performance.sql
README.md
```

## How to reproduce

1. Download the dataset from Kaggle.
2. Create a BigQuery dataset named `olist` and load the CSV files as tables: `orders`, `customers`, `order_items`, `payments`, `products`, `sellers`, `category_translation`, `reviews`.
3. Run the queries in the `sql/` folder in order.

---

**Author:** Ksheeraja P · [LinkedIn](https://www.linkedin.com/in/ksheeraja-p)
