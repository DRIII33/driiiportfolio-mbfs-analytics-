-- DML Script: Silver data cleansing and standardization layer
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_silver.cleaned_transactions` AS
WITH deduplicated_records AS (
  SELECT
    contract_id,
    customer_id,
    vehicle_model,
    dealer_region,
    credit_score,
    amount_financed,
    monthly_payment,
    days_past_due,
    contract_date,
    ROW_NUMBER() OVER(PARTITION BY contract_id ORDER BY contract_date DESC) as record_rank
  FROM `driiiportfolio.mbfs_bronze.raw_transactions`
)
SELECT
  SAFE_CAST(contract_id AS STRING) AS contract_id,
  SAFE_CAST(customer_id AS STRING) AS customer_id,
  UPPER(TRIM(vehicle_model)) AS vehicle_model,
  UPPER(TRIM(dealer_region)) AS dealer_region,
  -- Imputing missing credit scores using the portfolio standard average (680)
  COALESCE(SAFE_CAST(credit_score AS INT64), 680) AS credit_score,
  -- Parsing formatting variations ($ sign, commas, spaces) from financial fields
  SAFE_CAST(REGEXP_REPLACE(CAST(amount_financed AS STRING), r'[$\s,USD]', '') AS FLOAT64) AS amount_financed,
  SAFE_CAST(monthly_payment AS FLOAT64) AS monthly_payment,
  COALESCE(SAFE_CAST(days_past_due AS INT64), 0) AS days_past_due,
  CAST(contract_date AS DATE) AS contract_date
FROM deduplicated_records
WHERE record_rank = 1 AND contract_id IS NOT NULL;

-- DML Script: Gold Dimension Layer - Vehicle Dimension
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_gold.DIM_VEHICLE` AS
SELECT DISTINCT
  FARM_FINGERPRINT(vehicle_model) AS vehicle_key,
  vehicle_model AS vehicle_name
FROM `driiiportfolio.mbfs_silver.cleaned_transactions`;

-- DML Script: Gold Dimension Layer - Regional Network Dimension
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_gold.DIM_REGION` AS
SELECT DISTINCT
  FARM_FINGERPRINT(dealer_region) AS region_key,
  dealer_region AS region_name
FROM `driiiportfolio.mbfs_silver.cleaned_transactions`;

-- DML Script: Gold Dimension Layer - Calendar Dimension
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_gold.DIM_CALENDAR` AS
SELECT
  date_key,
  EXTRACT(YEAR FROM date_key) AS date_year,
  EXTRACT(QUARTER FROM date_key) AS date_quarter,
  EXTRACT(MONTH FROM date_key) AS date_month,
  EXTRACT(DAY FROM date_key) AS date_day,
  EXTRACT(DAYOFWEEK FROM date_key) - 1 AS date_day_of_week, -- 0=Sunday, 1=Monday, ..., 6=Saturday
  FORMAT_DATE('%A', date_key) AS date_day_name,
  EXTRACT(WEEK FROM date_key) AS date_week_of_year,
  FORMAT_DATE('%B', date_key) AS date_month_name,
  CASE WHEN EXTRACT(DAYOFWEEK FROM date_key) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM (
  SELECT DISTINCT date_key FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE`
),
UNNEST(GENERATE_DATE_ARRAY(
  (SELECT MIN(date_key) FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE`),
  (SELECT MAX(date_key) FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE`),
  INTERVAL 1 DAY
)) AS date_key;

-- DML Script: Gold Fact Layer - Portfolio Performance Fact Table
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE` AS
SELECT
  ct.contract_id,
  ct.customer_id,
  FARM_FINGERPRINT(ct.vehicle_model) AS vehicle_key,
  FARM_FINGERPRINT(ct.dealer_region) AS region_key,
  ct.contract_date AS date_key,
  ct.credit_score,
  ct.amount_financed,
  ct.monthly_payment,
  ct.days_past_due,
  CASE
    WHEN ct.days_past_due = 0 THEN 'Current'
    WHEN ct.days_past_due <= 30 THEN 'Early Stage Delinquency'
    WHEN ct.days_past_due <= 60 THEN 'Mid Stage Delinquency'
    ELSE 'Severe Default Risk'
  END AS portfolio_status
FROM `driiiportfolio.mbfs_silver.cleaned_transactions` ct;
