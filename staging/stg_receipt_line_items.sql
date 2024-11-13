CREATE OR REPLACE TABLE
  `my-project.fetch_test_exercise.stg_receipt_line_items` AS
SELECT
  _id.oid AS receipt_id,
  ROW_NUMBER() OVER (PARTITION BY _id.oid ORDER BY _id.oid) AS receipt_line_rn,
  JSON_EXTRACT_SCALAR(li_data, '$.barcode') AS barcode,
  JSON_EXTRACT_SCALAR(li_data, '$.brandCode') AS brand_code,
  JSON_EXTRACT_SCALAR(li_data, '$.description') AS description,
  JSON_EXTRACT_SCALAR(li_data, '$.discountedItemPrice') AS discounted_item_price,
  JSON_EXTRACT_SCALAR(li_data, '$.finalPrice') AS final_price,
  JSON_EXTRACT_SCALAR(li_data, '$.itemPrice') AS item_price,
  JSON_EXTRACT_SCALAR(li_data, '$.originalReceiptItemText') AS original_receipt_item_text,
  JSON_EXTRACT_SCALAR(li_data, '$.partnerItemId') AS partner_item_id,
  JSON_EXTRACT_SCALAR(li_data, '$.pointsEarned') AS points_earned,
  JSON_EXTRACT_SCALAR(li_data, '$.pointsPayerId') AS points_payer_id,
  JSON_EXTRACT_SCALAR(li_data, '$.quantityPurchased') AS quantity_purchased,
  JSON_EXTRACT_SCALAR(li_data, '$.rewardsGroup') AS rewards_group,
  JSON_EXTRACT_SCALAR(li_data, '$.rewardsProductPartnerId') AS rewards_product_partner_id,
FROM
  `my-project.fetch_test_exercise.receipts`,
  UNNEST(JSON_QUERY_ARRAY(rewardsReceiptItemList)) li_data