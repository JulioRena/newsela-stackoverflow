# Stack Overflow Post Analysis (BigQuery)

This project analyzes Stack Overflow questions using the public BigQuery dataset in order to understand how tags and post-level attributes correlate with engagement and resolution quality.

All analyses were performed using SQL only, following an analytics-engineering–oriented approach focused on reproducibility, transparency, and statistical relevance.

## Dataset

### Source: bigquery-public-data.stackoverflow

#### Tables used:

posts_questions

posts_answers

### Exploratory Data Analysis (EDA) Observations

Before implementing the analytical queries, an exploratory analysis was conducted to validate assumptions about the dataset structure and temporal coverage.

#### 1. Data Availability and “Current Year” Definition

An initial inspection of the dataset showed that there are no records for the actual current calendar year.
As a result, all queries define the current year dynamically as the latest year available in the dataset.
This approach ensures consistency and prevents filtering on a year with incomplete or missing data.

