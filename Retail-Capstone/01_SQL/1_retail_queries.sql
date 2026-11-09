/* =====================================================================
   Capstone Project 1: Retail Chain
   Question: Revenue grew about 12%, so why did profit fall?
   Database: SQL Server 2016 (class portal)
   ===================================================================== */

/* ---------------------------------------------------------------------
   METRIC DEFINITIONS (used by everyone in class)
   Gross sales          = quantity * unit_price
   Discount             = discount_amount (already the total for the line)
   Revenue              = quantity * unit_price - discount_amount
   Cost                 = quantity * unit_cost_at_sale
   Refunds              = from the CLEANED returns feed
   Gross profit         = Revenue - Cost - Refunds
   Margin %             = Gross profit / Revenue
   Effective discount % = Discount / Gross sales
   Return rate          = Returned lines / Completed lines
   Rules: only order_status = 'Completed' counts.
          Discounts are already out of revenue - do not subtract twice.
   --------------------------------------------------------------------- */


-- Step 1: Count the rows in each table
-- Expected: orders 12,000 | order_items 29,970 | customers 2,538 | returns_feed 863
-- My result:
-- (type your query below)

--Answer 1
/*
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM dbo.retail_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM dbo.retail_order_items
UNION ALL SELECT 'customers', COUNT(*) FROM dbo.retail_customers
UNION ALL SELECT 'returns_feed', COUNT(*) FROM dbo.retail_returns_feed;

-- My result: orders 12,000 | order_items 29,970 | customers 2,538 | returns_feed 863
*/


-- Step 2: Look at the order_status column
-- Expected: Completed 11,586 | Cancelled 414
/*
SELECT order_status, COUNT(*) AS orders      -- ← the one running now
FROM dbo.retail_orders
GROUP BY order_status
ORDER BY orders DESC;
*/
-- My result: Completed 11,586 | Cancelled 414  -> matches



-- Step 3: Revenue by year (Completed orders only)
-- Expected: 2024 revenue about $773,902 | 2025 about $867,086
-- My result:

/*
SELECT YEAR(o.order_datetime) AS order_year,
       SUM(i.quantity * i.unit_price) AS gross_sales,
       SUM(i.discount_amount) AS discounts,
       SUM(i.quantity * i.unit_price - i.discount_amount) AS revenue,
       SUM(i.quantity * i.unit_cost_at_sale) AS cost
--FROM dbo.retail_order_items AS i
--JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--WHERE o.order_status = 'Completed'
--GROUP BY YEAR(o.order_datetime)
--ORDER BY order_year;
*/
-- My result: Revenue 2023 $707,915 | 2024 $773,902 | 2025 $867,086 -> matches (raw, before cleaning)
-- Note: discounts grew ~40% in 2025 vs gross sales ~14%


/*
--Step 3 part b 
--SELECT YEAR(o.order_datetime) AS order_year,
--       SUM(i.quantity * i.unit_price) AS gross_sales,
--       SUM(i.discount_amount) AS discounts,
--       SUM(i.quantity * i.unit_price - i.discount_amount) AS revenue,
--       SUM(i.quantity * i.unit_cost_at_sale) AS cost
--FROM dbo.retail_order_items AS i
--JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--add (--) to run this step in front of WHERE
--WHERE o.order_status = 'Completed' 
--GROUP BY YEAR(o.order_datetime)
--ORDER BY order_year;
*/

-- Step 3b (Trap 1): WHERE removed -> revenue 2023 $736,930 | 2024 $797,745 | 2025 $900,173
-- Overstated by $29,015 / $23,843 / $33,087 because cancelled lines were counted



-- Step 4: INNER JOIN vs LEFT JOIN to customers (guest orders)
-- My result:

/*
SELECT YEAR(o.order_datetime) AS order_year,
       SUM(i.quantity * i.unit_price - i.discount_amount) AS total_revenue,
       SUM(CASE WHEN c.customer_id IS NOT NULL THEN 0
                ELSE i.quantity * i.unit_price - i.discount_amount END) AS guest_revenue
FROM dbo.retail_order_items AS i
JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
LEFT JOIN dbo.retail_customers AS c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY YEAR(o.order_datetime)
ORDER BY order_year;
*/

