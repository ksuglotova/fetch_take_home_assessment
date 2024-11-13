-- Total number of receipt line item entries with brand_code or barcode
select count(*)
from `my-project.fetch_test_exercise.stg_receipt_line_items`
where brand_code is not null or barcode is not null

-- Receipt line item entries without brand_code match
with receipt_line_items as (
  select 
    r.*, li.*
  from `my-project.fetch_test_exercise.stg_receipts` r
  inner join `my-project.fetch_test_exercise.stg_receipt_line_items` li
    on r.id = li.receipt_id
  where li.brand_code is not null 
    or li.barcode is not null
),
brands as (
  select * from `my-project.fetch_test_exercise.stg_brands`
)
select 
  count(rli.receipt_id || rli.receipt_line_rn)
from receipt_line_items rli
where not exists (select 1 from brands b
                  where b.brand_code = rli.brand_code)


-- Receipt line item entries without barcode match
with receipt_line_items as (
  select 
    r.*, li.*
  from `my-project.fetch_test_exercise.stg_receipts` r
  inner join `my-project.fetch_test_exercise.stg_receipt_line_items` li
    on r.id = li.receipt_id
  where li.brand_code is not null 
    or li.barcode is not null
),
brands as (
  select * from `my-project.fetch_test_exercise.stg_brands`
)
select 
  count(rli.receipt_id || rli.receipt_line_rn)
from receipt_line_items rli
where not exists (select 1 from brands b
                  where b.barcode = rli.barcode)

-- Receipt line items that could be updated with brand code using brand code from the product description, 
-- example with KRAFT brand code

select rli.brand_code, rli.barcode, rli.description
from `my-project.fetch_test_exercise.stg_receipt_line_items` rli
where (rli.brand_code is null)
  and contains_substr(rli.description, 'kraft')
group by 1, 2, 3				  