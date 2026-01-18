{{ config(materialized='view') }}

SELECT
  id AS user_id,
  TO_HEX(MD5(CAST(id AS STRING))) AS user_key,
  DATE(creation_date) AS user_creation_date,
  reputation
FROM `bigquery-public-data.stackoverflow.users`
