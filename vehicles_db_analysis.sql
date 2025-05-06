SELECT * FROM vehicles_db ORDER BY 1;


-- 🟢 Easy Questions

-- 1. List all vehicles with a price less than 5000.
SELECT DISTINCT vehicle
FROM vehicles_db 
WHERE price > 5000
ORDER BY 1;

-- 2. Show the distinct manufacturers in the dataset.
SELECT DISTINCT manufacturer
FROM vehicles_db
ORDER BY 1;

-- 3. Retrieve the top 10 most expensive vehicles.
SELECT DISTINCT vehicle, price
FROM vehicles_db
ORDER BY price DESC
LIMIT 10;

-- 4. Count how many vehicles are available in each state. (includes other territories like Washington DC as well hence we got 51)
SELECT state, COUNT(*) Count_of_vehicles
FROM vehicles_db
GROUP BY state
ORDER BY 2 DESC;

-- 5. Find all vehicles that use electric fuel.
SELECT DISTINCT vehicle electric_vehicle
FROM vehicles_db
WHERE FUEL = 'electric'
ORDER BY 1;


-- 🟡 Moderate Questions

-- 6. Show the average price of vehicles grouped by transmission type.
SELECT transmission, ROUND(AVG(price), 2) avg_price_transmission 
FROM vehicles_db
WHERE transmission IS NOT NULL
GROUP BY transmission
ORDER BY 2 DESC;

-- 7. Find the top 5 most common vehicle models for each manufacturer.
WITH model_counts AS (
  SELECT
    manufacturer,
    model,
    COUNT(*) model_count,
    ROW_NUMBER() OVER (PARTITION BY manufacturer ORDER BY COUNT(*) DESC) rn
  FROM vehicles_db
  GROUP BY manufacturer, model
)

SELECT manufacturer, model, model_count, rn
FROM model_counts
WHERE rn <= 5
ORDER BY manufacturer, model_count DESC;

-- 8. List all vehicles where the odometer reading is above the average.
WITH high_mileage AS (
  SELECT *
  FROM vehicles_db
  WHERE odometer > (SELECT AVG(odometer) FROM vehicles_db)
)
SELECT vehicle
FROM high_mileage
GROUP BY vehicle; 

-- 9. Show the minimum and maximum years of vehicles for each region.
SELECT INITCAP(region), MIN("year") min_year, MAX("year") max_year
FROM vehicles_db
GROUP BY region;

-- 10. Get a list of all vehicles with missing VINs.
SELECT vehicle
FROM vehicles_db
WHERE VIN IS NULL;

-- 11. Retrieve vehicles where the description includes the word “clean”.
SELECT vehicle, description
FROM vehicles_db
WHERE description ILIKE '%clean%';

-- 12. Rank the vehicles by price within each state.
WITH vehicle_data AS (
  SELECT
    state,
    vehicle,
    price
  FROM vehicles_db
  GROUP BY state, manufacturer, model, price
)

SELECT
  UPPER(state),
  vehicle,
  price,
  ROW_NUMBER() OVER (PARTITION BY state ORDER BY price DESC) price_rank
FROM vehicle_data
WHERE vehicle IS NOT NULL
ORDER BY state, price_rank;

-- 13. Show the number of vehicles by fuel type and condition.
SELECT
    fuel,
    condition,
    COUNT(*)    
FROM vehicles_db
GROUP BY fuel, condition
ORDER BY 3 DESC;

-- 15. Find the top 3 regions with the most vehicles posted this month.
SELECT region, COUNT(*)
FROM vehicles_db
WHERE EXTRACT(MONTH FROM posting_date) = 4
GROUP BY region
ORDER BY COUNT(*) DESC
LIMIT 3;


-- 🔴 Hard Questions

-- 16. Find the percentage of vehicles with automatic transmission per state.
SELECT 
  state,
  ROUND(100.0 * SUM(CASE WHEN transmission = 'automatic' THEN 1 END) / COUNT(*), 2) AS automatic_percentage
FROM vehicles_db
GROUP BY state
ORDER BY automatic_percentage DESC;


-- 17. For each manufacturer, list the model with the highest average price.
WITH avg_prices AS (
  SELECT 
    manufacturer, 
    model, 
    ROUND(AVG(price), 2) AS avg_price,
    RANK() OVER(PARTITION BY manufacturer ORDER BY avg_price DESC) AS rnk
  FROM vehicles_db
  WHERE manufacturer IS NOT NULL AND model IS NOT NULL 
  GROUP BY manufacturer, model
)

SELECT 
  UPPER(manufacturer), 
  model, 
  avg_price
FROM avg_prices
WHERE rnk = 1 
ORDER BY avg_price DESC;

-- 18. Identify duplicate listings based on VIN, price, and year.
SELECT VIN, price, "year", COUNT(*)
FROM vehicles_db
WHERE VIN IS NOT NULL
GROUP BY VIN, price, "year"
ORDER BY 4 DESC;

-- 19. Show vehicles whose price is in the top 10% within their region.
WITH ranked_vehicles AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY region ORDER BY price DESC) AS price_rank,
         COUNT(*) OVER (PARTITION BY region) AS total_vehicles
  FROM vehicles_db
)

SELECT DISTINCT region, manufacturer, model, price
FROM ranked_vehicles
WHERE price_rank <= CEIL(total_vehicles * 0.10)
ORDER BY region, price DESC;

-- 20. Get the average odometer reading for vehicles newer than the median year.
SELECT AVG(odometer) FROM vehicles_db
WHERE "year" > (
    SELECT (percentile_cont(0.5) WITHIN GROUP (ORDER BY "year"))::NUMBER median_year 
    FROM vehicles_db
);

