{{ config(materialized='view') }}

SELECT
  id AS question_id,
  DATE(creation_date) AS creation_date,
  creation_date AS creation_ts,
  title,
  tags,
  score,
  view_count,
  answer_count,
  accepted_answer_id,
  owner_user_id
FROM `bigquery-public-data.stackoverflow.posts_questions`
WHERE tags IS NOT NULL
