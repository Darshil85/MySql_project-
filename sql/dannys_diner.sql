-- Danny's Diner analytics schema and optimized queries
-- Target: MySQL 8.0+
CREATE DATABASE IF NOT EXISTS dannydiner;
USE dannydiner;

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS menu;

CREATE TABLE menu (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(50) NOT NULL UNIQUE,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE members (
  customer_id VARCHAR(10) PRIMARY KEY,
  join_date DATE NOT NULL
);

CREATE TABLE sales (
  sale_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id VARCHAR(10) NOT NULL,
  order_date DATE NOT NULL,
  product_id INT NOT NULL,
  CONSTRAINT fk_sales_menu FOREIGN KEY (product_id) REFERENCES menu(product_id)
);

-- Load menu and members before sales when using foreign keys.
INSERT INTO menu VALUES (1,'sushi',10.00),(2,'curry',15.00),(3,'ramen',12.00);
INSERT INTO members VALUES ('A','2021-01-07'),('B','2021-01-09');

INSERT INTO sales (customer_id, order_date, product_id) VALUES
('A','2021-01-01',1),('A','2021-01-01',2),('A','2021-01-07',2),
('A','2021-01-10',3),('A','2021-01-11',3),('A','2021-01-11',3),
('B','2021-01-01',2),('B','2021-01-02',2),('B','2021-01-04',1),
('B','2021-01-11',1),('B','2021-01-16',3),('B','2021-02-01',3),
('C','2021-01-01',3),('C','2021-01-01',3),('C','2021-01-07',3);

-- Indexes: support customer/date lookups, date filtering, and product joins.
CREATE INDEX idx_sales_customer_date ON sales(customer_id, order_date);
CREATE INDEX idx_sales_order_date ON sales(order_date);
CREATE INDEX idx_sales_product_date ON sales(product_id, order_date);

-- 1. Total amount spent by customer
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales s JOIN menu m ON m.product_id = s.product_id
GROUP BY s.customer_id ORDER BY total_spent DESC;

-- 2. Distinct visit days vs individual items purchased
SELECT customer_id,
       COUNT(DISTINCT order_date) AS visit_days,
       COUNT(*) AS items_purchased
FROM sales GROUP BY customer_id;

-- 3. First item(s) purchased on the customer's earliest date (preserves ties)
WITH first_dates AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM sales GROUP BY customer_id
)
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN first_dates f ON f.customer_id=s.customer_id AND f.first_order_date=s.order_date
JOIN menu m ON m.product_id=s.product_id
ORDER BY s.customer_id, m.product_name;

-- 4. Most purchased item overall (returns ties)
WITH item_counts AS (
  SELECT m.product_name, COUNT(*) AS total_orders
  FROM sales s JOIN menu m ON m.product_id=s.product_id
  GROUP BY m.product_id, m.product_name
)
SELECT product_name, total_orders
FROM item_counts
WHERE total_orders = (SELECT MAX(total_orders) FROM item_counts);

-- 5. Most popular item per customer (returns ties)
WITH item_counts AS (
  SELECT s.customer_id, m.product_name, COUNT(*) AS order_count
  FROM sales s JOIN menu m ON m.product_id=s.product_id
  GROUP BY s.customer_id, m.product_id, m.product_name
), ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_count DESC) AS rnk
  FROM item_counts
)
SELECT customer_id, product_name, order_count
FROM ranked WHERE rnk=1 ORDER BY customer_id;

-- 6. First purchase on/after membership date
WITH ranked AS (
  SELECT s.customer_id, s.order_date, m.product_name,
         ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date, s.sale_id) AS rn
  FROM sales s
  JOIN members mb ON mb.customer_id=s.customer_id AND s.order_date >= mb.join_date
  JOIN menu m ON m.product_id=s.product_id
)
SELECT customer_id, order_date, product_name FROM ranked WHERE rn=1;

-- 7. Last purchase before membership date (not on the join date)
WITH latest_pre_member AS (
  SELECT s.customer_id, MAX(s.order_date) AS last_order_date
  FROM sales s JOIN members mb ON mb.customer_id=s.customer_id
  WHERE s.order_date < mb.join_date
  GROUP BY s.customer_id
)
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN latest_pre_member p ON p.customer_id=s.customer_id AND p.last_order_date=s.order_date
JOIN menu m ON m.product_id=s.product_id
ORDER BY s.customer_id;

-- 8. Items and spend before membership
SELECT s.customer_id, COUNT(*) AS items_before_membership,
       SUM(m.price) AS spend_before_membership
FROM sales s
JOIN members mb ON mb.customer_id=s.customer_id AND s.order_date < mb.join_date
JOIN menu m ON m.product_id=s.product_id
GROUP BY s.customer_id;

-- 9. Points: $1 = 10 points, sushi earns 2x points
SELECT s.customer_id,
       SUM(CASE WHEN m.product_name='sushi' THEN m.price*20 ELSE m.price*10 END) AS points
FROM sales s JOIN menu m ON m.product_id=s.product_id
GROUP BY s.customer_id;

-- 10. Monthly revenue
SELECT DATE_FORMAT(s.order_date, '%Y-%m') AS month,
       SUM(m.price) AS revenue
FROM sales s JOIN menu m ON m.product_id=s.product_id
GROUP BY DATE_FORMAT(s.order_date, '%Y-%m')
ORDER BY month;

-- 11. Latest purchase date per customer (if multiple items on that date, returns all)
WITH latest_dates AS (
  SELECT customer_id, MAX(order_date) AS latest_order_date
  FROM sales GROUP BY customer_id
)
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN latest_dates d ON d.customer_id=s.customer_id AND d.latest_order_date=s.order_date
JOIN menu m ON m.product_id=s.product_id
ORDER BY s.customer_id, m.product_name;

-- 12. Running spend by customer. sale_id provides deterministic row ordering.
SELECT s.customer_id, s.order_date, s.sale_id, m.product_name, m.price,
       SUM(m.price) OVER (
         PARTITION BY s.customer_id ORDER BY s.order_date, s.sale_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_spend
FROM sales s JOIN menu m ON m.product_id=s.product_id
ORDER BY s.customer_id, s.order_date, s.sale_id;
