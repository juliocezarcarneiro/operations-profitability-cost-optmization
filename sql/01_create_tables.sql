CREATE TABLE locations (
    location_id VARCHAR(10) PRIMARY KEY,
    location_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    store_format VARCHAR(50),
    opening_year INT
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    menu_price NUMERIC(10,2),
    standard_food_cost NUMERIC(10,2),
    portion_size_grams INT,
    vendor_id VARCHAR(10)
);

CREATE TABLE vendor_prices (
    month VARCHAR(7),
    vendor_id VARCHAR(10),
    product_id VARCHAR(10),
    vendor_name VARCHAR(100),
    actual_unit_cost NUMERIC(10,2),
    prior_unit_cost NUMERIC(10,2),
    cost_change_pct NUMERIC(10,2)
);

CREATE TABLE sales (
    transaction_date DATE,
    month VARCHAR(7),
    location_id VARCHAR(10),
    product_id VARCHAR(10),
    units_sold INT,
    revenue NUMERIC(12,2),
    discount_amount NUMERIC(10,2),
    avg_ticket NUMERIC(10,2),
    transactions_count INT
);

CREATE TABLE costs (
    month VARCHAR(7),
    location_id VARCHAR(10),
    product_id VARCHAR(10),
    cogs NUMERIC(12,2),
    labor_cost NUMERIC(12,2),
    packaging_cost NUMERIC(12,2),
    overhead_allocated NUMERIC(12,2),
    total_cost NUMERIC(12,2)
);

CREATE TABLE waste (
    month VARCHAR(7),
    location_id VARCHAR(10),
    product_id VARCHAR(10),
    waste_units INT,
    waste_cost NUMERIC(12,2),
    waste_reason VARCHAR(100),
    recorded_by VARCHAR(100)
);