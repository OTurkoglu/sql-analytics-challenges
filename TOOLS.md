# Modern Data Stack — Tools & Technologies

A reference of the modern data stack tools and technologies used or referenced
in this project, mapped to their purpose in a production analytics engineering environment.

## Transformation & Modelling
| Tool | Purpose |
|------|---------|
| dbt Core | Data transformation, modelling, testing and documentation |
| dbt-utils | Extended dbt macros and generic tests |
| SQL | Primary language for all data transformation logic |

## Warehouse & Cloud
| Tool | Purpose |
|------|---------|
| Google BigQuery | Cloud data warehouse — primary compute and storage layer |
| Google Cloud Platform (GCP) | Cloud infrastructure |

## Data Quality & Observability
| Tool | Purpose |
|------|---------|
| dbt tests | Built-in schema tests — unique, not_null, accepted_values, relationships |
| Custom generic tests | Reusable SQL-based tests for business-specific data quality rules |
| Monte Carlo | Production data observability platform — automated anomaly detection, freshness monitoring, lineage tracking. The SQL patterns in data_quality/ demonstrate the underlying logic that Monte Carlo implements at scale. |
| re_data | Open source dbt-native data observability alternative |
| Atlan | Modern data catalogue and metadata management platform — data discovery, lineage, governance and collaboration across the data stack |

## Business Intelligence & Reporting
| Tool | Purpose |
|------|---------|
| Tableau | Enterprise BI and data visualisation |
| Looker Studio | Self-serve reporting and dashboards |
| Power BI | Microsoft BI tooling |

## Workflow & Collaboration
| Tool | Purpose |
|------|---------|
| Git | Version control |
| GitHub | Remote repository and code collaboration |
| Agile / SAFe | Delivery methodology |