-- My result: guest revenue 2023 $84,722 | 2024 $91,938 | 2025 $108,408 -> matches
-- INNER JOIN would lose ~12% of revenue, so use LEFT JOIN on customers



-- Step 5: Core SQL skills

--Step 5a
/*
WITH yearly AS (
    SELECT YEAR(o.order_datetime) AS order_year,
           SUM(i.quantity * i.unit_price - i.discount_amount) AS revenue,
           SUM(i.quantity * i.unit_cost_at_sale) AS cost
    FROM dbo.retail_order_items AS i
    JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY YEAR(o.order_datetime)
)
SELECT order_year, revenue,
       revenue / LAG(revenue) OVER (ORDER BY order_year) - 1 AS revenue_growth,
       revenue - cost AS margin_before_refunds,
       (revenue - cost) / revenue AS margin_pct
FROM yearly
ORDER BY order_year;

*/

-- My result: growth NULL / 9.3% / 12.0% | margin 23.5% / 23.3% / 21.9% -> matches
-- Revenue growing but margin slipping in 2025 (before refunds)


--Step 5b
--SELECT YEAR(o.order_datetime) AS order_year,
--      CASE WHEN o.promotion_id IS NULL THEN 'No promotion' ELSE 'On promotion' END AS promo_group,
--       COUNT(DISTINCT o.order_id) AS orders,
--       SUM(i.quantity * i.unit_price - i.discount_amount) AS revenue
--FROM dbo.retail_order_items AS i
--JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--WHERE o.order_status = 'Completed'
--GROUP BY YEAR(o.order_datetime),
--         CASE WHEN o.promotion_id IS NULL THEN 'No promotion' ELSE 'On promotion' END
--ORDER BY order_year, promo_group;

-- 5b My result: On-promotion orders 412 / 593 / 887 | revenue $79,863 / $105,576 / $144,680 -> matches
-- Promo orders doubled 2023->2025; non-promo nearly flat


--Step 5c

--SELECT g.region_name, YEAR(o.order_datetime) AS order_year,
--       DATEPART(QUARTER, o.order_datetime) AS order_qtr,
--       SUM(i.discount_amount) / SUM(i.quantity * i.unit_price) AS discount_pct
--FROM dbo.retail_order_items AS i
--JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--JOIN dbo.retail_stores AS s ON s.store_id = o.store_id
--JOIN dbo.retail_regions AS g ON g.region_id = s.region_id
--WHERE o.order_status = 'Completed'
--GROUP BY g.region_name, YEAR(o.order_datetime), DATEPART(QUARTER, o.order_datetime)
--HAVING SUM(i.discount_amount) / SUM(i.quantity * i.unit_price) > 0.10
--ORDER BY order_year, order_qtr, g.region_name;

-- 5c My result: 6 region-quarters over 10% discount -> matches
-- Midwest in 5 straight quarters (2024 Q4 to 2025 Q4), up to 18.2% -> lead to test

--5d: RANK, top store in each region
--WITH store_sales AS (
--    SELECT g.region_name, s.store_name,
--         SUM(i.quantity * i.unit_price - i.discount_amount) AS revenue

--FROM dbo.retail_order_items AS i
--   JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--    JOIN dbo.retail_stores AS s ON s.store_id = o.store_id
--   JOIN dbo.retail_regions AS g ON g.region_id = s.region_id
--    WHERE o.order_status = 'Completed'
--    GROUP BY g.region_name, s.store_name
--), ranked AS (
--   SELECT *, RANK() OVER (PARTITION BY region_name ORDER BY revenue DESC) AS region_rank
--    FROM store_sales
--)
--SELECT region_name, store_name, revenue
--FROM ranked
--WHERE region_rank = 1
--ORDER BY revenue DESC;

-- 5d My result: top store per region, NY Parkway Mall $241,485 leads (~2.5x next) -> matches
-- Flagship = obvious suspect; test its margin later (big is not the same as bad)

--5e: Rolling 3-month discount %

