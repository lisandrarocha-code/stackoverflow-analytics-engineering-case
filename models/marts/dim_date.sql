{{ config(materialized='view') }}

WITH bounds AS (
  SELECT
    MIN(creation_date) AS min_date,
    MAX(creation_date) AS max_date
  FROM {{ ref('stg_questions') }}
),
dates AS (
  SELECT d
  FROM bounds, UNNEST(GENERATE_DATE_ARRAY(min_date, max_date)) AS d
)
SELECT
  CAST(FORMAT_DATE('%Y%m%d', d) AS INT64) AS date_key,
  d AS date,
  DATE_TRUNC(d, WEEK(MONDAY)) AS week_start,
  DATE_TRUNC(d, MONTH) AS month_start,
  EXTRACT(YEAR FROM d) AS year,
  EXTRACT(MONTH FROM d) AS month,
  EXTRACT(WEEK(MONDAY) FROM d) AS week_of_year
FROM dates
