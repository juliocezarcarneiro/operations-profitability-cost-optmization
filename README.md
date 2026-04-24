# operations-profitability-cost-optmization

## Validation Findings

Core structural checks passed successfully, including missing values, duplicate records, negative values, orphan keys, date/month consistency, and sales-to-cost join coverage.

Two reconciliation checks failed and were flagged for review:

- `cost_components_not_equal_total_cost`: 553 rows, high severity
- `vendor_cost_change_pct_mismatch`: 139 rows, medium severity

These issues indicate calculation inconsistencies rather than structural data failures and should be reviewed before final profitability analysis.