-- 21. Compare the average price of 4-cylinder vs 6-cylinder vehicles.
SELECT cylinders, ROUND(AVG(price), 2) AS avg_price
FROM vehicles_db
WHERE cylinders = 4 OR cylinders = 6 
GROUP BY cylinders
ORDER BY cylinders;

-- 22. For each region, calculate the month-over-month change in vehicle postings.
WITH region_month_counts AS (
    SELECT 
        region,
        EXTRACT(MONTH FROM posting_date) AS months,
        COUNT(*) AS num_postings
    FROM vehicles_db
    WHERE posting_date IS NOT NULL
    GROUP BY region, EXTRACT(MONTH FROM posting_date)
),

region_with_lag AS (
    SELECT
        region,
        months,
        num_postings,
        LAG(num_postings) OVER (PARTITION BY region ORDER BY months) AS prev_month_postings
    FROM region_month_counts
)

SELECT
    region,
    months,
    num_postings,
    COALESCE(
    ROUND(
        100.0 * (num_postings - prev_month_postings) / NULLIF(prev_month_postings, 0), 2), 0
) AS MoM_change_percentage
FROM region_with_lag
ORDER BY region, months;

-- 23. Identify the 5 models with the steepest price depreciation from newest to oldest year.
WITH model_year_prices AS (
    SELECT 
        model,
        "year",
        AVG(price) AS avg_price -- in case multiple prices in same year
    FROM vehicles_db
    WHERE price > 1 AND "year" IS NOT NULL
    GROUP BY model, "year"
),

oldest_newest_prices AS (
    SELECT 
        model,
        FIRST_VALUE("year")    OVER(PARTITION BY model ORDER BY "year" ASC) AS oldest_year,
        FIRST_VALUE(avg_price) OVER(PARTITION BY model ORDER BY "year" ASC) AS oldest_year_price,
        FIRST_VALUE("year")    OVER(PARTITION BY model ORDER BY "year" DESC) AS newest_year,
        FIRST_VALUE(avg_price) OVER(PARTITION BY model ORDER BY "year" DESC) AS newest_year_price
    FROM model_year_prices
)

SELECT 
    model,
    ROUND(oldest_year, 2),
    ROUND(newest_year, 2),
    ROUND(oldest_year_price, 2),
    ROUND(newest_year_price, 2),
    ROUND(oldest_year_price - newest_year_price, 2) AS price_diff
FROM oldest_newest_prices
GROUP BY model, oldest_year, newest_year, oldest_year_price, newest_year_price
ORDER BY price_diff DESC
LIMIT 5;

-- 24. List vehicles where the price per mile (price/odometer) is below 0.1.
SELECT DISTINCT vehicle, price_per_mile
FROM vehicles_db
WHERE price_per_mile < 0.1
    AND vehicle IS NOT NULL
ORDER BY price_per_mile DESC
LIMIT 100;

-- 25. Find the average time between posting_date and the earliest posting in the same region.
WITH region_first_posting AS (
    SELECT 
        region,
        posting_date,
        MIN(posting_date) OVER (PARTITION BY region) AS first_posting_date
    FROM vehicles_db
)
SELECT 
    region,
    ROUND(AVG(DATEDIFF(day, first_posting_date, posting_date)), 1) AS avg_days_since_first_posting
FROM region_first_posting
WHERE DATEDIFF(day, first_posting_date, posting_date) > 0
GROUP BY region
ORDER BY avg_days_since_first_posting DESC;

-- 26. Create a bucketed price range and count vehicles in each bucket.
SELECT 
    FLOOR(price / 5000) * 5000 AS price_bucket, -- Can try 10K as well
    COUNT(*) AS vehicle_count
FROM vehicles_db
WHERE price IS NOT NULL
GROUP BY price_bucket
ORDER BY price_bucket;

-- 27. Determine which manufacturers have the widest variety of paint colors.
SELECT manufacturer, COUNT(DISTINCT paint_color) no_paint_colors
FROM vehicles_db
WHERE manufacturer IS NOT NULL AND paint_color IS NOT NULL
GROUP BY manufacturer
ORDER BY 2 DESC;

-- 28. Find the average number of words in the description by type of vehicle.
SELECT 
    type,
    ROUND(AVG(
        LENGTH(description) - LENGTH(REPLACE(description, ' ', '')) + 1 -- Counting spaces + 1
    ), 2) AS avg_word_count -- https://stackoverflow.com/questions/748276/using-sql-to-determine-word-count-stats-of-a-text-field
FROM vehicles_db
WHERE type IS NOT NULL AND description IS NOT NULL AND LENGTH(TRIM(description)) > 0
GROUP BY type
ORDER BY avg_word_count DESC;

-- 29. Get all vehicles where the lat/long coordinates are outside the expected U.S. range.
SELECT DISTINCT vehicle
FROM vehicles_db
WHERE 
    lat IS NOT NULL AND 
    long IS NOT NULL AND (
        lat < 24.5 OR lat > 49.5 OR
        long < -125 OR long > -66.5
    );

-- 30. Retrieve the top 5 models with the largest price variation in each fuel type.
WITH model_price_diff AS (
    SELECT
        fuel,
        model,
        MAX(price) - MIN(price) AS price_diff
    FROM vehicles_db
    WHERE price IS NOT NULL
    GROUP BY fuel, model
)

SELECT 
    fuel,
    model,
    price_diff
FROM model_price_diff
QUALIFY ROW_NUMBER() OVER (PARTITION BY fuel ORDER BY price_diff DESC) <= 5
ORDER BY fuel, price_diff DESC;