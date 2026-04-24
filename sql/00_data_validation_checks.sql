-- ============================================
-- File: 00_data_validation_checks.sql
-- Purpose: Data validation checks for Phase 5
-- Project: Operations Profitability & Cost Optimization Analysis
-- ============================================

DROP TABLE IF EXISTS validation_results;

CREATE TABLE validation_results (
    test_name VARCHAR(150),
    table_name VARCHAR(100),
    issue_count INT,
    severity VARCHAR(20),
    status VARCHAR(20),
    action_taken VARCHAR(255)
);

-- ============================================
-- 1. Missing values
-- ============================================

INSERT INTO validation_results
SELECT 'missing_product_id', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate null product_id and correct source/export logic'
FROM sales
WHERE product_id IS NULL;

INSERT INTO validation_results
SELECT 'missing_location_id', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate null location_id and correct source/export logic'
FROM sales
WHERE location_id IS NULL;

INSERT INTO validation_results
SELECT 'missing_transaction_date', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Backfill or remove rows with missing transaction_date'
FROM sales
WHERE transaction_date IS NULL;

INSERT INTO validation_results
SELECT 'missing_revenue', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate null revenue rows before analysis'
FROM sales
WHERE revenue IS NULL;

INSERT INTO validation_results
SELECT 'missing_cogs', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate null cogs rows before profitability analysis'
FROM costs
WHERE cogs IS NULL;

INSERT INTO validation_results
SELECT 'missing_waste_cost', 'waste', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review missing waste_cost values and recalculate if needed'
FROM waste
WHERE waste_cost IS NULL;

INSERT INTO validation_results
SELECT 'missing_category', 'products', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Standardize and backfill category values'
FROM products
WHERE category IS NULL;

-- ============================================
-- 2. Duplicate rows
-- ============================================

INSERT INTO validation_results
SELECT 'duplicate_sales_rows', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Deduplicate repeated sales records'
FROM (
    SELECT transaction_date, month, location_id, product_id, units_sold, revenue, COUNT(*)
    FROM sales
    GROUP BY transaction_date, month, location_id, product_id, units_sold, revenue
    HAVING COUNT(*) > 1
) d;

INSERT INTO validation_results
SELECT 'duplicate_costs_rows', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Deduplicate costs by month-location-product'
FROM (
    SELECT month, location_id, product_id, COUNT(*)
    FROM costs
    GROUP BY month, location_id, product_id
    HAVING COUNT(*) > 1
) d;

INSERT INTO validation_results
SELECT 'duplicate_waste_rows', 'waste', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review repeated waste logs'
FROM (
    SELECT month, location_id, product_id, waste_reason, COUNT(*)
    FROM waste
    GROUP BY month, location_id, product_id, waste_reason
    HAVING COUNT(*) > 1
) d;

INSERT INTO validation_results
SELECT 'duplicate_vendor_price_rows', 'vendor_prices', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review repeated vendor price records'
FROM (
    SELECT month, vendor_id, product_id, COUNT(*)
    FROM vendor_prices
    GROUP BY month, vendor_id, product_id
    HAVING COUNT(*) > 1
) d;

-- ============================================
-- 3. Negative / invalid numeric values
-- ============================================

INSERT INTO validation_results
SELECT 'negative_revenue', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate refund logic or invalid sales rows'
FROM sales
WHERE revenue < 0;

INSERT INTO validation_results
SELECT 'negative_units_sold', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid sales quantities'
FROM sales
WHERE units_sold < 0;

INSERT INTO validation_results
SELECT 'negative_discount_amount', 'sales', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review discount sign logic'
FROM sales
WHERE discount_amount < 0;

INSERT INTO validation_results
SELECT 'negative_cogs', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid cost records'
FROM costs
WHERE cogs < 0;

INSERT INTO validation_results
SELECT 'negative_total_cost', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid total_cost records'
FROM costs
WHERE total_cost < 0;

INSERT INTO validation_results
SELECT 'negative_waste_units', 'waste', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid waste quantities'
FROM waste
WHERE waste_units < 0;

INSERT INTO validation_results
SELECT 'negative_waste_cost', 'waste', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid waste cost values'
FROM waste
WHERE waste_cost < 0;

INSERT INTO validation_results
SELECT 'negative_vendor_cost', 'vendor_prices', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Investigate invalid vendor costs'
FROM vendor_prices
WHERE actual_unit_cost < 0
   OR prior_unit_cost < 0;

-- ============================================
-- 4. Invalid dates / date logic
-- Assumes month is stored like 'YYYY-MM'
-- ============================================

INSERT INTO validation_results
SELECT 'transaction_date_after_month', 'sales', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Check month alignment against transaction_date'
FROM sales
WHERE transaction_date IS NOT NULL
  AND month IS NOT NULL
  AND DATE_TRUNC('month', transaction_date)::date <> TO_DATE(month, 'YYYY-MM');

INSERT INTO validation_results
SELECT 'sales_month_out_of_scope', 'sales', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Restrict analysis window to Jan 2025 - Jun 2025'
FROM sales
WHERE month IS NOT NULL
  AND (
      TO_DATE(month, 'YYYY-MM') < DATE '2025-01-01'
      OR TO_DATE(month, 'YYYY-MM') > DATE '2025-06-01'
  );

