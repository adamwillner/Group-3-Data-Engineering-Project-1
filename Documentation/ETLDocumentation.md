# Rental Order Data Warehouse ETL Process Documentation

## 1. Overview

### Purpose

The purpose of this ETL process is to populate the **RentalOrderDW** data warehouse from the **RentalOrderOperationalDB** operational database. The process supports analytical reporting by organizing transactional rental data into a star schema consisting of dimension and fact tables.

### Source System

* **Database:** RentalOrderOperationalDB
* **Data Type:** Operational rental management data

### Target System

* **Database:** RentalOrderDW
* **Schema Type:** Star Schema

---

## 2. ETL Architecture

### Source Tables

| Table           | Description                      |
| --------------- | -------------------------------- |
| Customer        | Customer information             |
| Address         | Customer and location addresses  |
| Employee        | Employee information             |
| Location        | Location for stations and stores |
| Item            | Rental item master data          |
| ItemInstance    | Physical rental item instances   |
| Category        | Product categories               |
| SubCategory     | Product subcategories            |
| Rental          | Rental transactions              |
| RentalLineOrder | Rental line details              |

### Target Tables

#### Dimension Tables

* DimCustomer
* DimEmployee
* DimLocation
* DimItemInstance
* DimDate

#### Fact Table

* FactRentalLineOrder

---

## 3. Dimension Loading Process

### 3.1 DimCustomer

#### Purpose

Stores customer attributes for analytical reporting.

#### Source Tables

* Customer
* Address

#### Transformations

| Transformation            | Description                                |
| ------------------------- | ------------------------------------------ |
| `COALESCE()`              | Replaces NULL values with "Missing"        |
| `LEFT JOIN`               | Connects customer records to address data  |
| Business Key Preservation | `customer_id` stored as `alt_customer_key` |


---

### 3.2 DimEmployee

#### Purpose

Stores employee information.

#### Source Tables

* Employee
* Location

#### Transformations and Special Handling

A placeholder employee record is inserted:

| Transformation                | Description                                |
| ----------------------------- | ------------------------------------------ |
| COALESCE + employee_id        | If NULL, employee_id = -1                  |
| COALESCE + employee_name      | If NULL, default employee = 'Missing'      |
| COALESCE + location_id        | If NULL, location_id = 'Missing'           |

This ensures referential integrity when rentals are not associated with an employee.

Location ID is preserved as an alternate key.

---

### 3.3 DimLocation

#### Purpose

Stores rental and return location information.

#### Source Tables

* Location
* Address

#### Transformations

* Address enrichment through join.
* COALESCE replaces NULL values with "Missing".
* Location business key stored as `alt_location_key`.

---

### 3.4 DimItemInstance

#### Purpose

Stores information about rental items and their categorization.

#### Source Tables

* ItemInstance
* Item
* SubCategory
* Category

#### Transformations

| Transformation     | Description                                     |
| ------------------ | ----------------------------------------------- |
| Hierarchical Joins | Item → SubCategory → Category                   |
| COALESCE           | Replaces NULL values with "Missing"             |
| COALESCE km        | If NULL, distance values (km) = -1              |

`instance_id` is preserved in `alt_instance_key`.

---

### 3.5 DimDate

#### Purpose

Provides a reusable calendar dimension.

#### Date Range Variables

* **Start Date:** 2020-01-01
* **End Date:** 2030-12-31

#### Generated Attributes

| Column       | Description     |
| ------------ | --------------- |
| date_id      | YYYYMMDD format |
| date         | Full date       |
| day          | Weekday name    |
| month_number | Numeric month   |
| month_name   | Month name      |
| year         | Calendar year   |

#### Implementation

A recursive CTE generates one row per date until the specified end date is reached.

---

## 4. Fact Table Loading

### FactRentalLineOrder

#### Purpose

Stores rental transaction facts and measures for analysis.

#### Source Tables

| Table           |
| --------------- |
| RentalLineOrder |
| Rental          |
| DimCustomer     |
| DimEmployee     |
| DimItemInstance |
| DimLocation     |

#### Fact Measures

| Measure                 | Description                           |
| ----------------------- | ------------------------------------- |
| rental_count            | Fixed value of 1 for counting rentals |
| rental_amount           | Total rental revenue per rental       |
| rental_duration_minutes | Rental duration in minutes            |

#### Calculated Fields

##### Rental Amount

```sql
SUM(price_paid)
OVER (PARTITION BY rental_id)
```

Calculates total revenue generated for a rental transaction.

##### Rental Duration

```sql
DATEDIFF(
    minute,
    start_date_time,
    return_date_time
)
```

Calculates rental duration in minutes.

#### Date Keys

Dates are converted into surrogate date keys:

| Source           | Format   |
| ---------------- | -------- |
| start_date_time  | YYYYMMDD |
| return_date_time | YYYYMMDD |
| end_date_time    | YYYYMMDD |

#### Dimension Key Lookups

| Dimension     | Lookup                         |
| ------------- | ------------------------------ |
| Customer      | customer_id → alt_customer_key |
| Employee      | employee_id → alt_employee_key |
| Item Instance | instance_id → alt_instance_key |

---

## 5. Data Quality Rules

| Rule                     | Action                            |
| ------------------------ | --------------------------------- |
| NULL rental status       | Replace with "Missing"            |
| NULL price paid          | Replace with 0                    |
| NULL discount offered    | Replace with 0                    |
| NULL customer attributes | Replace with "Missing"            |
| NULL location attributes | Replace with "Missing"            |
| NULL numeric values      | Replace with -1 or 0              |
| Missing employee         | Use employee_id = -1              |
| Missing dates            | Default time values when required |

---

## 6. Business Value

This ETL process enables:

* Rental revenue analysis
* Rental duration analysis
* Customer segmentation reporting
* Employee performance analysis
* Location performance reporting
* Item utilization tracking
* Category and subcategory reporting

