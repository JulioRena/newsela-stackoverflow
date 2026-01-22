-- Identifies tags with the highest percentage of questions that have an accepted answer

WITH LatestYear AS (
  SELECT EXTRACT(YEAR FROM MAX(creation_date)) AS year
  FROM `bigquery-public-data.stackoverflow.posts_questions`
),
TagAcceptedAnswerRates AS (
  SELECT
    tag,
    COUNT(*) AS total_questions,
    SUM(CASE WHEN accepted_answer_id IS NOT NULL THEN 1 ELSE 0 END) AS questions_with_accepted_answers,
    -- Calculate approved answer rate as percentage
    SAFE_DIVIDE(
      SUM(CASE WHEN accepted_answer_id IS NOT NULL THEN 1 ELSE 0 END), 
      COUNT(*)
    ) AS accepted_answer_rate
  FROM (
    SELECT
      SPLIT(tags, '|') AS tag_list,
      accepted_answer_id
    FROM
      `bigquery-public-data.stackoverflow.posts_questions`,
      LatestYear
    WHERE
      EXTRACT(YEAR FROM creation_date) = LatestYear.year
      AND tags IS NOT NULL
  ), UNNEST(tag_list) AS tag
  GROUP BY tag
  HAVING total_questions >= 10  -- Minimum threshold for statistical significance
)
SELECT
  tag,
  total_questions,
  questions_with_accepted_answers,
  ROUND(accepted_answer_rate * 100, 2) AS accepted_answer_rate_percent
FROM TagAcceptedAnswerRates
ORDER BY accepted_answer_rate DESC  -- Highest approval rates first
LIMIT 20;
