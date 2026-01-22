
WITH questions AS (
  SELECT
    q.id AS question_id,
    q.tags AS tag,
    q.accepted_answer_id
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  WHERE
    -- define analysis window (last 10 years)
    EXTRACT(YEAR FROM q.creation_date) >= EXTRACT(YEAR FROM CURRENT_DATE()) - 10
    -- restrict to questions with exactly one tag
    AND ARRAY_LENGTH(SPLIT(q.tags, '|')) = 1
    -- python vs dbt only
    AND q.tags IN ('python', 'dbt')
),

answers AS (
  SELECT
    parent_id AS question_id,
    COUNT(*) AS answer_count
  FROM `bigquery-public-data.stackoverflow.posts_answers`
  GROUP BY parent_id
)

SELECT
  q.tag,
  COUNT(DISTINCT q.question_id) AS question_count,
  SUM(IFNULL(a.answer_count, 0)) AS total_answers,
  SAFE_DIVIDE(
    SUM(IFNULL(a.answer_count, 0)),
    COUNT(DISTINCT q.question_id)
  ) AS avg_answers_per_question,
  AVG(
    CASE
      WHEN q.accepted_answer_id IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS accepted_answer_rate
FROM questions q
LEFT JOIN answers a
  ON q.question_id = a.question_id
GROUP BY q.tag
ORDER BY q.tag;