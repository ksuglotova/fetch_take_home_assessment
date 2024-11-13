CREATE OR REPLACE TABLE `my-project.fetch_test_exercise.stg_users` AS
SELECT
  _id.oid AS id,
  active,
  createdDate.date AS created_date,
  TIMESTAMP_MILLIS(createdDate.date) AS created_timestamp,
  lastLogin.date AS last_login_date,
  TIMESTAMP_MILLIS(lastLogin.date) AS last_login_timestamp,
  role,
  signUpSource AS signup_source,
  state
FROM
  my-project.fetch_test_exercise.users