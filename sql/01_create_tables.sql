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
    unit_cost NUMERIC(10,2),
    unit_price NUMERIC(10,2),
    supplier_name VARCHAR(100)
);

CREATE TABLE sales (
    sale_id VARCHAR(20) PRIMARY KEY,
    sale_date DATE,
    location_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity_sold INT,
    revenue NUMERIC(12,2),
    discount NUMERIC(10,2),
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE inventory (
    inventory_id VARCHAR(20) PRIMARY KEY,
    inventory_date DATE,
    location_id VARCHAR(10),
    product_id VARCHAR(10),
    stock_on_hand INT,
    waste_quantity INT,
    spoilage_cost NUMERIC(12,2),
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE labor (
    labor_id VARCHAR(20) PRIMARY KEY,
    labor_date DATE,
    location_id VARCHAR(10),
    labor_hours NUMERIC(10,2),
    labor_cost NUMERIC(12,2),
    overtime_hours NUMERIC(10,2),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE expenses (
    expense_id VARCHAR(20) PRIMARY KEY,
    expense_date DATE,
    location_id VARCHAR(10),
    expense_type VARCHAR(100),
    expense_amount NUMERIC(12,2),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);