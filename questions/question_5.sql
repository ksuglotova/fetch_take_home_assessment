WITH
  user_data AS (
  SELECT
    id
  FROM
    `my-project.fetch_test_exercise.stg_users`
  WHERE
    DATE(created_timestamp) <= DATE_SUB(date '2021-01-01', INTERVAL 6 month) )
SELECT
  brand_name,
  SUM(CAST(final_price AS numeric) * CAST(quantity_purchased AS numeric)) AS total_sum
FROM
  `my-project.fetch_test_exercise.fct_receipt_line_items_brands` rli
INNER JOIN
  user_data u
ON
  rli.user_id = u.id
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  1