# Danny's Diner — SQL + Python + Power BI Analytics

A portfolio-ready extension of the Danny's Diner SQL case study using MySQL 8.0, Pandas, and Power BI.

## Project contents
- `data/`: sample sales, menu, and membership CSV files
- `sql/dannys_diner.sql`: schema, sample data, indexes, and corrected analytical queries
- `python/analyze.py`: reproducible Pandas analysis, data checks, summary CSVs, and charts
- `powerbi/DASHBOARD_GUIDE.md`: steps to build the Power BI report and suggested measures
- `outputs/`: generated analysis outputs (created by the Python script)

## Run locally
1. Install Python 3.10+.
2. In a terminal at the project root:
   ```bash
   pip install -r requirements.txt
   python python/analyze.py
   ```
3. Run `sql/dannys_diner.sql` in MySQL Workbench 8.0.
4. Follow `powerbi/DASHBOARD_GUIDE.md` to build the dashboard in Power BI Desktop.

## Analytical questions
- How much did each customer spend?
- How many distinct visit days and items did each customer have?
- Which menu items sold most often and generated the most revenue?
- How did revenue vary by month?
- What purchases occurred before and after membership?

## SQL and data-quality improvements
- Primary keys for menu, members, and each sale row.
- Foreign key from sales to menu.
- Indexes for customer/date, date, and product/date access patterns.
- Window functions and CTEs where they improve clarity.
- Tie-aware queries for first purchases and most popular items.
- Deterministic running totals using `sale_id`.
- Uses `COUNT(DISTINCT order_date)` for visit days rather than counting every item row.

Indexes should be validated against real data and query plans (`EXPLAIN ANALYZE`) before assuming they improve performance. For this tiny sample, performance differences will be negligible.

## Sample-data caveat
This is a small teaching dataset (15 item-level sale rows). Results are illustrative, not statistically representative. A customer's multiple items on one date count as multiple sales rows but one visit day. Membership correlation is not causal evidence.

## Resume bullet (use only after you run and understand the project)
Built a customer-sales analytics project using MySQL and Pandas; analyzed spending, item popularity, monthly revenue, and membership-period purchases, and prepared Power BI dashboard specifications with KPI and trend visualizations.
