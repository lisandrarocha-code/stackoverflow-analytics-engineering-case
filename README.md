# Stack Overflow – Analytics Engineering Case

## Project overview
This project was developed as part of an Analytics Engineering use case, using the public Stack Overflow dataset available in BigQuery.  
The main objective is to identify popular and trending topics (tags) with a high volume of unanswered questions, with a special focus on new users, in order to surface potential gaps in community support.

The solution covers the full analytics workflow:
- data modeling in BigQuery using dbt
- dimensional modeling (star schema)
- performance optimization (partitioning & clustering)
- data quality tests
- a BI-ready table consumed by a dashboard



## Data sources
- **Dataset**: `bigquery-public-data.stackoverflow`
- **Main tables used**:
  - `posts_questions`
  - `posts_answers`
  - `users`

All transformations are performed in BigQuery via dbt.



## Data model
The model follows a star schema, designed to support analytical queries efficiently.

### Dimensions
- **dim_date**  
  Calendar dimension derived from question creation dates.

- **dim_tag**  
  One row per Stack Overflow tag, enriched with:
  - `tag_category` (e.g. language, framework, database)
  - `tag_domain` (frontend, backend, data, devops, other)

- **dim_user**  
  User metadata used for segmentation (e.g. new users vs experienced users).

### Fact
- **fact_question_day_tag_tbl**  
  Grain: **one row per day, per tag**  
  This is the final, BI-ready table used by the dashboard.

Key characteristics:
- Partitioned by `date`
- Clustered by `tag_key`
- Limited to the last 5 years to balance history and performance



## Metrics & logic
The fact table includes, among others:

- Total number of questions
- Number of unanswered questions
- Percentage of unanswered questions
- Number of unique askers
- Metrics segmented for new users (accounts ≤ 30 days old)
- Average score, views, and asker reputation

This allows answering questions such as:
- Which tags are popular but underserved?
- Are new users more likely to receive no answers?
- Which domains or categories have higher unanswered rates?



## dbt project structure
models/
staging/
stg_questions.sql
stg_answers.sql

marts/
dim_date.sql
dim_tag.sql
dim_user.sql
fact_question_day_tag.sql
fact_question_day_tag_tbl.sql

schema.yml

dbt_project.yml
README.md


### Staging
- Light transformations
- Renaming and basic type casting
- No business logic

### Marts
- Dimensional modeling
- Business logic and aggregations
- Final table optimized for BI consumption



## Data quality tests
Basic dbt tests are implemented to ensure data reliability:
- Primary keys are `not_null` and `unique` in dimension tables
- Mandatory fields in the fact table are `not_null`

Tests can be run with:
```bash
dbt test

To run the project: dbt run
The final table will be created in BigQuery and can be directly connected to a BI tool.

## Dashboard

The final table fact_question_day_tag_tbl is consumed by a dashboard (Looker Studio), which includes:

- Overview KPIs (questions, unanswered rate)
- Top tags with the highest number of unanswered questions
- Trend analysis over time
- Segmentation by tag category, domain, and new users

Dashboard link: https://lookerstudio.google.com/u/0/reporting/cafe30da-2393-4476-90ec-0be932830fe4/page/p_hhj5s7z2zd

## Assumptions & trade-offs

- Tag categorization is rule-based; in a production setting, this could be replaced by ML-based clustering or NLP on question titles.
- User segmentation is simplified to “new users ≤ 30 days”.
- Data volume is limited to the last 5 years for performance reasons.

## Possible next steps

- Apply NLP techniques to question titles to identify emerging topics beyond tags
- Build incremental models for large-scale production usage
- Introduce freshness and volume-based alerts for unanswered questions
- Add semantic layer / metrics definitions for BI self-service

