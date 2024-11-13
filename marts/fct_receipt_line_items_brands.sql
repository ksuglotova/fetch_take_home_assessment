CREATE OR REPLACE TABLE
  `my-project.fetch_test_exercise.fct_receipt_line_items_brands` AS
WITH
  receipt_line_items AS (
  SELECT
    r.id,
    r.bonus_points_earned,
    r.bonus_points_earned_reason,
    r.create_date,
    r.create_timestamp,
    r.scanned_date,
    r.scanned_timestamp,
    r.finished_date,
    r.finished_timestamp,
    r.modify_date,
    r.modify_timestamp,
    r.points_awarded_date,
    r.points_awarded_timestamp,
    r.points_earned AS receipt_points_earned,
    r.purchase_date,
    r.purchase_timestamp,
    r.purchased_item_count,
    r.rewards_receipt_status,
    r.total_spent,
    r.user_id,
    li.receipt_line_rn,
    li.barcode,
    li.brand_code,
    li.description,
    li.discounted_item_price,
    li.final_price,
    li.item_price,
    li.original_receipt_item_text,
    li.partner_item_id,
    li.points_earned,
    li.points_payer_id,
    li.quantity_purchased,
    li.rewards_group,
    li.rewards_product_partner_id
  FROM
    `my-project.fetch_test_exercise.stg_receipts` r
  INNER JOIN
    `my-project.fetch_test_exercise.stg_receipt_line_items` li
  ON
    r.id = li.receipt_id
  WHERE
    li.brand_code IS NOT NULL
    OR li.barcode IS NOT NULL ),
  brands AS (
  SELECT
    *
  FROM
    `my-project.fetch_test_exercise.stg_brands` )
SELECT
  rli.*,
  bcode.name AS brand_name
FROM
  receipt_line_items rli
INNER JOIN
  brands bcode
ON
  rli.brand_code = bcode.brand_code
UNION ALL
SELECT
  rli.*,
  bbar.name AS brand_name
FROM
  receipt_line_items rli
INNER JOIN
  brands bbar
ON
  rli.barcode = bbar.barcode
WHERE
  bbar.brand_code IS null