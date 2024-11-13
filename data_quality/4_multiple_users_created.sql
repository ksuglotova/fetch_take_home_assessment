select
  created_timestamp,
  count(*) as user_count
from `my-project.fetch_test_exercise.stg_users`
group by 1
order by 2 desc
limit 10