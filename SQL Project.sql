use project;

SET FOREIGN_KEY_CHECKS = 0;
SET sql_safe_updates = 0;

CREATE TABLE IF NOT EXISTS dim_category (
  category_id   INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  UNIQUE KEY uq_category_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS dim_sub_category (
  sub_category_id   INT AUTO_INCREMENT PRIMARY KEY,
  category_id       INT NOT NULL,
  sub_category_name VARCHAR(50) NOT NULL,
  UNIQUE KEY uq_cat_sub (category_id, sub_category_name),
  CONSTRAINT fk_subcat_category
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS dim_location (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  continent   VARCHAR(50),
  country     VARCHAR(80),
  state       VARCHAR(120),
  city        VARCHAR(120),
  UNIQUE KEY uq_loc (continent, country, state, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS dim_product (
  product_sk      INT AUTO_INCREMENT PRIMARY KEY,
  product_id      VARCHAR(30)  NOT NULL,  -- e.g., 'OFF-LA-4658'
  product_name    VARCHAR(255) NOT NULL,
  sub_category_id INT NOT NULL,
  UNIQUE KEY uq_product_id (product_id),
  CONSTRAINT fk_prod_subcat
    FOREIGN KEY (sub_category_id) REFERENCES dim_sub_category(sub_category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

START TRANSACTION;

INSERT INTO dim_category (category_name)
SELECT DISTINCT TRIM(s.`Category`) AS category_name
FROM sales s
LEFT JOIN dim_category dc
  ON dc.category_name = TRIM(s.`Category`)
WHERE s.`Category` IS NOT NULL
  AND TRIM(s.`Category`) <> ''
  AND dc.category_id IS NULL;

INSERT INTO dim_sub_category (category_id, sub_category_name)
SELECT DISTINCT dc.category_id, TRIM(s.`Sub-Category`) AS sub_category_name
FROM sales s
JOIN dim_category dc
  ON dc.category_name = TRIM(s.`Category`)
LEFT JOIN dim_sub_category dsc
  ON dsc.category_id = dc.category_id
 AND dsc.sub_category_name = TRIM(s.`Sub-Category`)
WHERE s.`Sub-Category` IS NOT NULL
  AND TRIM(s.`Sub-Category`) <> ''
  AND dsc.sub_category_id IS NULL;
  
  INSERT INTO dim_location (continent, country, state, city)
SELECT DISTINCT
  TRIM(s.`Continent`),
  TRIM(s.`Country`),
  TRIM(s.`State`),
  TRIM(s.`City`)
FROM sales s
LEFT JOIN dim_location dl
  ON dl.continent = TRIM(s.`Continent`)
 AND dl.country   = TRIM(s.`Country`)
 AND dl.`state`   = TRIM(s.`State`)
 AND dl.city      = TRIM(s.`City`)
WHERE s.`Continent` IS NOT NULL
  AND TRIM(s.`Continent`) <> ''
  AND dl.location_id IS NULL;
  
  INSERT INTO dim_product (product_id, product_name, sub_category_id)
SELECT DISTINCT
  TRIM(s.`Product ID`)   AS product_id,
  TRIM(s.`Product Name`) AS product_name,
  dsc.sub_category_id
FROM sales s
JOIN dim_category dc
  ON dc.category_name = TRIM(s.`Category`)
JOIN dim_sub_category dsc
  ON dsc.category_id = dc.category_id
 AND dsc.sub_category_name = TRIM(s.`Sub-Category`)
LEFT JOIN dim_product dp
  ON dp.product_id = TRIM(s.`Product ID`)
WHERE TRIM(s.`Product ID`) <> ''
  AND dp.product_sk IS NULL;
  
  COMMIT;


CREATE TABLE IF NOT EXISTS fact_transaction (
  fact_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  row_id         INT,
  order_id       VARCHAR(50),
  order_date     DATE,
  ship_date      DATE,
  ship_mode      VARCHAR(50),
  customer_segment VARCHAR(50),
  order_priority VARCHAR(30),

  product_sk     INT NOT NULL,
  location_id    INT NOT NULL,

  quantity       INT,
  unit_price     DECIMAL(10,2),
  discount_pct   DECIMAL(6,3),         -- store percent as 0-100
  unit_mfg_cost  DECIMAL(10,2),
  unit_ship_cost DECIMAL(10,2),

  gross_revenue  DECIMAL(12,2),        -- qty * unit_price
  net_revenue    DECIMAL(12,2),        -- qty * unit_price * (1 - pct/100)
  profit         DECIMAL(12,2),        -- net - qty*(mfg+ship)
  return_flag    TINYINT(1) DEFAULT 0,

  CONSTRAINT fk_fact_product
    FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_fact_location
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO fact_transaction (
  row_id, order_id, order_date, ship_date, ship_mode, customer_segment, order_priority,
  product_sk, location_id, quantity, unit_price, discount_pct, unit_mfg_cost, unit_ship_cost,
  gross_revenue, net_revenue, profit, return_flag
)
SELECT
  s.`Row ID`,
  s.`Order ID`,
  STR_TO_DATE(s.`Order Date`, '%m/%d/%Y') AS order_date,
  STR_TO_DATE(s.`Ship Date`, '%m/%d/%Y')  AS ship_date,
  TRIM(s.`Ship Mode`),
  TRIM(s.`Customer Segment`),
  TRIM(s.`Order Priority`),

  dp.product_sk,
  dl.location_id,

  s.`Quantity`,
  ROUND(s.`Unit Price ($)`, 2),
  s.`Discount (%)`,
  ROUND(s.`Unit Manufacturing Cost ($)`, 2),
  ROUND(s.`Unit Shipping Cost ($)`, 2),

  -- gross, net, profit
  ROUND(s.`Quantity` * s.`Unit Price ($)`, 2) AS gross_revenue,
  ROUND(s.`Quantity` * (s.`Unit Price ($)` * (1 - s.`Discount (%)`/100)), 2) AS net_revenue,
  ROUND(
    s.`Quantity` * (s.`Unit Price ($)` * (1 - s.`Discount (%)`/100))
    - s.`Quantity` * (s.`Unit Manufacturing Cost ($)` + s.`Unit Shipping Cost ($)`),
    2
  ) AS profit,

  0 AS return_flag
FROM sales s
JOIN dim_category dc
  ON dc.category_name = TRIM(s.`Category`)
JOIN dim_sub_category dsc
  ON dsc.category_id = dc.category_id
 AND dsc.sub_category_name = TRIM(s.`Sub-Category`)
JOIN dim_product dp
  ON dp.product_id = TRIM(s.`Product ID`)
 AND dp.sub_category_id = dsc.sub_category_id
JOIN dim_location dl
  ON dl.continent = TRIM(s.`Continent`)
 AND dl.country   = TRIM(s.`Country`)
 AND dl.`state`   = TRIM(s.`State`)
 AND dl.city      = TRIM(s.`City`);
 
 DROP PROCEDURE IF EXISTS sp_set_returns;
DELIMITER //
CREATE PROCEDURE sp_set_returns()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name   = 'return_table'
  ) THEN
    UPDATE fact_transaction f
    JOIN return_table r
      ON r.`Order ID` = f.order_id
     AND r.`Returned` = 'Yes'
    SET f.return_flag = 1;
  END IF;
END//
DELIMITER ;

CALL sp_set_returns();
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM dim_category;
select* from fact_transaction;