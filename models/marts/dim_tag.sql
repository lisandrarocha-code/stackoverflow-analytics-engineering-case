{{ config(materialized='view') }}

WITH tags AS (
  SELECT DISTINCT tag
  FROM {{ ref('stg_questions') }},
  UNNEST(SPLIT(tags, '|')) AS tag
)
SELECT
  TO_HEX(MD5(tag)) AS tag_key,
  tag AS tag_name,

  CASE
    WHEN tag IN ('python','java','c#','javascript','go','rust','php','ruby','scala') THEN 'language'
    WHEN tag IN ('reactjs','angular','vue.js','django','flask','spring','laravel') THEN 'framework'
    WHEN tag IN ('mysql','postgresql','sql-server','oracle','mongodb','bigquery') THEN 'database'
    WHEN tag IN ('docker','kubernetes','git','jenkins','terraform') THEN 'tool'
    ELSE 'other'
  END AS tag_category,

  CASE
    WHEN tag IN ('reactjs','angular','vue.js','javascript','css','html') THEN 'frontend'
    WHEN tag IN ('python','java','c#','spring','django','flask') THEN 'backend'
    WHEN tag IN ('pandas','numpy','scikit-learn','bigquery') THEN 'data'
    WHEN tag IN ('docker','kubernetes','terraform') THEN 'devops'
    ELSE 'other'
  END AS tag_domain
FROM tags
