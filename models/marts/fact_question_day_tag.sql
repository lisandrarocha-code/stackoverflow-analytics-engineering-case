{{ config(materialized='view') }}

WITH base AS (
  SELECT
    q.question_id,
    q.creation_date AS question_date,
    q.owner_user_id AS user_id,
    q.answer_count,
    q.score,
    q.view_count,
    tag
  FROM {{ ref('stg_questions') }} q,
  UNNEST(SPLIT(q.tags, '|')) AS tag
  WHERE q.owner_user_id IS NOT NULL
),
enriched AS (
  SELECT
    b.*,
    u.user_creation_date,
    DATE_DIFF(b.question_date, u.user_creation_date, DAY) AS account_age_days,
    u.reputation
  FROM base b
  LEFT JOIN {{ ref('dim_user') }} u
    ON b.user_id = u.user_id
)
SELECT
  CAST(FORMAT_DATE('%Y%m%d', question_date) AS INT64) AS date_key,
  TO_HEX(MD5(tag)) AS tag_key,
  tag AS tag_name,

  COUNT(*) AS questions,
  COUNT(DISTINCT user_id) AS unique_askers,

  SUM(CASE WHEN answer_count = 0 THEN 1 ELSE 0 END) AS unanswered_questions,
  SAFE_DIVIDE(SUM(CASE WHEN answer_count = 0 THEN 1 ELSE 0 END), COUNT(*)) AS pct_unanswered,

  SUM(CASE WHEN account_age_days <= 30 THEN 1 ELSE 0 END) AS new_user_questions,
  SUM(CASE WHEN account_age_days <= 30 AND answer_count = 0 THEN 1 ELSE 0 END) AS new_user_unanswered_questions,
  SAFE_DIVIDE(
    SUM(CASE WHEN account_age_days <= 30 AND answer_count = 0 THEN 1 ELSE 0 END),
    NULLIF(SUM(CASE WHEN account_age_days <= 30 THEN 1 ELSE 0 END), 0)
  ) AS pct_unanswered_new_users,

  AVG(score) AS avg_score,
  AVG(view_count) AS avg_views,
  AVG(reputation) AS avg_reputation_askers
FROM enriched
GROUP BY date_key, tag_key, tag_name