--WITH monthly AS (
--    SELECT DATEFROMPARTS(YEAR(o.order_datetime), MONTH(o.order_datetime), 1) AS order_month,
--          SUM(i.discount_amount) AS discounts,
--           SUM(i.quantity * i.unit_price) AS gross_sales
--    FROM dbo.retail_order_items AS i
--    JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--   WHERE o.order_status = 'Completed'
--    GROUP BY DATEFROMPARTS(YEAR(o.order_datetime), MONTH(o.order_datetime), 1)
--)
--SELECT TOP (6) order_month, discounts / gross_sales AS discount_pct,
--       SUM(discounts) OVER (ORDER BY order_month ROWS 2 PRECEDING)
--     / SUM(gross_sales) OVER (ORDER BY order_month ROWS 2 PRECEDING) AS rolling_3mo
--FROM monthly
--ORDER BY order_month DESC;

-- 5e My result: Dec 2025 discount 11.6%, rolling 3-mo 9.0% -> matches
-- Rolling avg = sum(discounts)/sum(gross) over 3 months, not an average of percentages



-- Step 6: Look at the returns feed before joining it (random sample)

--6: Trap 3, are return references unique?
--SELECT COUNT(*) AS feed_rows,
--       SUM(CASE WHEN return_ref IS NULL THEN 1 ELSE 0 END) AS blank_rows,
--       COUNT(DISTINCT UPPER(LTRIM(RTRIM(return_ref)))) AS unique_refs
--FROM dbo.retail_returns_feed;

-- Step 6 My result: 863 rows | 3 blank | 820 unique refs -> matches
-- 40 repeated refs -> joining now would double-count refunds; clean first


--6b Expected: 863 / 3 / 820. 
--SELECT TOP 50 * FROM dbo.retail_returns_feed ORDER BY NEWID();




-- Step 7: Extracts to save as CSV (in the csv folder)
-- 7a Sales lines   - expected rows: 29,970
-- 7b Returns feed  - expected rows: 863
-- 7c Customers     - expected rows: 2,538


--7a: Extract 1, sales lines (→ csv\sales_lines.csv)

--SELECT o.order_number, CAST(o.order_datetime AS DATE) AS order_date,
--       o.channel, o.order_status, o.payment_method,
--       s.store_code, s.store_name, s.store_format, s.city AS store_city, g.region_name,
--       c.category_name, c.department, p.sku, p.product_name, p.brand, p.list_price,
--      cu.customer_code, pr.promo_code, pr.promo_name, pr.promo_type,
--       i.quantity, i.unit_price, i.discount_amount, i.unit_cost_at_sale
--FROM dbo.retail_order_items AS i
--JOIN dbo.retail_orders AS o ON o.order_id = i.order_id
--JOIN dbo.retail_stores AS s ON s.store_id = o.store_id
--JOIN dbo.retail_regions AS g ON g.region_id = s.region_id
--JOIN dbo.retail_products AS p ON p.product_id = i.product_id
--JOIN dbo.retail_categories AS c ON c.category_id = p.category_id
--LEFT JOIN dbo.retail_customers AS cu ON cu.customer_id = o.customer_id
--LEFT JOIN dbo.retail_promotions AS pr ON pr.promotion_id = o.promotion_id
--ORDER BY o.order_number, p.sku;

--SELECT COUNT(*) FROM dbo.retail_order_items;   -- must be 29,970 (just the number of rows)
-- 7a Sales lines extract: 29,970 rows -> matches retail_order_items (cancelled kept on purpose)



--7b: Extract 2, returns feed (→ csv\returns_feed.csv)
--SELECT return_ref, order_number_text, sku_text, return_date_text,
--       quantity_text, return_reason, refund_amount_text, processed_by
--FROM dbo.retail_returns_feed;

--SELECT COUNT(*) FROM dbo.retail_returns_feed;   -- 863  (find rows)
--7b Returns feed extract: 863 rows -> matches retail_returns_feed (raw, untouched - cleaned later in Excel/Python)


--7c: Extract 3, customers (→ csv\customers.csv)
--SELECT c.customer_code, c.first_name, c.last_name, c.gender, c.birth_date, c.city,
--       g.region_name, c.signup_date, c.loyalty_tier, c.email, c.phone
--FROM dbo.retail_customers AS c
--JOIN dbo.retail_regions AS g ON g.region_id = c.region_id
--ORDER BY c.customer_code;

-- 7c Customers extract: 2,538 rows -> matches retail_customers (all columns, region name joined in)
-- Seen: mixed city case (Detroit/detroit), NULL emails, 4+ phone formats, some NULL gender/birth_date/tier
