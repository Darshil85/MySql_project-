# 🍽️ Danny's Diner SQL Case Study

## 📌 Project Overview

This project analyzes customer behavior, sales trends, and membership impact using SQL.

The dataset consists of 3 tables:

* **sales**: customer orders
* **menu**: product details
* **members**: membership join dates

---

## 🗂️ Database Schema

### 1. Sales Table

| Column      | Type    |
| ----------- | ------- |
| customer_id | VARCHAR |
| order_date  | DATE    |
| product_id  | INT     |

### 2. Menu Table

| Column       | Type    |
| ------------ | ------- |
| product_id   | INT     |
| product_name | VARCHAR |
| price        | INT     |

### 3. Members Table

| Column      | Type    |
| ----------- | ------- |
| customer_id | VARCHAR |
| join_date   | DATE    |

---

## 🧪 SQL Questions & Solutions

### 1. Total amount spent by each customer

```sql
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

### 2. Number of days each customer visited

```sql
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;
```

### 3. First item purchased by each customer

```sql
WITH ranked_orders AS (
    SELECT s.customer_id, m.product_name,
           ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ranked_orders
WHERE rn = 1;
```

### 4. Most purchased item overall

```sql
SELECT m.product_name, COUNT(*) AS total_orders
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_orders DESC
LIMIT 1;
```

### 5. Most popular item per customer

```sql
WITH order_counts AS (
    SELECT s.customer_id, m.product_name, COUNT(*) AS order_count
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
), ranked_items AS (
    SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY order_count DESC) AS rnk
    FROM order_counts
)
SELECT customer_id, product_name
FROM ranked_items
WHERE rnk = 1;
```

---

## 📊 Key Insights

* Customer A spent the most overall.
* Sushi generates the highest revenue per order.
* Membership increases customer purchase frequency.
* Ramen is the most frequently ordered item.

---

## 🛠️ Skills Demonstrated

* SQL Joins
* Aggregations (SUM, COUNT)
* Window Functions (ROW_NUMBER, RANK)
* Common Table Expressions (CTE)
* Business Problem Solving

---

## 🚀 How to Run

1. Create database: `CREATE DATABASE dannydiner;`
2. Create tables and insert data
3. Run queries in MySQL / PostgreSQL

---

## 📌 Future Improvements

* Add Power BI dashboard
* Add Python analysis (Pandas)
* Optimize queries for large datasets

---

## ⭐ Author

Darshil Kumar
