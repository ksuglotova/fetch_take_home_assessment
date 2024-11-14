-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH
  data_tmp AS (
  SELECT
    DATE_TRUNC(DATE(scanned_timestamp), month) AS scanned_month,
    brand_name,
	COUNT(DISTINCT id) AS receipt_cnt,
    SUM(CAST(final_price AS numeric) * CAST(quantity_purchased AS numeric)) AS total_sum
  FROM
    `my-project.fetch_test_exercise.fct_receipt_line_items_brands`
  WHERE
    DATE(scanned_timestamp) >= '2021-01-01'
    AND DATE(scanned_timestamp) < '2021-03-01'
  GROUP BY
    1,
    2)
SELECT
  *,
  RANK() OVER (PARTITION BY scanned_month ORDER BY receipt_cnt DESC) AS brand_rank
FROM
  data_tmp
QUALIFY
  RANK() OVER (PARTITION BY scanned_month ORDER BY receipt_cnt DESC) <= 5