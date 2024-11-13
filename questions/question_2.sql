WITH
  data_tmp AS (
  SELECT
    DATE_TRUNC(DATE(scanned_timestamp), month) AS scanned_month,
    brand_name,
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
  DENSE_RANK() OVER (PARTITION BY scanned_month ORDER BY total_sum DESC) AS brand_rank
FROM
  data_tmp
QUALIFY
  DENSE_RANK() OVER (PARTITION BY scanned_month ORDER BY total_sum DESC) <= 5