# Data documentation: Rental operational data (CSV)

This document describes the CSV datasets used for the light transport equipment rental operational database. The datasets represent rental locations, customers, employees, equipment categories, item models, physical inventory, rental transactions, and rental line orders.

The documentation is split into two parts:

- **Test data**: a smaller dataset intended for development, demos, and ETL/ELT validation.
- **Generated SQL data**: a larger generated dataset intended for performance testing, throughput testing, and warehouse loading.

---

# Data documentation: Test data (CSV)

This document describes the **test datasets** located in `Data/Test data`. These CSV files represent a simplified operational dataset for a light transport equipment rental business and are intended for development, demos, and validating ETL/ELT logic.

## Location

- Folder: `Data/Test data`
- Format: CSV (header row included)

## Dataset overview

| File | Rows (approx.) | Primary key | Description |
|---|---:|---|---|
| `Category.csv` | 4 | `category_id` | High-level product categories. |
| `SubCategory.csv` | 8 | `subcategory_id` | Product subcategories. |
| `Item.csv` | 16 | `item_id` | Item models available for rent. |
| `ItemInstance.csv` | 120 | `instance_id` | Physical inventory instances of item models. |
| `Address.csv` | 84 | `address_id` | Address records (includes `country`, `city`). |
| `Location.csv` | 24 | `location_id` | Pickup/return locations (stores/stations). |
| `Employee.csv` | 24 | `employee_id` | Employees assigned to stores. |
| `Customer.csv` | 60 | `customer_id` | Customers (private/corporate). |
| `Rental.csv` | 550 | `rental_id` | Rental header transactions. |
| `RentalLineOrder.csv` | 550 | `rental_line_id` | Rental line transactions (per instance). |

## Known characteristics / assumptions

- `Rental.start_date_time` spans **2026-01-01** to **2026-06-10** (based on file contents).

---

# Data documentation: Generated SQL data (CSV)

This section documents the **generated dataset** located in `Data/SQLData`. The files mirror the same logical entities as the smaller test dataset in `Data/Test data`, but at a much larger scale (e.g., 500k rentals) for performance/throughput testing and warehouse loading.

## Location

- Folder: `Data/SQLData`
- Archive copy: `Data/SQLData.zip`
- Format: CSV (header row included)

## Dataset overview

| File | Rows (approx.) | What it contains |
|---|---:|---|
| `Category.csv` | 4 | Category names for light transport rental equipment. |
| `SubCategory.csv` | 10 | Equipment subcategories linked to categories. |
| `Item.csv` | 150 | Item models across all categories/subcategories. |
| `ItemInstance.csv` | 4,467 | Physical inventory instances with condition/status. |
| `Address.csv` | 2,524 | Address records used by customers and locations. |
| `Location.csv` | 24 | Stores and stations for pickup/return. |
| `Employee.csv` | 120 | Employees assigned to locations. |
| `Customer.csv` | 2,500 | Private and corporate customers. |
| `Rental.csv` | 500,000 | Rental header transactions (timestamps, customer, employee, pickup/return). |
| `RentalLineOrder.csv` | 825,003 | Rental lines connecting rentals to item instances and prices. |

## Known characteristics / assumptions

- This is a **larger-scale generated version** of the same business domain as `Data/Test data`, intended for **load/performance testing**.
- Some rentals contain **multiple rental lines**, meaning one rental transaction can include more than one physical equipment item.
- `Rental.employee_id` can be **null** when no employee was assigned.
- `Rental.return_date_time` can be **null** for `Cancelled`, `Overdue`, and `Active` rentals.
- `Completed` rentals have a non-null `return_date_time`.
- `Overdue` rentals have a null `return_date_time` and an `end_date_time` before the current reference date.
- `Active` rentals have a null `return_date_time` and an `end_date_time` on or after the current reference date.
- `Cancelled` rentals have a null `return_date_time` and zero rental line charges.
- `ItemInstance.item_status` is non-null for all rows and contains only `0` or `1`.

## Suggested ingestion / load order

Use the same load order as the test dataset:

1. `Category` → `SubCategory` → `Item` → `ItemInstance`
2. `Address` → `Location` → `Employee` and `Customer`
3. `Rental` → `RentalLineOrder`
