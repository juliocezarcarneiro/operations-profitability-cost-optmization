-- This SQL script creates a final table to store the results of the validation process. It includes a timestamp to indicate when the validation was performed
DROP TABLE IF EXISTS validation_results_final;

CREATE TABLE validation_results_final AS
SELECT
    *,
    CURRENT_TIMESTAMP AS validated_at
FROM validation_results;

-- Query to retrieve failed validation results, ordered by severity and issue count
SELECT
    test_name,
    table_name,
    issue_count,
    severity,
    status
FROM validation_results_final
WHERE status = 'FAIL'
ORDER BY severity, issue_count DESC;

-- Summary query to count the number of checks and total issues by status
SELECT
    status,
    COUNT(*) AS total_checks,
    SUM(issue_count) AS total_issues
FROM validation_results_final
GROUP BY status;