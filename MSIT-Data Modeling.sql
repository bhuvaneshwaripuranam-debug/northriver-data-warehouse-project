CREATE DATABASE northriver_oltp;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) UNIQUE,
    region        VARCHAR(50),
    segment       VARCHAR(50),
    updated_at    TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    brand         VARCHAR(50),
    category      VARCHAR(50),
    subcategory   VARCHAR(50),
    unit_cost     NUMERIC(10, 2),
    updated_at    TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date    DATE    NOT NULL,
    channel       VARCHAR(50),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INTEGER        NOT NULL REFERENCES orders(order_id),
    product_id    INTEGER        NOT NULL REFERENCES products(product_id),
    quantity      INTEGER        NOT NULL,
    unit_price    NUMERIC(10, 2) NOT NULL,
    updated_at    TIMESTAMP      NOT NULL DEFAULT now()
);


INSERT INTO customers (first_name, last_name, email, region, segment) VALUES
('Alice',    'Martins',  'alice.martins@example.com',  'North', 'B2C'),
('Bruno',    'Silva',    'bruno.silva@corp.com',      'South', 'B2B'),
('Clara',    'Nunes',    'clara.nunes@example.com',     'East',  'B2C'),
('Diego',    'Costa',    'diego.costa@corp.com',      'West',  'B2B'),
('Elena',    'Ferreira', 'elena.f@example.com',         'North', 'B2C'),
('Fabio',    'Rocha',    'fabio.rocha@corp.com',      'South', 'B2B'),
('Gabriela', 'Lima',     'gabi.lima@example.com',       'East',  'B2C'),
('Hugo',     'Alves',    'hugo.alves@corp.com',       'West',  'B2B'),
('Isabela',  'Santos',   'isa.santos@example.com',      'North', 'B2C'),
('Joao',     'Pereira',  'joao.p@corp.com',           'South', 'B2B');

INSERT INTO products (product_name, brand, category, subcategory, unit_cost) VALUES
('Laptop Pro 15',               'TechBrand', 'Electronics', 'Computers',   750.00),
('Wireless Mouse',              'TechBrand', 'Electronics', 'Peripherals',  15.00),
('USB-C Hub',                   'ConnectX',  'Electronics', 'Accessories',  25.00),
('Office Chair',                'ErgoHome',  'Furniture',   'Seating',     180.00),
('Standing Desk',               'ErgoHome',  'Furniture',   'Desks',       320.00),
('Noise Cancelling Headphones', 'SoundPro',  'Electronics', 'Audio',        90.00),
('Mechanical Keyboard',         'TechBrand', 'Electronics', 'Peripherals',  60.00),
('Monitor 27in',                'ViewMax',   'Electronics', 'Displays',    200.00),
('Webcam HD',                   'ConnectX',  'Electronics', 'Peripherals',  40.00),
('Desk Lamp',                   'LightCo',   'Furniture',   'Lighting',     30.00);

INSERT INTO orders (customer_id, order_date, channel) VALUES
(1, '2024-01-05', 'Online'),
(2, '2024-01-08', 'Phone'),
(3, '2024-01-12', 'Online'),
(4, '2024-01-15', 'Partner'),
(5, '2024-02-02', 'Online'),
(6, '2024-02-10', 'In-Store'),
(7, '2024-02-14', 'Online'),
(8, '2024-02-20', 'Phone'),
(1, '2024-03-01', 'Online'),
(3, '2024-03-07', 'Online'),
(9, '2024-03-15', 'In-Store'),
(10,'2024-03-22', 'Partner'),
(2, '2024-04-01', 'Phone'),
(5, '2024-04-10', 'Online'),
(7, '2024-04-18', 'Online');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,  1, 1, 999.00),
(1,  2, 2,  25.00),
(2,  4, 4, 240.00),
(3,  3, 1,  35.00),
(3,  7, 1,  85.00),
(4,  5, 2, 420.00),
(5,  6, 1, 120.00),
(5,  8, 2, 259.00),
(6,  9, 3,  55.00),
(7,  1, 1, 999.00),
(7, 10, 2,  40.00),
(8,  2, 5,  25.00),
(9,  1, 2, 949.00),
(9,  7, 1,  85.00),
(10, 3, 2,  35.00),
(11, 4, 1, 240.00),
(11, 6, 2, 120.00),
(12, 5, 1, 420.00),
(13, 8, 1, 259.00),
(14, 9, 2,  55.00),
(14, 2, 3,  25.00),
(15, 1, 1, 999.00),
(15,10, 1,  40.00);


