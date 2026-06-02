# Technical Documentation: RentalOrderDW

This document describes the technical solution and important decisions for the `RentalOrderDW` data warehouse.

## Architecture Diagram

The data warehouse uses a star schema with one central fact table and five dimension tables.

<img width="719" height="438" alt="DatawarehouseModel" src="https://github.com/user-attachments/assets/217461fb-c8e8-4d9b-bc76-4dae67f36ca8" />

## Database Schema

Database name: `RentalOrderDW`

The `RentalOrderDW` database uses a star schema with one central fact table and five dimension tables. Dimension tables store descriptive information, while the fact table stores rental line order transactions, foreign keys, and measures.

| Table | Type | Primary Key | Operational Source Table(s) | Description |
|---|---|---|---|---|
| `DimLocation` | Dimension | `location_id` | `Location`, `Address`, `City`, `Country` | Stores rental and return location information, including address, city, country, and location name. |
| `DimEmployee` | Dimension | `employee_id` | `Employee`, `Location` | Stores employee information and the location connected to the employee. |
| `DimDate` | Dimension | `date_id` | Generated from rental date values | Stores date attributes used for filtering, grouping, and reporting. |
| `DimItemInstance` | Dimension | `instance_id` | `ItemInstance`, `Item`, `Subcategory`, `Category` | Stores item instance, item, subcategory, and category information in one denormalized dimension. |
| `DimCustomer` | Dimension | `customer_id` | `Customer`, `Address`, `City`, `Country`, `CustomerType` | Stores customer information, including address and customer type. |
| `FactRentalLineOrder` | Fact | `rental_line_id` | `RentalLineOrder`, `RentalOrder` | Stores rental line order transactions, foreign keys to dimensions, and calculated measures. |

---

## Dimension Table Descriptions

### `DimLocation`

The `DimLocation` table stores information about locations. It is used as a role-playing dimension because the same dimension is used for both rental locations and return locations in the fact table.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `location_id` | `INT IDENTITY(1,1)` | Surrogate primary key for the location dimension. | Generated in data warehouse | Generated key |
| `location_type` | `NVARCHAR(50)` | Describes the type of location. | `Location` | `location_type` |
| `address_id` | `INT` | Identifier for the address connected to the location. | `Address` | `address_id` |
| `address` | `NVARCHAR(50)` | Street address of the location. | `Address` | `address` |
| `city` | `NVARCHAR(50)` | City where the location is located. | `Address` | `city` |
| `country` | `NVARCHAR(50)` | Country where the location is located. | `Address` | `country` |
| `location_name` | `NVARCHAR(50)` | Name of the rental or return location. | `Location` | `location_name` |
| `alt_location_key` | `INT` | Alternative key from the operational database, used to trace the dimension row back to the source system. | `Location` | Original location key |

#### Used by fact table columns

| Fact Column | References | Description |
|---|---|---|
| `rental_location_id` | `DimLocation(location_id)` | Identifies the location where the rental started. |
| `return_location_id` | `DimLocation(location_id)` | Identifies the location where the rental was returned. |

---

### `DimEmployee`

The `DimEmployee` table stores information about employees and the location connected to each employee.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `employee_id` | `INT IDENTITY(1,1)` | Surrogate primary key for the employee dimension. | Generated in data warehouse | Generated key |
| `employee_name` | `NVARCHAR(50)` | Name of the employee. | `Employee` | `employee_name` |
| `location_id` | `INT` | Identifier for the location connected to the employee. | `Location` | `location_id` |
| `location_name` | `NVARCHAR(50)` | Name of the employee's location. | `Location` | `location_name` |
| `alt_employee_key` | `INT` | Alternative key from the operational database, used to trace the dimension row back to the source system. | `Employee` | Original employee key |

---

### `DimDate`

The `DimDate` table stores reusable date attributes. It is used as a role-playing dimension for start date, return date, and end date.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `date_id` | `INT` | Primary key for the date dimension. Usually formatted as a date key, for example `YYYYMMDD`. | Generated from rental date values | Generated date key |
| `date` | `DATE` | Full date value. | Generated from rental date values | Rental date fields |
| `day` | `NVARCHAR(20)` | Day value or day name used for reporting. | Generated from `date` | Generated date attribute |
| `month_number` | `INT` | Numeric month value. | Generated from `date` | Generated date attribute |
| `month_name` | `NVARCHAR(20)` | Name of the month. | Generated from `date` | Generated date attribute |
| `year` | `INT` | Year value. | Generated from `date` | Generated date attribute |

#### Used by fact table columns

| Fact Column | References | Description |
|---|---|---|
| `start_date_id` | `DimDate(date_id)` | Identifies the date when the rental started. |
| `return_date_id` | `DimDate(date_id)` | Identifies the date when the rental was returned. |
| `end_date_id` | `DimDate(date_id)` | Identifies the planned or actual rental end date. |

---

### `DimItemInstance`

