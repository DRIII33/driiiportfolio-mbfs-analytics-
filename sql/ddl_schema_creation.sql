-- DDL Script: Initializing the decoupled relational environment layers inside BigQuery
CREATE SCHEMA IF NOT EXISTS `driiiportfolio.mbfs_bronze` OPTIONS(location="us");
CREATE SCHEMA IF NOT EXISTS `driiiportfolio.mbfs_silver` OPTIONS(location="us");
CREATE SCHEMA IF NOT EXISTS `driiiportfolio.mbfs_gold` OPTIONS(location="us");

-- Creating the Raw Landing Table Structure (Bronze Layer)
CREATE OR REPLACE TABLE `driiiportfolio.mbfs_bronze.raw_transactions` (
    contract_id STRING,
    customer_id STRING,
    vehicle_model STRING,
    dealer_region STRING,
    credit_score FLOAT64, -- Injected Nulls require relaxed initial typings
    amount_financed STRING, -- Injected string characters replicate manual entry formatting variations
    monthly_payment FLOAT64,
    days_past_due INT64,
    contract_date TIMESTAMP
);
