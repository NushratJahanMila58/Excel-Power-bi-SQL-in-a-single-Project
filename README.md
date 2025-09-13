# E-commerce Sales Analysis Project

## 📌 Project Overview
This project focuses on analyzing an **E-commerce Sales Dataset** using three different approaches:
1. **Excel Dashboard** – Data transformation, modeling, and visualization using Power Query, Power Pivot, and DAX.
2. **Power BI Report** – Interactive dashboards with advanced visualizations and navigation.
3. **SQL Project** – Database design, data normalization, ingestion, and business query analysis.

The dataset includes two files:
- `sales.csv` (main transaction dataset)
- `return_table.csv` (records of returned orders)

The project demonstrates **data cleaning, modeling, KPI measurement, and insightful reporting** for decision-making.

---

## 🔹 Part 1: Excel Dashboard
Tasks completed using **Excel, Power Query, Power Pivot, and DAX**:
- Data transformation and creation of **dimension tables** (Location, Product, Date).
- Built **data model** connecting dimension and fact tables.
- Created multiple dashboards:
  - **Product Analysis** → Total Orders vs Returned Orders (stacked bar chart).
  - **Regional Sales** → KPIs (Revenue, Profit, Margin, Avg. Order Value), Map visualization, Continent slicers.
  - **Logistics Insights** → Avg. Shipping Days, Revenue vs Shipping Correlation, Conditional formatting.
  - **Time-Series Analysis** → Cumulative Profit, Weekly Growth, Monthly Rolling Revenue with Area, Waterfall, Treemap visuals.

---

## 🔹 Part 2: Power BI Report
Tasks completed in **Power BI**:
- Data model creation using **Star Schema** (Date, Region, Return tables) and **Snowflake Schema** (Product hierarchy).
- Added calculated columns for **Cost, Revenue, Profit**.
- Designed a **4-page interactive report**:
  1. **Homepage** – Title & navigation buttons.
  2. **Executive Dashboard** – KPIs, Donut charts, Profit by Continent, Summary tables.
  3. **Regional Orders** – Donut chart (Order Priority), Map (Country → State → City), Top 5 cities chart.
  4. **Sales Page** – Returned vs Non-returned KPIs, Monthly performance tables, Revenue trend analysis.

- Included slicers and navigation buttons for user interactivity.

---

## 🔹 Part 3: SQL Project
Tasks completed using **MySQL**:
- **Data Ingestion & Normalization**
  - Loaded `sales.csv` and `return_table.csv` into SQL database.
  - Created **dimension tables** (`dim_location`, `dim_product`, `dim_category`, `dim_sub_category`).
  - Built **fact_transaction** table with foreign keys.
- **Business Insights via Queries**
  - Total Revenue, Net Revenue, and Profit calculations.
  - Order distribution by customer segment & shipping mode.
  - Top 5 products by sales quantity.
  - Monthly revenue trends & YoY growth.
  - Return rate analysis by category & continent.
  - Profitability insights (high-margin categories, negative profit products).
  - Customer & product behavior analysis (frequently bought together, multi-product orders).
  - Abnormal order/shipping cost detection.

---

## 🚀 Key Highlights
- Built a **complete analytics pipeline** across Excel, Power BI, and SQL.
- Used **DAX & SQL queries** for deep KPI insights.
- Designed **interactive dashboards** for executive decision-making.
- Ensured **data integrity** through proper normalization & modeling.
- Answered **20+ real business questions** through SQL analysis.

---

## 📂 Project Deliverables
- Excel File (`Ecommerce_Analysis.xlsx`) with multiple dashboards.
- Power BI File (`Ecommerce_Analysis.pbix`) with interactive reports.
- SQL Script (`Ecommerce_Analysis.sql`) with table creation & ingestion.
- SQL Report (`SQL_Analysis.doc`) with queries & outputs.

---

## 🏆 Conclusion
This project demonstrates the ability to work with **real-world datasets**, applying **data transformation, visualization, and analytical techniques** across different tools. The outcome provides actionable insights into **sales, returns, customer behavior, logistics, and profitability**, supporting **data-driven decision-making** in the e-commerce domain.

---
