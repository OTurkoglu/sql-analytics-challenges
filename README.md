cat > README.md << 'EOF'
# SQL Analytics Challenges

A collection of SQL challenges demonstrating analytical patterns commonly used in data engineering and analytics engineering roles. Each challenge includes comments explaining the concept, the question being solved, and the approach taken.

## Structure

window_functions/    # ROW_NUMBER, RANK, LAG, running totals
CTEs/                # Multi-step logic, segmentation, filtering
aggregations/        # GROUP BY, HAVING, percentage calculations
query_optimisation/  # Performance patterns, early filtering, pre-aggregation

## Challenges

### Window Functions
| File | Concept |
|------|---------|
| 01_running_total.sql | SUM() OVER, cumulative revenue by order status |
| 02_rank_customers_by_revenue.sql | RANK vs DENSE_RANK vs ROW_NUMBER |
| 03_month_over_month_growth.sql | LAG(), MoM revenue growth percentage |

### CTEs
| File | Concept |
|------|---------|
| 01_customer_segmentation.sql | Multi-CTE segmentation, CASE WHEN, COALESCE |
| 02_repeat_customers.sql | Customer loyalty classification, aggregation filtering |

### Aggregations
| File | Concept |
|------|---------|
| 01_revenue_by_status.sql | GROUP BY, percentage of total, CROSS JOIN |
| 02_cohort_retention.sql | Cohort retention analysis, acquisition cohorts, month-over-month retention rate |

### Query Optimisation
| File | Concept |
|------|---------|
| 01_optimising_joins.sql | Filter early, pre-aggregate before joins, avoid functions on columns |

### Data Quality
| File | Concept |
|------|---------|
| 01_detect_data_quality_issues.sql | Duplicate detection, orphan records, null analysis, late arriving data, revenue anomalies |

## Principles Applied

- Filter as early as possible to reduce rows before joins
- Pre-aggregate in CTEs before joining to larger tables
- Avoid applying functions to columns in WHERE clauses — use range filters instead
- Use COALESCE to handle nulls from LEFT JOINs explicitly
- Use NULLIF to avoid division by zero in percentage calculations
- Comment every challenge with concept, question and approach
- Data quality checks reflect patterns automated by observability tools like Monte Carlo in production

## Tech Stack

- SQL dialect: BigQuery / PostgreSQL compatible
- Dataset: Jaffle Shop Classic by dbt Labs
- See TOOLS.md for full modern data stack reference

## About

Built by Ozleyis Turkoglu — Analytics Engineering Lead with 10+ years building data platforms at Vodafone and Virgin Media O2.