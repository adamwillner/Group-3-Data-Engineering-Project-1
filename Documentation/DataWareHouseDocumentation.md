# Technical Documentation: RentalOrderDW

This document describes the technical solution and important decisions for the `RentalOrderDW` data warehouse.

## Architecture Diagram

The data warehouse uses a star schema with one central fact table and five dimension tables.

<img width="719" height="438" alt="DatawarehouseModel" src="https://github.com/user-attachments/assets/217461fb-c8e8-4d9b-bc76-4dae67f36ca8" />

## Database Schema

The following tables are included in the `RentalOrderDW` data warehouse.

| Table | Type | Primary Key | Operational Source Table(s) | Description |
|---|---|---|---|---|
| `DimLocation` | Dimension | `location_id` | `Location` | Stores location information used for rental and return locations. |
| `DimEmployee` | Dimension | `employee_id` | `Employee` | Stores employee information related to rental orders. |
| `DimDate` | Dimension | `date_id` | Generated from date values in `RentalOrder` | Stores reusable date attributes for reporting and filtering. |
| `DimItemInstance` | Dimension | `instance_id` | `ItemInstance`, `Item`, `Subcategory`, `Category` | Stores item instance details together with item, subcategory, and category information. |
| `DimCustomer` | Dimension | `customer_id` | `Customer` | Stores customer information related to rental orders. |
| `FactRentalLineOrder` | Fact | `rental_line_id` | `RentalLineOrder`, `RentalOrder` | Stores rental line order transactions, foreign keys to dimensions, and measurable values. |

---

## Dimension Table Descriptions

### `DimLocation`

The `DimLocation` table stores information about locations. It is used as a role-playing dimension because the same table is used for both rental locations and return locations.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `location_id` | Unique identifier for the location. Primary key in the dimension table. | `Location` | `location_id` |
| Location attributes | Descriptive information about the location, such as location name or address. | `Location` | Location-related columns |

#### Used by fact table columns

| Fact Column | References | Description |
|---|---|---|
| `rental_location_id` | `DimLocation(location_id)` | Identifies the location where the rental started. |
| `return_location_id` | `DimLocation(location_id)` | Identifies the location where the rental was returned. |

---

### `DimEmployee`

The `DimEmployee` table stores information about employees involved in rental orders.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `employee_id` | Unique identifier for the employee. Primary key in the dimension table. | `Employee` | `employee_id` |
| Employee attributes | Descriptive information about the employee, such as name or role. | `Employee` | Employee-related columns |

---

### `DimDate`

The `DimDate` table stores date attributes used for reporting and analysis. It is reused for multiple date roles in the fact table.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `date_id` | Unique identifier for the date. Primary key in the dimension table. Usually stored as a date key. | Generated from rental date fields | Generated value |
| Date attributes | Descriptive date information such as day, month, year, weekday, or quarter. | Generated from rental date fields | Date values from rental-related columns |

#### Used by fact table columns

| Fact Column | References | Description |
|---|---|---|
| `start_date_id` | `DimDate(date_id)` | Identifies the rental start date. |
| `return_date_id` | `DimDate(date_id)` | Identifies the date when the rental was returned. |
| `end_date_id` | `DimDate(date_id)` | Identifies the planned or actual rental end date. |

---

### `DimItemInstance`

The `DimItemInstance` table stores information about item instances and includes related item, subcategory, and category information in the same dimension table.

This denormalized design makes reporting easier because users can analyze rentals by item instance, item, subcategory, or category without joining multiple dimension tables.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `instance_id` | Unique identifier for the item instance. Primary key in the dimension table. | `ItemInstance` | `instance_id` |
| Item instance attributes | Descriptive information about the specific item instance. | `ItemInstance` | Item instance-related columns |
| Item attributes | Information about the item connected to the item instance. | `Item` | Item-related columns |
| Subcategory attributes | Information about the item subcategory. | `Subcategory` | Subcategory-related columns |
| Category attributes | Information about the item category. | `Category` | Category-related columns |

---

### `DimCustomer`

The `DimCustomer` table stores customer information used to analyze rental activity by customer.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `customer_id` | Unique identifier for the customer. Primary key in the dimension table. | `Customer` | `customer_id` |
| Customer attributes | Descriptive information about the customer, such as name or contact details. | `Customer` | Customer-related columns |

---

## Fact Table Description

### `FactRentalLineOrder`

The `FactRentalLineOrder` table stores the measurable rental line order events. The grain of the table is one row per rental line order.

| Column | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|
| `rental_line_id` | Unique identifier for the rental line order. Primary key in the fact table. | `RentalLineOrder` | `rental_line_id` |
| `customer_id` | Foreign key to `DimCustomer`. Identifies the customer connected to the rental order. | `RentalOrder` | `customer_id` |
| `employee_id` | Foreign key to `DimEmployee`. Identifies the employee connected to the rental order. | `RentalOrder` | `employee_id` |
| `instance_id` | Foreign key to `DimItemInstance`. Identifies the rented item instance. | `RentalLineOrder` | `instance_id` |
| `rental_location_id` | Foreign key to `DimLocation`. Identifies where the rental started. | `RentalOrder` | `rental_location_id` |
| `return_location_id` | Foreign key to `DimLocation`. Identifies where the rental was returned. | `RentalOrder` | `return_location_id` |
| `start_date_id` | Foreign key to `DimDate`. Identifies the rental start date. | `RentalOrder` | Start date column |
| `return_date_id` | Foreign key to `DimDate`. Identifies the rental return date. | `RentalOrder` | Return date column |
| `end_date_id` | Foreign key to `DimDate`. Identifies the rental end date. | `RentalOrder` | End date column |
| `rental_count` | Measure used to count rental line orders. Always has the value `1`. | Calculated in ETL | Static calculated value |
| `rental_amount` | Measure representing the total rental amount. | `RentalOrder` / `RentalLineOrder` | Amount-related columns |
| `rental_duration_minutes` | Measure representing the duration of the rental in minutes. | Calculated in ETL | Based on rental start and return/end date values |

---

## Fact Table Grain

The grain of `FactRentalLineOrder` is:

> One row per rental line order.

Each fact row connects one rental line to:

- One customer
- One employee
- One item instance
- One rental location
- One return location
- One start date
- One return date
- One end date

## Main Measures

| Measure | Description |
|---|---|
| `rental_count` | For counting rental line orders. Always `1`. |
| `rental_amount` | Total amount cost for the whole rental including many rental lines. |
| `rental_duration_minutes` | Duration of the rental in minutes. |

## Foreign Key Relationships

| Fact Column | References |
|---|---|
| `start_date_id` | `DimDate(date_id)` |
| `return_date_id` | `DimDate(date_id)` |
| `end_date_id` | `DimDate(date_id)` |
| `customer_id` | `DimCustomer(customer_id)` |
| `employee_id` | `DimEmployee(employee_id)` |
| `rental_location_id` | `DimLocation(location_id)` |
| `return_location_id` | `DimLocation(location_id)` |
| `instance_id` | `DimItemInstance(instance_id)` |

## Important Technical Decisions and Changes

- The warehouse uses a star schema to make reporting simpler and improve query performance.
- `FactRentalLineOrder` is the central fact table because rental line orders contain the measurable business events.
- Dimension tables are denormalized to reduce the number of joins needed in reports.
- `DimItemInstance` includes item, subcategory, and category information in one dimension.
- `DimDate` is reused as a role-playing dimension for start date, return date, and end date.
- `DimLocation` is reused as a role-playing dimension for rental location and return location.
- Calculated values such as `rental_amount` and `rental_duration_minutes` are stored in the fact table to simplify analysis.
