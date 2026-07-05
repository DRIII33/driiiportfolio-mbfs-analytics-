import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Set random seed for deterministic generation matching MBFS requirements
np.random.seed(42)
num_records = 5000

# Generate base dimension profiles
customer_ids = [f"CUST-{str(i).zfill(5)}" for i in range(1, 1001)]
vehicle_models = ["C-Class Sedan", "E-Class Sedan", "S-Class Luxury", "GLE SUV", "GLS Luxury SUV", "EQE Electric"]
dealer_regions = ["Northeast", "Southeast", "Midwest", "Southwest", "Pacific"]

# Generate base structural fields
data = {
    "contract_id": [f"CON-{str(i).zfill(6)}" for i in range(1, num_records + 1)],
    "customer_id": np.random.choice(customer_ids, num_records),
    "vehicle_model": np.random.choice(vehicle_models, num_records),
    "dealer_region": np.random.choice(dealer_regions, num_records),
    "credit_score": np.random.randint(580, 850, size=num_records),
    "amount_financed": np.round(np.random.uniform(35000, 120000, size=num_records), 2),
    "monthly_payment": np.round(np.random.uniform(500, 1800, size=num_records), 2),
    "days_past_due": np.random.choice([0, 15, 30, 45, 60, 90], num_records, p=[0.85, 0.08, 0.04, 0.015, 0.01, 0.005]),
    "contract_date": [datetime(2024, 1, 1) + timedelta(days=int(np.random.randint(0, 730))) for _ in range(num_records)]
}

df = pd.DataFrame(data)

# Inject Data Quality and Compliance Anomalies (The structural reason for hiring the Analytics Engineer)
# 1. Completeness Issue: Null value injections in critical credit risk assessment fields
df.loc[df.sample(frac=0.045).index, "credit_score"] = np.nan

# 2. Validity Issue: Unmanaged string characters in currency fields replicating historical Excel macro issues
df["amount_financed"] = df["amount_financed"].astype(object)
bad_finance_idx = df.sample(frac=0.035).index
df.loc[bad_finance_idx, "amount_financed"] = df.loc[bad_finance_idx, "amount_financed"].apply(lambda x: f"${x:,.2f} USD")

# 3. Uniqueness Issue: Direct primary key duplication replicating unmanaged EUC pipeline collisions
duplicate_rows = df.sample(n=120, replace=False).copy()
df = pd.concat([df, duplicate_rows], ignore_index=True)

# Save generated baseline file structure
df.to_csv("mbfs_raw_portfolio_data.csv", index=False)
print(f"Generated {len(df)} realistic records containing structural DQA data quality exceptions.")
