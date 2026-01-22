-- Identifies tags that lead to the lowest average number of answers per question
-- Same structure as Query 1, but ordered ascending

WITH LatestYear AS (
  SELECT EXTRACT(YEAR FROM MAX(creation_date)) AS year
  FROM `bigquery-public-data.stackoverflow.posts_questions`
),
TagAnswerCounts AS (
  SELECT
    tag,
    COUNT(*) AS total_questions,
    SUM(answer_count) AS total_answers,
    AVG(answer_count) AS avg_answers_per_question
  FROM (
    SELECT
      SPLIT(tags, '|') AS tag_list,
      answer_count
    FROM
      `bigquery-public-data.stackoverflow.posts_questions`,
      LatestYear
    WHERE
      EXTRACT(YEAR FROM creation_date) = LatestYear.year
      AND tags IS NOT NULL
      AND answer_count IS NOT NULL
  ), UNNEST(tag_list) AS tag
  GROUP BY tag
  HAVING total_questions >= 10
)
SELECT
  tag,
  total_questions,
  total_answers,
  ROUND(avg_answers_per_question, 2) AS avg_answers_per_question
FROM TagAnswerCounts
ORDER BY avg_answers_per_question ASC  -- Sort ascending to show lowest first
LIMIT 20;