INSERT INTO validation_results
SELECT 'costs_month_out_of_scope', 'costs', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Restrict analysis window to Jan 2025 - Jun 2025'
FROM costs
WHERE month IS NOT NULL
  AND (
      TO_DATE(month, 'YYYY-MM') < DATE '2025-01-01'
      OR TO_DATE(month, 'YYYY-MM') > DATE '2025-06-01'
  );

INSERT INTO validation_results
SELECT 'waste_month_out_of_scope', 'waste', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Restrict analysis window to Jan 2025 - Jun 2025'
FROM waste
WHERE month IS NOT NULL
  AND (
      TO_DATE(month, 'YYYY-MM') < DATE '2025-01-01'
      OR TO_DATE(month, 'YYYY-MM') > DATE '2025-06-01'
  );

INSERT INTO validation_results
SELECT 'vendor_prices_month_out_of_scope', 'vendor_prices', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Restrict analysis window to Jan 2025 - Jun 2025'
FROM vendor_prices
WHERE month IS NOT NULL
  AND (
      TO_DATE(month, 'YYYY-MM') < DATE '2025-01-01'
      OR TO_DATE(month, 'YYYY-MM') > DATE '2025-06-01'
  );

-- ============================================
-- 5. Orphan keys
-- ============================================

INSERT INTO validation_results
SELECT 'orphan_product_id_in_sales', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing product records or remove invalid sales rows'
FROM sales s
LEFT JOIN products p
    ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_location_id_in_sales', 'sales', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing location records or remove invalid sales rows'
FROM sales s
LEFT JOIN locations l
    ON s.location_id = l.location_id
WHERE l.location_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_product_id_in_costs', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing product records or remove invalid cost rows'
FROM costs c
LEFT JOIN products p
    ON c.product_id = p.product_id
WHERE p.product_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_location_id_in_costs', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing location records or remove invalid cost rows'
FROM costs c
LEFT JOIN locations l
    ON c.location_id = l.location_id
WHERE l.location_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_product_id_in_waste', 'waste', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing product records or remove invalid waste rows'
FROM waste w
LEFT JOIN products p
    ON w.product_id = p.product_id
WHERE p.product_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_location_id_in_waste', 'waste', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing location records or remove invalid waste rows'
FROM waste w
LEFT JOIN locations l
    ON w.location_id = l.location_id
WHERE l.location_id IS NULL;

INSERT INTO validation_results
SELECT 'orphan_product_id_in_vendor_prices', 'vendor_prices', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Add missing product records or remove invalid vendor rows'
FROM vendor_prices vp
LEFT JOIN products p
    ON vp.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================
-- 6. Inconsistent category names
-- ============================================

INSERT INTO validation_results
SELECT 'inconsistent_category_format', 'products', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Standardize category to lowercase and trimmed naming'
FROM products
WHERE category <> LOWER(TRIM(category));

-- ============================================
-- 7. Reconciliation checks
-- ============================================

INSERT INTO validation_results
SELECT 'cost_components_not_equal_total_cost', 'costs', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Recalculate total_cost from cost components'
FROM costs
WHERE ROUND(COALESCE(cogs,0) + COALESCE(labor_cost,0) + COALESCE(packaging_cost,0) + COALESCE(overhead_allocated,0), 2)
   <> ROUND(COALESCE(total_cost,0), 2);

INSERT INTO validation_results
SELECT 'sales_revenue_less_than_discount', 'sales', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review rows where discount exceeds revenue'
FROM sales
WHERE discount_amount > revenue;

INSERT INTO validation_results
SELECT 'vendor_cost_change_pct_mismatch', 'vendor_prices', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Recalculate cost_change_pct from actual and prior unit cost'
FROM vendor_prices
WHERE prior_unit_cost IS NOT NULL
  AND prior_unit_cost <> 0
  AND ROUND((actual_unit_cost - prior_unit_cost) / prior_unit_cost, 4) <> ROUND(cost_change_pct, 4);

-- ============================================
-- 8. Join coverage checks
-- Uses converted month values to avoid text/date issues
-- ============================================

INSERT INTO validation_results
SELECT 'sales_without_matching_costs', 'sales_costs_join', COUNT(*), 'high',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review missing costs for sold items'
FROM sales s
LEFT JOIN costs c
    ON TO_DATE(s.month, 'YYYY-MM') = TO_DATE(c.month, 'YYYY-MM')
   AND s.location_id = c.location_id
   AND s.product_id = c.product_id
WHERE c.product_id IS NULL;

INSERT INTO validation_results
SELECT 'costs_without_matching_sales', 'sales_costs_join', COUNT(*), 'medium',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       'Review cost rows with no matching sales'
FROM costs c
LEFT JOIN sales s
    ON TO_DATE(s.month, 'YYYY-MM') = TO_DATE(c.month, 'YYYY-MM')
   AND s.location_id = c.location_id
   AND s.product_id = c.product_id
WHERE s.product_id IS NULL;

-- ============================================
-- Final output
-- ============================================

SELECT *
FROM validation_results
ORDER BY
    CASE severity
        WHEN 'high' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'low' THEN 3
        ELSE 4
    END,
    issue_count DESC,
    test_name;