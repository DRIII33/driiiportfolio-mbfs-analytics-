# Looker Studio Dashboard Design Strategy Specification
---
##### **Project Title:** Automated Portfolio Analytics Infrastructure Modernization
##### **Assigned Division:** Data Insights and Advanced Analytics (DIAA Team Space)
##### **Engineering Lead:** Data Analytics Engineer Candidate
##### **Data Analytics Engineer:** Daniel Rodriguez III
##### **Date:** 04 July 2026
---

## 1. Strategic Visual Framework

The automated semantic model feeds an executive interactive dashboard built in Looker Studio.

The interface provides real-time visibility into portfolio performance, operational efficiency, and data quality health metrics across all regional dealer networks.

## 2. Visual Component Specifications

## Page 1: Enterprise Portfolio Executive Overview

### Visual Asset 1: Corporate KPI Scorecard Matrix

**Functional Purpose:**  
Displays high-level portfolio metrics: Total Capital Active, Average Monthly Payment, and Weighted Average Portfolio Credit Rating.

**Calculation Formula:**

$$
\text{Total Capital Active} = \sum(\text{amount\_financed})
$$

$$
\text{Portfolio Credit Rating} = \text{AVG}(\text{credit\_score})
$$

**Business Interpretation:**  
Allows leadership to monitor total credit exposure and portfolio health at a glance.

### Visual Asset 2: Regional Risk Heat Map Component

**Functional Purpose:**  
Maps portfolio distribution and delinquency rates across regional dealer networks.

**Calculation Formula:**

$$
\text{Delinquency Concentration} =
\frac{\text{COUNT}(\text{Contracts where days\_past\_due} > 30)}
{\text{Total Active Contracts}}
$$

**Business Interpretation:**  
Helps risk teams identify and adjust underwriting criteria in underperforming regions.

## Page 2: Operational Data Quality Audit Dashboard

### Visual Asset 3: Pipeline Integrity Scorecard Matrix

**Functional Purpose:**  
Tracks data cleaning metrics, including duplicate records caught and missing values resolved.

**Calculation Formula:**

$$
\text{Duplicate Remediation} =
\text{Count\_Raw} - \text{Count\_Cleaned}
$$

**Business Interpretation:**  
Validates data pipeline stability for compliance and audit reviews.
