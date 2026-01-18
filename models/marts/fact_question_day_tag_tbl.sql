{{ config(
    materialized='table',
    partition_by={"field": "date", "data_type": "date"},
    cluster_by=["tag_key"]
) }}

SELECT
  PARSE_DATE('%Y%m%d', CAST(f.date_key AS STRING)) AS date,
  f.date_key,
  f.tag_key,
  f.tag_name,

  dt.tag_category,
  dt.tag_domain,

  f.questions,
  f.unique_askers,
  f.unanswered_questions,
  f.pct_unanswered,

  f.new_user_questions,
  f.new_user_unanswered_questions,
  f.pct_unanswered_new_users,

  f.avg_score,
  f.avg_views,
  f.avg_reputation_askers
FROM {{ ref('fact_question_day_tag') }} f
LEFT JOIN {{ ref('dim_tag') }} dt
  ON f.tag_key = dt.tag_key
WHERE PARSE_DATE('%Y%m%d', CAST(f.date_key AS STRING))
      >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR)
