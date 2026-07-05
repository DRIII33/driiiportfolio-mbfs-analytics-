-- DQA Audit Query: Validating primary key uniqueness across the data lifecycle
SELECT
  'Bronze Stage Raw' AS pipeline_tier,
  COUNT(contract_id) - COUNT(DISTINCT contract_id) AS duplicate_count
FROM `driiiportfolio.mbfs_bronze.raw_transactions`
UNION ALL
SELECT
  'Gold Stage Production' AS pipeline_tier,
  COUNT(contract_id) - COUNT(DISTINCT contract_id) AS duplicate_count
FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE`;

-- DQA Audit Query: Checking for completeness issues in critical credit risk fields
SELECT
  COUNT(*) AS total_processed_records,
  SUM(CASE WHEN credit_score IS NULL THEN 1 ELSE 0 END) AS null_scores_bronze
FROM `driiiportfolio.mbfs_bronze.raw_transactions`;
