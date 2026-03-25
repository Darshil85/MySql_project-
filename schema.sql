-- Create Database
CREATE DATABASE dannydiner;
USE dannydiner;

-- Create Sales Table
CREATE TABLE sales (
  customer_id VARCHAR(10),
  order_date DATE,
  product_id INT
);

-- Insert Sales Data
INSERT INTO sales (customer_id, order_date, product_id) VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

-- Create Menu Table
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(10),
  price INT
);

-- Insert Menu Data
INSERT INTO menu VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);

-- Create Members Table
CREATE TABLE members (
  customer_id VARCHAR(10),
  join_date DATE
);

-- Insert Members Data
INSERT INTO members VALUES
('A', '2021-01-07'),
('B', '2021-01-09');
