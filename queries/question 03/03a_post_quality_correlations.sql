-- Identify non-tag-related post qualities correlated with
-- higher answer rates and accepted answer rates

WITH questions AS (
  SELECT
    q.id AS question_id,
    q.creation_date,
    q.score,
    q.accepted_answer_id,
    LENGTH(q.body) AS body_length,
    LENGTH(q.title) AS title_length,
    CASE
      WHEN q.body LIKE '%<code>%' THEN 1
      ELSE 0
    END AS has_code
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  WHERE
    EXTRACT(YEAR FROM q.creation_date) >= EXTRACT(YEAR FROM CURRENT_DATE()) - 10
),

answers AS (
  SELECT
    parent_id AS question_id,
    COUNT(*) AS answer_count,
    MIN(creation_date) AS first_answer_date
  FROM `bigquery-public-data.stackoverflow.posts_answers`
  GROUP BY parent_id
),

features AS (
  SELECT
    q.question_id,
    q.score,
    q.body_length,
    q.title_length,
    q.has_code,
    IFNULL(a.answer_count, 0) AS answer_count,
    CASE
      WHEN q.accepted_answer_id IS NOT NULL THEN 1
      ELSE 0
    END AS has_accepted_answer,
    DATE_DIFF(a.first_answer_date, q.creation_date, HOUR) AS hours_to_first_answer
  FROM questions q
  LEFT JOIN answers a
    ON q.question_id = a.question_id
)

SELECT
  -- Binned body length
  CASE
    WHEN body_length < 500 THEN 'short'
    WHEN body_length BETWEEN 500 AND 1500 THEN 'medium'
    ELSE 'long'
  END AS body_length_bucket,

  has_code,

  COUNT(*) AS question_count,
  AVG(answer_count) AS avg_answers,
  AVG(has_accepted_answer) AS accepted_answer_rate,
  AVG(hours_to_first_answer) AS avg_hours_to_first_answer
FROM features
GROUP BY body_length_bucket, has_code
ORDER BY body_length_bucket, has_code;