The `DimItemInstance` table stores item instance information together with item, subcategory, and category information. This denormalized design reduces the number of joins needed in reports.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `instance_id` | `INT IDENTITY(1,1)` | Surrogate primary key for the item instance dimension. | Generated in data warehouse | Generated key |
| `item_state` | `NVARCHAR(50)` | Describes the current state or condition of the item instance. | `ItemInstance` | `item_state` |
| `distance_km` | `FLOAT` | Distance value connected to the item instance. | `ItemInstance` | `distance_km` |
| `item_id` | `INT` | Identifier for the item connected to the item instance. | `Item` | `item_id` |
| `model_name` | `NVARCHAR(50)` | Model name of the item. | `Item` | `model_name` |
| `item_status` | `BIT` | Status of the item, for example active or inactive. | `ItemInstance` | `item_status` |
| `subcategory_id` | `INT` | Identifier for the subcategory connected to the item. | `Subcategory` | `subcategory_id` |
| `subcat_description` | `NVARCHAR(50)` | Description of the item subcategory. | `Subcategory` | `subcat_description` |
| `category_id` | `INT` | Identifier for the category connected to the subcategory. | `Category` | `category_id` |
| `cat_description` | `NVARCHAR(50)` | Description of the item category. | `Category` | `cat_description` |
| `alt_instance_key` | `INT` | Alternative key from the operational database, used to trace the dimension row back to the source system. | `ItemInstance` | Original instance key |

---

### `DimCustomer`

The `DimCustomer` table stores customer information, including address and customer type.

> Note: The column names `adress_id` and `adress` are written this way because that is how they appear in the SQL table definition.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `customer_id` | `INT IDENTITY(1,1)` | Surrogate primary key for the customer dimension. | Generated in data warehouse | Generated key |
| `customer_name` | `NVARCHAR(50)` | Name of the customer. | `Customer` | `name` |
| `adress_id` | `INT` | Identifier for the customer's address. | `Address` | `address_id` |
| `adress` | `NVARCHAR(50)` | Street address of the customer. | `Address` | `address` |
| `city` | `NVARCHAR(50)` | City where the customer is located. | `Address` | `city` |
| `country` | `NVARCHAR(50)` | Country where the customer is located. | `Address` | `country` |
| `customer_type` | `NVARCHAR(50)` | Type or classification of the customer. | `CustomerType` | `customer_type` |
| `alt_customer_key` | `INT` | Alternative key from the operational database, used to trace the dimension row back to the source system. | `Customer` | Original customer key |

---

## Fact Table Description

### `FactRentalLineOrder`

The `FactRentalLineOrder` table stores measurable rental line order events. The grain of the table is one row per rental line order.

| Column | Data Type | Description | Operational Source Table | Operational Source Column |
|---|---|---|---|---|
| `rental_line_id` | `INT IDENTITY(1,1)` | Surrogate primary key for the fact table. | Generated in data warehouse | Generated key |
| `rental_id` | `INT` | Identifier for the rental order connected to the rental line. | `Rental` | `rental_id` |
| `rental_status` | `NVARCHAR(50)` | Status of the rental order. | `Rental` | `rental_status` |
| `price_paid` | `DECIMAL(10,2)` | Price paid for the rental line. | `RentalLineOrder` | `price_paid` |
| `discount_offered` | `FLOAT` | Discount offered for the rental line. | `RentalLineOrder` | `discount_offered` |
| `start_date_id` | `INT` | Foreign key to `DimDate`. Identifies the rental start date. | `Rental` | `start_date_id` |
| `return_date_id` | `INT` | Foreign key to `DimDate`. Identifies the rental return date. | `Rental` | `return_date_id`  |
| `end_date_id` | `INT` | Foreign key to `DimDate`. Identifies the rental end date. | `Rental` |`end_date_id` |
| `customer_id` | `INT` | Foreign key to `DimCustomer`. Identifies the customer connected to the rental. | `Customer` | `customer_id` |
| `employee_id` | `INT` | Foreign key to `DimEmployee`. Identifies the employee connected to the rental. | `Employee` | `employee_id` |
| `rental_location_id` | `INT` | Foreign key to `DimLocation`. Identifies where the rental started. | `Location` | `rental_location_id` |
| `return_location_id` | `INT` | Foreign key to `DimLocation`. Identifies where the rental was returned. | `Location` | `return_location_id` |
| `instance_id` | `INT` | Foreign key to `DimItemInstance`. Identifies the rented item instance. | `ItemInstance` | `instance_id` |
| `start_time` | `TIME` | Time when the rental started. | `Rental` | `start_time`  |
| `end_time` | `TIME` | Time when the rental ended. | `Rental`  |`end_time` |
| `rental_count` | `INT` | Measure used to count rental line orders. Always equals `1`. | Calculated in ETL | Static value |
| `rental_amount` | `DECIMAL(10,2)` | Total rental amount used for analysis. | Calculated in ETL / rental source tables | Based on price and discount values |
| `rental_duration_minutes` | `INT` | Duration of the rental in minutes. | Calculated in ETL | Based on start and end date/time values |

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
