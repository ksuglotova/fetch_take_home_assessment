CREATE OR REPLACE TABLE
  `my-project.fetch_test_exercise.stg_receipts` AS
SELECT
  _id.oid AS id,
  bonusPointsEarned AS bonus_points_earned,
  bonusPointsEarnedReason AS bonus_points_earned_reason,
  createDate.date AS create_date,
  TIMESTAMP_MILLIS(createDate.date) AS create_timestamp,
  dateScanned.date AS scanned_date,
  TIMESTAMP_MILLIS(dateScanned.date) AS scanned_timestamp,
  finishedDate.date AS finished_date,
  TIMESTAMP_MILLIS(finishedDate.date) AS finished_timestamp,
  modifyDate.date AS modify_date,
  TIMESTAMP_MILLIS(modifyDate.date) AS modify_timestamp,
  pointsAwardedDate.date AS points_awarded_date,
  TIMESTAMP_MILLIS(pointsAwardedDate.date) AS points_awarded_timestamp,
  pointsEarned AS points_earned,
  purchaseDate.date AS purchase_date,
  TIMESTAMP_MILLIS(purchaseDate.date) AS purchase_timestamp,
  purchasedItemCount AS purchased_item_count,
  rewardsReceiptItemList AS rewards_receipt_item_list,
  rewardsReceiptStatus AS rewards_receipt_status,
  totalSpent AS total_spent,
  userId AS user_id
FROM
  my-project.fetch_test_exercise.receipts