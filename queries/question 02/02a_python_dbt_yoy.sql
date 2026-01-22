-- Year-over-year analysis of Stack Overflow questions
-- restricted to questions with EXACTLY ONE tag: python or sql
-- Tag structure validated via exploratory analysis as pipe-delimited (|)

WITH questions AS (
  SELECT
    q.id AS question_id,
    EXTRACT(YEAR FROM q.creation_date) AS year,
    q.tags AS tag,
    q.accepted_answer_id
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  WHERE
    -- last 10 years
    EXTRACT(YEAR FROM q.creation_date) >= EXTRACT(YEAR FROM CURRENT_DATE()) - 10
    -- restrict to single-tag questions
    AND ARRAY_LENGTH(SPLIT(q.tags, '|')) = 1
    -- focus on python vs sql
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
  q.year,
  q.tag,
  COUNT(DISTINCT q.question_id) AS question_count,
  SUM(IFNULL(a.answer_count, 0)) AS total_answers,
  SAFE_DIVIDE(
    SUM(IFNULL(a.answer_count, 0)),
    COUNT(DISTINCT q.question_id)
  ) AS question_to_answer_ratio,
  AVG(
    CASE
      WHEN q.accepted_answer_id IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS accepted_answer_rate
FROM questions q
LEFT JOIN answers a
  ON q.question_id = a.question_id
GROUP BY q.year, q.tag
ORDER BY  q.tag, q.year;