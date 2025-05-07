# 🚗 Vehicle Listings Data Pipeline & Analysis
[![Read on Medium](https://img.shields.io/badge/Read_on-Medium-green?logo=medium)](https://medium.com/@masaliasaiyam09/driving-data-how-i-built-an-end-to-end-vehicle-analytics-pipeline-with-snowflake-s3-sql-d42e3ff04275)

## 📊 **Project Overview**

This project builds a **scalable data pipeline** for analyzing \~420,000 vehicle listings scraped from public online marketplaces (similar to Craigslist). The goal is to uncover **pricing trends, risk factors, and actionable insights** for dealerships and online vehicle platforms.

🔗 **Part 1: Data Pipeline & SQL Analysis (this repo)**

🛠️ *Part 2 (Dashboarding) coming soon!*

---

## 🔄 **Pipeline Stages**

1️⃣ **Raw Data Input:**

* Vehicle listings (CSV, \~420K rows)

2️⃣ **Data Cleaning (Python):**

* Removed nulls & duplicates
* Remove Outliers
* Standardized fields (manufacturer, model, price)
* Engineered features (e.g., price\_per\_mile)

3️⃣ **Cloud Storage:**

* Uploaded cleaned dataset to **AWS S3**

4️⃣ **Data Warehouse:**

* Imported into **Snowflake (vehicles\_db table)**

5️⃣ **SQL Analysis:**

* Performed deep-dive queries:

  * Price trends by region & vehicle type
  * Mileage impact on pricing
  * Condition/age analysis
  * Risk flags (e.g., title status)

---

## 🔍 **Sample Business Insights**

* ✅ Optimal pricing ranges by car type & age
* 🚩 Identification of listings with possible risk (e.g., salvage titles)
* 🚗 Inventory analysis to assist dealership planning

---

## 📁 **Files**

* `vehicles_db_analysis.sql` – full SQL analysis scripts
* `README.md` – this file
* `vehicle_data_cleaning.ipynb` - Data Cleaning using Pandas

---

## 🗂️ **Tech Stack**

* Python (Pandas)
* AWS S3
* Snowflake
* SQL

---

## 📈 **Next Steps (Part 2)**

➡️ Building interactive dashboards using **Tableau** to visualize:

* Pricing trends
* Regional distributions
* High-risk inventory markers

---

## 📜 **Data Source**

The dataset used was scraped from public online vehicle marketplaces and contains detailed listing info (price, manufacturer, model, condition, etc.). A comparable dataset is available on [Kaggle here](https://www.kaggle.com/datasets/austinreese/craigslist-carstrucks-data).
