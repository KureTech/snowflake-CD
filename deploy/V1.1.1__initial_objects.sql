-- 1. Create a Database (Note: Snowflake does not support "IF NOT EXISTS" for DATABASE)
CREATE DATABASE STOCKSDB;

-- 2. Create a Schema (Note: Snowflake does not support "IF NOT EXISTS" for SCHEMA)
CREATE SCHEMA STOCKSDB.STOCKS_SCHEMA;

-- 3. Create a Table within the Schema
CREATE OR REPLACE TABLE STOCKSDB.STOCKS_SCHEMA.STOCKSDATA (
    id INT,
    stock_symbol STRING,
    description STRING,
    current_price FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Insert Data into the Table
INSERT INTO STOCKSDB.STOCKS_SCHEMA.STOCKSDATA (id, stock_symbol, description, current_price)
VALUES 
    (1, 'TESLA', 'TESLA', 450.00),
    (2, 'APPL', 'Apple Inc', 300.00),
    (3, 'AMD', 'AMD', 130.00);

-- 5. Verify the data has been inserted
SELECT * FROM STOCKSDB.STOCKS_SCHEMA.STOCKSDATA;
