# Data documentation: Test data (CSV)

This document describes the **test datasets** located in `Data/Test data`. These CSV files represent a simplified operational dataset for a light transport equipment rental business and are intended for development, demos, and validating ETL/ELT logic.

## Location
- Folder: `Data/Test data`
- Format: CSV (header row included)

## Dataset overview

| File | Rows (approx.) | Primary key | Description                                   |
|---|---:|---|-----------------------------------------------|
| `Category.csv` | 4 | `category_id` | High-level product categories.                |
| `SubCategory.csv` | 8 | `subcategory_id` | Product subcategories.                        |
| `Item.csv` | 16 | `item_id` | Item models available for rent.               |
| `ItemInstance.csv` | 120 | `instance_id` | Physical inventory instances of item models.  |
| `Address.csv` | 84 | `address_id` | Address records (includes `country`, `city`). |
| `Location.csv` | 24 | `location_id` | Pickup/return locations (stores/stations).    |
| `Employee.csv` | 24 | `employee_id` | Employees assigned to stores.                 |
| `Customer.csv` | 60 | `customer_id` | Customers (private/corporate).                |
| `Rental.csv` | 550 | `rental_id` | Rental header transactions.                   |
| `RentalLineOrder.csv` | 550 | `rental_line_id` | Rental line transactions (per instance).      |


## Known characteristics / assumptions
- `Rental.start_date_time` spans **2026-01-01** to **2026-06-10** (based on file contents).

---

# Data documentation: Generated SQL data (CSV)

This section documents the **generated dataset** located in `Data/SQLData`. The files mirror the same logical entities as the smaller test dataset in `Data/Test data`, but at a much larger scale (e.g., 500k rentals) for performance/throughput testing and warehouse loading.

## Location
- Folder: `Data/SQLData`
- Archive copy: `Data/SQLData.zip`
- Format: CSV (header row included)

## What was generated (high level)
- **Customers:** 10,000 (8,316 `Private`, 1,684 `Corporate`)
- **Locations:** 36 (12 `Store`, 24 `Station`)
- **Employees:** 72
- **Product catalog:** 4 categories × 2 subcategories each; 64 item models total (16 per category)
- **Inventory:** 5,000 item instances (`Good`: 3,137; `Used`: 1,065; `New`: 575; `Needs service`: 223)
- **Transactions:** 500,000 rentals and 500,000 rental lines (effectively ~1 line per rental in this generated dataset)
- **Time span:** `Rental.start_date_time` from **2023-06-01 06:05:57** to **2026-05-31 23:54:25**
- **Rental statuses (counts):** `Completed` 410,535; `Returned Late` 34,453; `Cancelled` 25,011; `Extended` 20,020; `Active` 9,981

## Files and sizes

| File | Rows (approx.) | What it contains                                                            |
|---|---:|-----------------------------------------------------------------------------|
| `Category.csv` | 4 | Category names (e.g., Bicycles/Scooters/Kickboards/Mopeds).                 |
| `SubCategory.csv` | 8 | Two subcategories per category.                                             |
| `Item.csv` | 64 | Item models across all categories/subcategories.                            |
| `ItemInstance.csv` | 5,000 | Physical inventory instances with condition/status.                         |
| `Address.csv` | 10,036 | Address records used by customers and locations.                            |
| `Location.csv` | 36 | Stores and stations for pickup/return.                                      |
| `Employee.csv` | 72 | Employees assigned to stores.                                               |
| `Customer.csv` | 10,000 | Private and corporate customers.                                            |
| `Rental.csv` | 500,000 | Rental header transactions (timestamps, customer, employee, pickup/return). |
| `RentalLineOrder.csv` | 500,000 | Rental lines connecting rentals to item instances and prices.               |

## Known characteristics / assumptions
- This is a **larger-scale generated version** of the same business domain as `Data/Test data` (customers, inventory, rentals), intended for **load/performance testing**.
- In this generated dataset, `Rental.employee_id` appears to be **non-null for all rows**.

## Suggested ingestion / load order
Use the same load order as the test dataset:
1. `Category` → `SubCategory` → `Item` → `ItemInstance`
2. `Address` → `Location` → `Employee` and `Customer`
3. `Rental` → `RentalLineOrder`
