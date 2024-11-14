/*
For the questions related to brands, current month is set to February 2021 because of no purchase with brands in March 2021.
*/
-- What are the top 5 brands by receipts scanned for most recent month?

SELECT
  brand_name,
  COUNT(DISTINCT id) AS receipt_cnt,
  SUM(CAST(final_price AS numeric) * CAST(quantity_purchased AS numeric)) AS total_sum
FROM
  `my-project.fetch_test_exercise.fct_receipt_line_items_brands`
WHERE
  DATE(scanned_timestamp) >= '2021-02-01'
  AND DATE(scanned_timestamp) < '2021-03-01'
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  5