SELECT 'customers'   AS table_name, COUNT(*) AS rows FROM customers
UNION ALL
SELECT 'products',                  COUNT(*)          FROM products
UNION ALL
SELECT 'orders',                    COUNT(*)          FROM orders
UNION ALL
SELECT 'order_items',               COUNT(*)          FROM order_items;

SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer,
    o.order_date,
    o.channel,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
ORDER BY o.order_date, o.order_id
LIMIT 10;


CREATE DATABASE northriver_dw;

CREATE SCHEMA staging;

CREATE TABLE IF NOT EXISTS staging.stg_customers (
    customer_id   INTEGER,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    region        VARCHAR(50),
    segment       VARCHAR(50),
    updated_at    TIMESTAMP,
    extracted_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staging.stg_products (
    product_id    INTEGER,
    product_name  VARCHAR(100),
    brand         VARCHAR(50),
    category      VARCHAR(50),
    subcategory   VARCHAR(50),
    unit_cost     NUMERIC(10, 2),
    updated_at    TIMESTAMP,
    extracted_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staging.stg_orders (
    order_id      INTEGER,
    customer_id   INTEGER,
    order_date    DATE,
    channel       VARCHAR(50),
    updated_at    TIMESTAMP,
    extracted_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staging.stg_order_items (
    order_item_id INTEGER,
    order_id      INTEGER,
    product_id    INTEGER,
    quantity      INTEGER,
    unit_price    NUMERIC(10, 2),
    updated_at    TIMESTAMP,
    extracted_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staging.etl_watermark (
    source_table    VARCHAR(50) PRIMARY KEY,
    last_watermark  TIMESTAMP NOT NULL DEFAULT '1900-01-01'
);

INSERT INTO staging.etl_watermark (source_table) VALUES
    ('customers'), ('products'), ('orders'), ('order_items')
ON CONFLICT (source_table) DO NOTHING;

CREATE SCHEMA warehouse;


SELECT schema_name
FROM   information_schema.schemata
WHERE  schema_name IN ('staging', 'warehouse')
ORDER  BY schema_name;

SELECT table_name
FROM   information_schema.tables
WHERE  table_schema = 'staging'
ORDER  BY table_name;



-- Activates the dblink extension for this database (no-op if it's already enabled)
CREATE EXTENSION IF NOT EXISTS dblink;

WITH incoming AS (
    -- Pull only OLTP customers changed since the last watermark for this table
    SELECT *
    FROM dblink(
        'host=localhost port=5432 dbname=northriver_oltp user=postgres password=1219252',
        format(
            'SELECT customer_id, first_name, last_name, email, region, segment, updated_at FROM customers WHERE updated_at >= %L',
            (SELECT last_watermark FROM staging.etl_watermark WHERE source_table = 'customers')  -- current watermark for 'customers'
        )
    ) AS t(
        customer_id INTEGER, first_name VARCHAR(50), last_name VARCHAR(50),
        email VARCHAR(100), region VARCHAR(50), segment VARCHAR(50), updated_at TIMESTAMP
    )
),
removed AS (
    -- Drop any stale copy already in staging so the fresh row doesn't end up duplicated
    DELETE FROM staging.stg_customers
    WHERE customer_id IN (SELECT customer_id FROM incoming)
    RETURNING customer_id
),
inserted AS (
    -- Land the fresh (new or changed) rows in staging
    INSERT INTO staging.stg_customers
        (customer_id, first_name, last_name, email, region, segment, updated_at)
    SELECT customer_id, first_name, last_name, email, region, segment, updated_at
    FROM incoming
    RETURNING customer_id
)
-- Move the watermark to the newest source timestamp that was actually extracted.
-- If no rows were extracted, keep the previous watermark.
UPDATE staging.etl_watermark
SET last_watermark = COALESCE((SELECT MAX(updated_at) FROM incoming), last_watermark)
WHERE source_table = 'customers';

WITH incoming AS (
    -- Pull only OLTP products changed since the last watermark for this table
    SELECT *
    FROM dblink(
        'host=localhost port=5432 dbname=northriver_oltp user=postgres password=1219252',
        format(
            'SELECT product_id, product_name, brand, category, subcategory, unit_cost, updated_at FROM products WHERE updated_at >= %L',
            (SELECT last_watermark FROM staging.etl_watermark WHERE source_table = 'products')  -- current watermark for 'products'
        )
    ) AS t(
        product_id INTEGER, product_name VARCHAR(100), brand VARCHAR(50),
        category VARCHAR(50), subcategory VARCHAR(50), unit_cost NUMERIC(10, 2), updated_at TIMESTAMP
    )
),
removed AS (
    -- Drop any stale copy already in staging so the fresh row doesn't end up duplicated
    DELETE FROM staging.stg_products
    WHERE product_id IN (SELECT product_id FROM incoming)
    RETURNING product_id
),
inserted AS (
    -- Land the fresh (new or changed) rows in staging
    INSERT INTO staging.stg_products
        (product_id, product_name, brand, category, subcategory, unit_cost, updated_at)
    SELECT product_id, product_name, brand, category, subcategory, unit_cost, updated_at
    FROM incoming
    RETURNING product_id
)
-- Move the watermark to the newest source timestamp that was actually extracted.
-- If no rows were extracted, keep the previous watermark.
UPDATE staging.etl_watermark
SET last_watermark = COALESCE((SELECT MAX(updated_at) FROM incoming), last_watermark)
WHERE source_table = 'products';

WITH incoming AS (
    -- Pull only OLTP orders changed since the last watermark for this table
    SELECT *
    FROM dblink(
        'host=localhost port=5432 dbname=northriver_oltp user=postgres password=1219252',
        format(
            'SELECT order_id, customer_id, order_date, channel, updated_at FROM orders WHERE updated_at >= %L',
            (SELECT last_watermark FROM staging.etl_watermark WHERE source_table = 'orders')  -- current watermark for 'orders'
        )
    ) AS t(
        order_id INTEGER, customer_id INTEGER, order_date DATE, channel VARCHAR(50), updated_at TIMESTAMP
    )
),
removed AS (
    -- Drop any stale copy already in staging so the fresh row doesn't end up duplicated
    DELETE FROM staging.stg_orders
    WHERE order_id IN (SELECT order_id FROM incoming)
    RETURNING order_id
),
inserted AS (
    -- Land the fresh (new or changed) rows in staging
    INSERT INTO staging.stg_orders
        (order_id, customer_id, order_date, channel, updated_at)
    SELECT order_id, customer_id, order_date, channel, updated_at
    FROM incoming
    RETURNING order_id
)
-- Move the watermark to the newest source timestamp that was actually extracted.
-- If no rows were extracted, keep the previous watermark.
UPDATE staging.etl_watermark
SET last_watermark = COALESCE((SELECT MAX(updated_at) FROM incoming), last_watermark)
WHERE source_table = 'orders';

WITH incoming AS (
    -- Pull only OLTP order items changed since the last watermark for this table
    SELECT *
    FROM dblink(
        'host=localhost port=5432 dbname=northriver_oltp user=postgres password=1219252',
        format(
            'SELECT order_item_id, order_id, product_id, quantity, unit_price, updated_at FROM order_items WHERE updated_at >= %L',
            (SELECT last_watermark FROM staging.etl_watermark WHERE source_table = 'order_items')  -- current watermark for 'order_items'
        )
    ) AS t(
        order_item_id INTEGER, order_id INTEGER, product_id INTEGER,
        quantity INTEGER, unit_price NUMERIC(10, 2), updated_at TIMESTAMP
    )
),
removed AS (
    -- Drop any stale copy already in staging so the fresh row doesn't end up duplicated
    DELETE FROM staging.stg_order_items
    WHERE order_item_id IN (SELECT order_item_id FROM incoming)
    RETURNING order_item_id
),
inserted AS (
    -- Land the fresh (new or changed) rows in staging
    INSERT INTO staging.stg_order_items
        (order_item_id, order_id, product_id, quantity, unit_price, updated_at)
    SELECT order_item_id, order_id, product_id, quantity, unit_price, updated_at
    FROM incoming
    RETURNING order_item_id
)
-- Move the watermark to the newest source timestamp that was actually extracted.
-- If no rows were extracted, keep the previous watermark.
UPDATE staging.etl_watermark
SET last_watermark = COALESCE((SELECT MAX(updated_at) FROM incoming), last_watermark)
WHERE source_table = 'order_items';

-- Row counts should match the OLTP source exactly, since this is the first run
SELECT 'stg_customers'   AS table_name, COUNT(*) AS rows FROM staging.stg_customers
UNION ALL
SELECT 'stg_products',                  COUNT(*)          FROM staging.stg_products
UNION ALL
SELECT 'stg_orders',                    COUNT(*)          FROM staging.stg_orders
UNION ALL
SELECT 'stg_order_items',               COUNT(*)          FROM staging.stg_order_items;

-- Spot-check that extracted_at is a real, recent timestamp on every landed row
SELECT customer_id, first_name, extracted_at
FROM   staging.stg_customers
LIMIT  5;

-- A brand-new row: should be picked up as an insert
INSERT INTO customers (first_name, last_name, email, region, segment)
VALUES ('Karen', 'Duarte', 'karen.duarte@example.com', 'North', 'B2C');

-- A change to an existing row: updated_at is set by hand, since there's no trigger doing it automatically
UPDATE customers
SET region = 'South', updated_at = now()
WHERE first_name = 'Alice' AND last_name = 'Martins';

-- Expect 11: the original 10 plus Karen
SELECT COUNT(*) FROM staging.stg_customers;

-- Alice should show her new region with a fresh extracted_at; Karen should appear for the first time
SELECT customer_id, first_name, region, extracted_at
FROM staging.stg_customers
WHERE first_name IN ('Karen', 'Alice')
ORDER BY first_name;


UPDATE staging.stg_orders SET channel = 'online' WHERE order_id = 1;
UPDATE staging.stg_orders SET channel = 'ONLINE' WHERE order_id = 9;

UPDATE staging.stg_customers SET email = NULL WHERE customer_id = 3;

INSERT INTO staging.stg_customers
    (customer_id, first_name, last_name, email, region, segment, updated_at, extracted_at)
SELECT customer_id, first_name, last_name, email, region, segment, updated_at, now()
FROM staging.stg_customers
WHERE customer_id = 5;

SELECT channel, COUNT(*) FROM staging.stg_orders GROUP BY channel;

SELECT customer_id, first_name, last_name FROM staging.stg_customers WHERE email IS NULL;

SELECT customer_id, COUNT(*)
FROM staging.stg_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT oi.order_item_id
FROM staging.stg_order_items oi
LEFT JOIN staging.stg_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

UPDATE staging.stg_orders
SET channel = INITCAP(LOWER(channel));

DELETE FROM staging.stg_customers a
USING staging.stg_customers b
WHERE a.customer_id = b.customer_id
  AND a.extracted_at < b.extracted_at;

SELECT customer_id, first_name, last_name, email FROM staging.stg_customers WHERE email IS NULL;

SELECT channel, COUNT(*) FROM staging.stg_orders GROUP BY channel;

SELECT customer_id, COUNT(*)
FROM staging.stg_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM staging.stg_customers;


CREATE TABLE warehouse.dim_customer (
    customer_sk   SERIAL PRIMARY KEY,
    customer_id   INTEGER UNIQUE NOT NULL,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    region        VARCHAR(50),
    segment       VARCHAR(50)
);

CREATE TABLE warehouse.dim_product (
    product_sk    SERIAL PRIMARY KEY,
    product_id    INTEGER UNIQUE NOT NULL,
    product_name  VARCHAR(100),
    brand         VARCHAR(50),
    category      VARCHAR(50),
    subcategory   VARCHAR(50),
    unit_cost     NUMERIC(10, 2)
);

CREATE TABLE warehouse.dim_date (
    date_sk       SERIAL PRIMARY KEY,
    full_date     DATE UNIQUE NOT NULL,
    year          INTEGER,
    quarter       INTEGER,
    month         INTEGER,
    day_of_week   VARCHAR(10)
);

CREATE TABLE warehouse.dim_channel (
    channel_sk    SERIAL PRIMARY KEY,
    channel_name  VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE warehouse.fact_orders (
    order_item_sk   SERIAL PRIMARY KEY,
    customer_sk     INTEGER NOT NULL REFERENCES warehouse.dim_customer(customer_sk),
    product_sk      INTEGER NOT NULL REFERENCES warehouse.dim_product(product_sk),
    date_sk         INTEGER NOT NULL REFERENCES warehouse.dim_date(date_sk),
    channel_sk      INTEGER NOT NULL REFERENCES warehouse.dim_channel(channel_sk),
    order_id        INTEGER NOT NULL,
    order_item_id    INTEGER NOT NULL,
    quantity        INTEGER NOT NULL,
    unit_price      NUMERIC(10, 2) NOT NULL,
    revenue         NUMERIC(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);


SELECT table_name
FROM   information_schema.tables
WHERE  table_schema = 'warehouse'
ORDER  BY table_name;

SELECT tc.table_name, kcu.column_name, ccu.table_name AS references_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'warehouse'
ORDER BY kcu.column_name;


INSERT INTO warehouse.dim_customer
    (customer_id, first_name, last_name, email, region, segment)
SELECT DISTINCT
    s.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    s.region,
    s.segment
FROM staging.stg_customers s
WHERE NOT EXISTS (
    SELECT 1
    FROM warehouse.dim_customer d
    WHERE d.customer_id = s.customer_id
);

INSERT INTO warehouse.dim_product
    (product_id, product_name, brand, category, subcategory, unit_cost)
SELECT DISTINCT
    s.product_id,
    s.product_name,
    s.brand,
    s.category,
    s.subcategory,
    s.unit_cost
FROM staging.stg_products s
WHERE NOT EXISTS (
    SELECT 1
    FROM warehouse.dim_product d
    WHERE d.product_id = s.product_id
);

INSERT INTO warehouse.dim_date
    (full_date, year, quarter, month, day_of_week)
SELECT DISTINCT
    o.order_date,
    EXTRACT(YEAR FROM o.order_date)::INTEGER,
    EXTRACT(QUARTER FROM o.order_date)::INTEGER,
    EXTRACT(MONTH FROM o.order_date)::INTEGER,
    TO_CHAR(o.order_date, 'FMDay')
FROM staging.stg_orders o
WHERE NOT EXISTS (
    SELECT 1
    FROM warehouse.dim_date d
    WHERE d.full_date = o.order_date
);

INSERT INTO warehouse.dim_channel (channel_name)
SELECT DISTINCT s.channel
FROM staging.stg_orders s
WHERE NOT EXISTS (
    SELECT 1
    FROM warehouse.dim_channel d
    WHERE d.channel_name = s.channel
);

INSERT INTO warehouse.fact_orders
    (customer_sk, product_sk, date_sk, channel_sk, order_id, order_item_id, quantity, unit_price)
SELECT
    dc.customer_sk,
    dp.product_sk,
    dd.date_sk,
    dch.channel_sk,
    o.order_id,
    oi.order_item_id,
    oi.quantity,
    oi.unit_price
FROM staging.stg_order_items oi
JOIN staging.stg_orders o
  ON oi.order_id = o.order_id
JOIN warehouse.dim_customer dc
  ON o.customer_id = dc.customer_id
JOIN warehouse.dim_product dp
  ON oi.product_id = dp.product_id
JOIN warehouse.dim_date dd
  ON o.order_date = dd.full_date
JOIN warehouse.dim_channel dch
  ON o.channel = dch.channel_name
WHERE NOT EXISTS (
    SELECT 1
    FROM warehouse.fact_orders f
    WHERE f.order_item_id = oi.order_item_id
);


SELECT 'dim_customer' AS table_name, COUNT(*) AS rows FROM warehouse.dim_customer
UNION ALL
SELECT 'dim_product',  COUNT(*) FROM warehouse.dim_product
UNION ALL
SELECT 'dim_date',     COUNT(*) FROM warehouse.dim_date
UNION ALL
SELECT 'dim_channel',  COUNT(*) FROM warehouse.dim_channel
UNION ALL
SELECT 'fact_orders',  COUNT(*) FROM warehouse.fact_orders;

SELECT * FROM warehouse.dim_customer limit 100;

-- Sprint 3

ALTER TABLE warehouse.dim_customer
  ADD COLUMN IF NOT EXISTS effective_from DATE NOT NULL DEFAULT CURRENT_DATE,
  ADD COLUMN IF NOT EXISTS effective_to   DATE,
  ADD COLUMN IF NOT EXISTS is_current     BOOLEAN NOT NULL DEFAULT TRUE;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'warehouse'
  AND table_name = 'dim_customer'
ORDER BY ordinal_position;

UPDATE warehouse.dim_customer
SET effective_from = '2024-01-01'
WHERE is_current = TRUE;

SELECT customer_sk, customer_id, first_name, last_name, region,
       effective_from, effective_to, is_current
FROM warehouse.dim_customer
ORDER BY customer_sk;

ALTER TABLE warehouse.dim_customer
DROP CONSTRAINT IF EXISTS dim_customer_customer_id_key;

select
*
from warehouse.dim_customer
WHERE email = 'elena.f@example.com'
;

/*
 UPDATE warehouse.dim_customer
SET region = 'South'
WHERE email = 'elena.f@example.com';
 */

UPDATE warehouse.dim_customer
SET effective_to = '2024-04-14',
    is_current   = FALSE
WHERE email = 'elena.f@example.com'
  AND is_current = true
;

INSERT INTO warehouse.dim_customer
  (customer_id, first_name, last_name, email, region, segment, effective_from, effective_to, is_current)
SELECT
  customer_id, first_name, last_name, email, 'South', segment, '2024-04-15', NULL, TRUE
FROM warehouse.dim_customer
WHERE email = 'elena.f@example.com'
  AND is_current = FALSE
ORDER BY effective_to DESC
LIMIT 1;

SELECT
    customer_sk,
    customer_id,
    first_name,
    last_name,
    email,
    region,
    effective_from,
    effective_to,
    is_current
FROM warehouse.dim_customer
WHERE email = 'elena.f@example.com'
ORDER BY effective_from;

SELECT
    f.order_id,
    f.order_item_id ,
    d.full_date AS order_date,
    f.revenue,
    c.region,
    c.effective_from AS dim_effective_from,
    c.is_current AS dim_is_current
FROM warehouse.fact_orders f
JOIN warehouse.dim_customer c
  ON f.customer_sk = c.customer_sk
JOIN warehouse.dim_date d
  ON f.date_sk = d.date_sk
WHERE c.email = 'elena.f@example.com'
ORDER BY d.full_date;

ALTER TABLE warehouse.dim_product
  ADD COLUMN effective_from DATE NOT NULL DEFAULT CURRENT_DATE,
  ADD COLUMN effective_to   DATE,
  ADD COLUMN is_current     BOOLEAN NOT NULL DEFAULT TRUE;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'warehouse'
  AND table_name = 'dim_product'
ORDER BY ordinal_position;

UPDATE warehouse.dim_product
SET effective_from = '2024-01-01'
WHERE is_current = TRUE;

SELECT product_sk, product_id, product_name, category,
       effective_from, effective_to, is_current
FROM warehouse.dim_product
ORDER BY product_sk;

ALTER TABLE warehouse.dim_product
DROP CONSTRAINT IF EXISTS dim_product_product_id_key;

UPDATE warehouse.dim_product
SET effective_to = '2024-06-30',
    is_current   = FALSE
WHERE product_name = 'Office Chair'
  AND brand = 'ErgoHome'
  AND is_current = TRUE;

INSERT INTO warehouse.dim_product
  (product_id, product_name, brand, category, subcategory, unit_cost,
   effective_from, effective_to, is_current)
SELECT
  product_id,
  product_name,
  brand,
  'Office Furniture',
  subcategory,
  unit_cost,
  '2024-07-01',
  NULL,
  TRUE
FROM warehouse.dim_product
WHERE product_name = 'Office Chair'
  AND brand = 'ErgoHome'
  AND is_current = FALSE
ORDER BY effective_to DESC
LIMIT 1;

SELECT
    product_sk,
    product_id,
    product_name,
    brand,
    category,
    effective_from,
    effective_to,
    is_current
FROM warehouse.dim_product
WHERE product_name = 'Office Chair'
  AND brand = 'ErgoHome'
ORDER BY effective_from;

SELECT
    f.order_id,
    d.full_date AS order_date,
    f.revenue,
    p.category,
    p.effective_from AS dim_effective_from,
    p.is_current AS dim_is_current
FROM warehouse.fact_orders f
JOIN warehouse.dim_product p
  ON f.product_sk = p.product_sk
JOIN warehouse.dim_date d
  ON f.date_sk = d.date_sk
WHERE p.product_name = 'Office Chair'
  AND p.brand = 'ErgoHome'
ORDER BY d.full_date;

