-- Step 1: Create Schema
CREATE OR REPLACE SCHEMA vehicles.schema_vehicles;


-- Step 2: Create Table
CREATE OR REPLACE TABLE vehicles.schema_vehicles.vehicles_db (
    id NUMBER,
    url STRING,
    region STRING,
    price NUMBER,
    "year" NUMBER,
    vehicle STRING,
    manufacturer STRING,
    model STRING,
    condition STRING,
    cylinders FLOAT,
    fuel STRING,
    odometer NUMBER,
    title_status STRING,
    transmission STRING,
    VIN STRING,
    drive STRING,
    type STRING,
    paint_color STRING,
    image_url STRING,
    description STRING,
    state STRING,
    lat FLOAT,
    long FLOAT,
    posting_date DATE,
    price_per_mile FLOAT
);


-- Step 3: Create File Format
CREATE OR REPLACE FILE FORMAT my_csv_format
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
NULL_IF = ('', 'NULL');


-- Step 4: Load Data
COPY INTO vehicles.schema_vehicles.vehicles_db
FROM 's3://vehicles-s3/vehicles_split_files/'
CREDENTIALS = (
    AWS_KEY_ID = 'AWS_KEY_ID',
    AWS_SECRET_KEY = 'AWS_SECRET_KEY'
)
FILE_FORMAT = my_csv_format
ON_ERROR = 'CONTINUE';


SELECT * FROM vehicles_db;