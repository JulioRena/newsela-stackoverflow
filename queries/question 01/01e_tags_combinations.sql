-- Identifies pairs of tags that lead to the highest average number of answers per question


WITH LatestYear AS (
  SELECT EXTRACT(YEAR FROM MAX(creation_date)) AS year
  FROM `bigquery-public-data.stackoverflow.posts_questions`
),
TagPairs AS (
  -- Sort tags alphabetically to normalize tag order (python|django = django|python)
  SELECT
    ARRAY(SELECT tag FROM UNNEST(SPLIT(tags, '|')) AS tag ORDER BY tag) AS sorted_tags,
    answer_count
  FROM
    `bigquery-public-data.stackoverflow.posts_questions`,
    LatestYear
  WHERE
    EXTRACT(YEAR FROM creation_date) = LatestYear.year
    AND tags IS NOT NULL
    AND answer_count IS NOT NULL
    AND ARRAY_LENGTH(SPLIT(tags, '|')) >= 2  -- Only questions with 2+ tags
),
TagCombinations AS (
  -- Generate all unique pairs from sorted tag arrays
  SELECT
    sorted_tags[OFFSET(o1)] AS tag1,
    sorted_tags[OFFSET(o2)] AS tag2,
    answer_count
  FROM TagPairs,
  UNNEST(GENERATE_ARRAY(0, ARRAY_LENGTH(sorted_tags) - 1)) AS o1,
  UNNEST(GENERATE_ARRAY(0, ARRAY_LENGTH(sorted_tags) - 1)) AS o2
  WHERE o1 < o2  -- Ensure unique pairs (avoid duplicates and self-pairs)
)
SELECT
  CONCAT(tag1, ' | ', tag2) AS tag_combination,
  COUNT(*) AS total_questions,
  SUM(answer_count) AS total_answers,
  ROUND(AVG(answer_count), 2) AS avg_answers_per_question
FROM TagCombinations
GROUP BY tag1, tag2
HAVING COUNT(*) >= 5  -- Minimum threshold for tag combinations
ORDER BY avg_answers_per_question DESC  -- Highest performing combinations first
LIMIT 20;