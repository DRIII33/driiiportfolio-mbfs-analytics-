-- KPI Query: Enterprise Credit Risk Exposure Profile by Region
SELECT
  dim_reg.region_name,
  fact.portfolio_status,
  COUNT(fact.contract_id) AS total_active_contracts,
  ROUND(SUM(fact.amount_financed), 2) AS regional_capital_exposure,
  ROUND(AVG(fact.credit_score), 1) AS mean_credit_rating,
  ROUND(SUM(fact.monthly_payment), 2) AS expected_monthly_inflow
FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE` fact
JOIN `driiiportfolio.mbfs_gold.DIM_REGION` dim_reg
  ON fact.region_key = dim_reg.region_key
GROUP BY 1, 2
ORDER BY regional_capital_exposure DESC;

-- KPI Query: Portfolio Performance Assessment Matrix
SELECT
  dim_veh.vehicle_name,
  COUNT(fact.contract_id) AS total_units_financed,
  ROUND(SUM(fact.amount_financed), 2) AS aggregate_financed_volume,
  ROUND(AVG(fact.amount_financed), 2) AS average_deal_size,
  SUM(CASE WHEN fact.days_past_due > 30 THEN 1 ELSE 0 END) AS units_in_delinquency
FROM `driiiportfolio.mbfs_gold.FACT_PORTFOLIO_PERFORMANCE` fact
JOIN `driiiportfolio.mbfs_gold.DIM_VEHICLE` dim_veh
  ON fact.vehicle_key = dim_veh.vehicle_key
GROUP BY 1
ORDER BY aggregate_financed_volume DESC;
