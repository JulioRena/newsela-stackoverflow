# Stack Overflow Post Analysis (BigQuery)

This project analyzes Stack Overflow questions using the public BigQuery dataset in order to understand how tags and post-level attributes correlate with engagement and resolution quality.

All analyses were performed using SQL only, following an analytics-engineering–oriented approach focused on reproducibility, transparency, and statistical relevance.

## Dataset

### Source: bigquery-public-data.stackoverflow

#### Tables used:

* posts_questions
* posts_answers

### Exploratory Data Analysis (EDA) Observations

Before implementing the analytical queries, an exploratory analysis was conducted to validate assumptions about the dataset structure and temporal coverage.

#### 1. Data Availability and “Current Year” Definition

An initial inspection of the dataset showed that there are no records for the actual current calendar year.
As a result, all queries define the current year dynamically as the latest year available in the dataset.
This approach ensures consistency and prevents filtering on a year with incomplete or missing data.

#### 2. Tag Structure Validation
Exploratory analysis confirmed that Stack Overflow tags are stored as a pipe-delimited string (|), rather than as an array.
Based on this observation, all tag-based analyses explicitly:

* Split tags using SPLIT(tags, '|')
* Filter for single-tag questions.

This ensures that comparisons between tags (e.g., python vs dbt) are not confounded by multi-tag interactions.

#### 3. Minimum Volume Threshold for Statistical Relevance

During the analysis, it was observed that simply ordering results by metrics such as answer rate or accepted answer rate often surfaces tags or segments with very small sample sizes, leading to misleading conclusions.

To mitigate this, a minimum volume threshold was applied consistently across queries.
This ensures that reported results reflect patterns supported by a sufficient number of observations rather than noise from low-frequency cases.


## Analysis Overview
### Prompt 1 — Tag-Level Performance

* Identifies tags (and tag combinations) that lead to:

  * the highest number of answers

  * the highest accepted answer rate

* Includes both best- and worst-performing tags

* Focuses on the most recent year available in the dataset

### Prompt 2 — Python vs DBT Comparison

* Analyzes questions tagged exclusively with python or dbt

* Includes:

  * year-over-year trends (last 10 years)

  * aggregated comparison over the full period

* Metrics include:

  * question-to-answer ratio

  * accepted answer rate

### Prompt 3 — Post Quality Correlates

* Explores non-tag-related post attributes correlated with:

  * higher answer rates

  * higher accepted answer rates

* Features include:

  * question length

  * presence of code snippets

  * question score

  * time to first answer

## Technical Approach

* 100% SQL-based analysis using Google BigQuery

* Modular query structure using CTEs for clarity

* Explicit feature engineering within SQL

* Defensive querying using SAFE_DIVIDE and volume thresholds

* All queries are executable and documented with inline comments

## Notes

This analysis prioritizes interpretability and statistical reliability over overly complex modeling, aligning with best practices for analytics engineering workflows.