"""Danny's Diner: reproducible Pandas analysis.
Run from the project root: python python/analyze.py
Requires: pandas, matplotlib
"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUT = ROOT / "outputs"
OUT.mkdir(exist_ok=True)

sales = pd.read_csv(DATA / "sales.csv", parse_dates=["order_date"])
menu = pd.read_csv(DATA / "menu.csv")
members = pd.read_csv(DATA / "members.csv", parse_dates=["join_date"])

# Basic data quality checks
assert sales[["customer_id", "order_date", "product_id"]].notna().all().all()
assert menu["product_id"].is_unique
assert set(sales["product_id"]).issubset(set(menu["product_id"]))

orders = sales.merge(menu, on="product_id", how="left", validate="many_to_one")
orders["month"] = orders["order_date"].dt.to_period("M").astype(str)

customer_summary = (orders.groupby("customer_id", as_index=False)
    .agg(total_spent=("price", "sum"),
         items_purchased=("product_id", "size"),
         visit_days=("order_date", "nunique"),
         first_order=("order_date", "min"),
         last_order=("order_date", "max"))
    .sort_values("total_spent", ascending=False))
item_summary = (orders.groupby("product_name", as_index=False)
    .agg(items_sold=("product_id", "size"),
         revenue=("price", "sum"))
    .sort_values("items_sold", ascending=False))
monthly_revenue = (orders.groupby("month", as_index=False)
    .agg(revenue=("price", "sum"))
    .sort_values("month"))

member_orders = orders.merge(members, on="customer_id", how="left", validate="many_to_one")
member_orders["membership_status"] = "Non-member / no join date"
member_orders.loc[
    member_orders["join_date"].notna() & (member_orders["order_date"] >= member_orders["join_date"]),
    "membership_status"
] = "On/after membership"
member_orders.loc[
    member_orders["join_date"].notna() & (member_orders["order_date"] < member_orders["join_date"]),
    "membership_status"
] = "Before membership"
membership_summary = (member_orders.groupby("membership_status", as_index=False)
    .agg(items=("product_id", "size"), revenue=("price", "sum"),
         unique_customers=("customer_id", "nunique")))

customer_summary.to_csv(OUT / "customer_summary.csv", index=False)
item_summary.to_csv(OUT / "item_summary.csv", index=False)
monthly_revenue.to_csv(OUT / "monthly_revenue.csv", index=False)
membership_summary.to_csv(OUT / "membership_summary.csv", index=False)
orders.to_csv(OUT / "order_detail.csv", index=False)

# Chart 1: item popularity
ax = item_summary.sort_values("items_sold").plot(
    x="product_name", y="items_sold", kind="barh", legend=False,
    title="Danny's Diner — Items Sold")
ax.set_xlabel("Items sold")
ax.set_ylabel("Menu item")
plt.tight_layout()
plt.savefig(OUT / "items_sold.png", dpi=160)
plt.close()

# Chart 2: monthly revenue
ax = monthly_revenue.plot(x="month", y="revenue", marker="o", legend=False,
                          title="Danny's Diner — Monthly Revenue")
ax.set_xlabel("Month")
ax.set_ylabel("Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(OUT / "monthly_revenue.png", dpi=160)
plt.close()

print("Customer summary:")
print(customer_summary.to_string(index=False))
print("\\nItem summary:")
print(item_summary.to_string(index=False))
print("\\nMonthly revenue:")
print(monthly_revenue.to_string(index=False))
print("\\nMembership summary (descriptive only; not causal):")
print(membership_summary.to_string(index=False))
print(f"\\nFiles written to: {OUT}")
