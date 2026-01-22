-- Identifies tags that lead to the highest number of answers per question

WITH LatestYear AS (
  -- Get the most recent year that has data in the dataset
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
      SPLIT(tags, '|') AS tag_list,  -- Split pipe-delimited tags into array
      answer_count
    FROM
      `bigquery-public-data.stackoverflow.posts_questions`,
      LatestYear
    WHERE
      EXTRACT(YEAR FROM creation_date) = LatestYear.year
      AND tags IS NOT NULL
      AND answer_count IS NOT NULL
  ), UNNEST(tag_list) AS tag  -- Unnest array to get individual tags
  GROUP BY tag
  HAVING total_questions >= 10  -- Filter out tags with very few questions for statistical significance
)
SELECT
  tag,
  total_questions,
  total_answers,
  ROUND(avg_answers_per_question, 2) AS avg_answers_per_question
FROM TagAnswerCounts
ORDER BY total_answers DESC  -- Sort by highest average answers first
LIMIT 20;