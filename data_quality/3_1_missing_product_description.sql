select
  description,
  barcode,
  brand_code,
  count(receipt_id || receipt_line_rn) as line_item_count
from `my-project.fetch_test_exercise.stg_receipt_line_items`
where description is null
group by 1, 2, 3