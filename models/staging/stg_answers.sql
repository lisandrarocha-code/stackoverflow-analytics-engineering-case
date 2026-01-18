{{ config(materialized='view') }}

SELECT
  id AS answer_id,
  parent_id AS question_id,
  DATE(creation_date) AS creation_date,
  creation_date AS creation_ts,
  score
FROM `bigquery-public-data.stackoverflow.posts_answers`
