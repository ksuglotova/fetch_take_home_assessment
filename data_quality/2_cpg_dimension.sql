select 
  cpg_ref,
  count(cpg_id) as cpg_id_count
from `my-project.fetch_test_exercise.stg_brands`
group by 1