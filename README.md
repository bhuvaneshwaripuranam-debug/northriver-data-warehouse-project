# NorthRiver Data Warehouse

A star-schema data warehouse built from the NorthRiver OLTP database. The data is loaded by an automated Databricks pipeline and served to a Power BI dashboard.

## Architecture
OLTP -> staging tables in Databricks -> star schema in `northriver_warehouse` -> Power BI.
The Databricks job `northriver_nightly_pipeline` runs the extract, transform and load tasks nightly at 02:00 (Europe/Berlin).

## Design choices
- Fact grain: `fact_orders`, one row per order line item
- Dimensions: `dim_customer`, `dim_product`, `dim_channel`, `dim_date`, with surrogate keys (`_sk`)
- SCD Type 2 on `dim_customer` and `dim_product`
- Loading order: dimensions first, then the fact table

## Files
| File | What it is |
|---|---|
| `MSIT-Data Modeling.sql` | Initial SQL for the OLTP source |
| `02_create_warehouse_schema` | Creates the warehouse schema and tables |
| `03_extract` | Extracts source data into staging |
| `04_transform` | Builds dimensions with SCD Type 2 |
| `05_load` | Loads fact_orders |
| `06_pipeline_documentation` | Pipeline documentation |
| `NorthRiver_Dashboard.pbix` | Power BI dashboard |
| `NorthRiver Data Warehouse.pptx` | Presentation |
| `NorthRiver_Data_Warehouse_Executive_Report...pdf` | Executive report |
| `NorthRiver_Summary_Report.pdf` | Short summary |
