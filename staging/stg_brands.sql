CREATE OR REPLACE TABLE
  `my-project.fetch_test_exercise.stg_brands` AS
SELECT
  _id.oid AS id,
  name,
  barcode,
  category,
  categoryCode AS category_code,
  cpg.id.oid AS cpg_id,
  cpg.ref AS cpg_ref,
  topBrand AS top_brand,
  brandCode AS brand_code
FROM
  my-project.fetch_test_exercise.brands