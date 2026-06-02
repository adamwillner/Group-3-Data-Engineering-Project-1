# Technical Documentation: RentalOrderDW

This document describes the technical solution and important decisions for the `RentalOrderDW` data warehouse.

## Architecture Diagram

The data warehouse uses a star schema with one central fact table and five dimension tables.

<img width="719" height="438" alt="DatawarehouseModel" src="https://github.com/user-attachments/assets/217461fb-c8e8-4d9b-bc76-4dae67f36ca8" />

## Database Schema
Database Schema
Table	Type	Primary Key	Description
DimLocation	Dimension	location_id	Stores location information.
DimEmployee	Dimension	employee_id	Stores employee information.
DimDate	Dimension	date_id	Stores date information.
DimItemInstance	Dimension	instance_id	Stores information about item instances, including subcategory and category.
DimCustomer	Dimension	customer_id	Stores customer information.
FactRentalLineOrder	Fact	rental_line_id	Stores rental line order transactions and measures.
Table Descriptions
DimLocation
Column / Field	Description
location_id	Primary key for the location dimension.
Location information	Stores descriptive information about rental and return locations.
Usage	Used to analyze rentals by rental location and return location.

Role-playing usage:

Fact Column	References	Description
rental_location_id	DimLocation(location_id)	Identifies the location where the rental started.
return_location_id	DimLocation(location_id)	Identifies the location where the rental was returned.
DimEmployee
Column / Field	Description
employee_id	Primary key for the employee dimension.
Employee information	Stores descriptive information about employees.
Usage	Used to analyze rental line orders by employee.
DimDate
Column / Field	Description
date_id	Primary key for the date dimension.
Date information	Stores calendar-related information used for reporting and analysis.
Usage	Used to analyze rentals by start date, return date, and end date.

Role-playing usage:

Fact Column	References	Description
start_date_id	DimDate(date_id)	Identifies the date when the rental started.
return_date_id	DimDate(date_id)	Identifies the date when the rental was returned.
end_date_id	DimDate(date_id)	Identifies the planned or actual rental end date.
DimItemInstance
Column / Field	Description
instance_id	Primary key for the item instance dimension.
Item instance information	Stores information about specific item instances.
Subcategory information	Stores item subcategory details.
Category information	Stores item category details.
Usage	Used to analyze rentals by item instance, subcategory, and category.

Design note:

Decision	Description
Denormalized item structure	Item, subcategory, and category information are stored in one dimension table to reduce joins and simplify reporting.
DimCustomer
Column / Field	Description
customer_id	Primary key for the customer dimension.
Customer information	Stores descriptive information about customers.
Usage	Used to analyze rental line orders by customer.
FactRentalLineOrder
Column / Field	Description
rental_line_id	Primary key for the fact table.
Rental line order transaction	Represents one rental line order transaction.
Measures	Stores numeric values used for analysis, such as rental count, rental amount, and rental duration.
Foreign keys	Connects each rental line order to related dimensions such as customer, employee, item instance, location, and date.
Fact Table Grain

The grain of FactRentalLineOrder is:

One row per rental line order.

Each fact row connects one rental line to the following dimensions:

| Table | Type | Primary Key | Description |
|---|---|---|---|
| `DimLocation` | Dimension | `location_id` | Stores location information. |
| `DimEmployee` | Dimension | `employee_id` | Stores employee information. |
| `DimDate` | Dimension | `date_id` | Stores date information. |
| `DimItemInstance` | Dimension | `instance_id` | Stores information about item instances e.g. subcategory, and category. |
| `DimCustomer` | Dimension | `customer_id` | Stores customer information. |
| `FactRentalLineOrder` | Fact | `rental_line_id` | Stores rental line order transactions and measures. |

Dimension Role	Related Dimension Table
Customer	DimCustomer
Employee	DimEmployee
Item instance	DimItemInstance
Rental location	DimLocation
Return location	DimLocation
Start date	DimDate
Return date	DimDate
End date	DimDate
Main Measures
Measure	Description
rental_count	Used for counting rental line orders. Always has the value 1.
rental_amount	Total rental amount cost for the rental, including many rental lines.
rental_duration_minutes	Duration of the rental in minutes.
Foreign Key Relationships
Fact Column	References
start_date_id	DimDate(date_id)
return_date_id	DimDate(date_id)
end_date_id	DimDate(date_id)
customer_id	DimCustomer(customer_id)
employee_id	DimEmployee(employee_id)
rental_location_id	DimLocation(location_id)
return_location_id	DimLocation(location_id)
instance_id	DimItemInstance(instance_id)
Important Technical Decisions and Changes
Decision	Description
Star schema design	The warehouse uses a star schema to make reporting simpler and improve query performance.
Central fact table	FactRentalLineOrder is the central fact table because rental line orders contain the measurable business events.
Denormalized dimensions	Dimension tables are denormalized to reduce the number of joins needed in reports.
Combined item dimension	DimItemInstance includes item, subcategory, and category information in one dimension.
Role-playing date dimension	DimDate is reused for start date, return date, and end date.
Role-playing location dimension	DimLocation is reused for rental location and return location.
Stored calculated measures	Calculated values such as rental_amount and rental_duration_minutes are stored in the fact table to simplify analysis.
Database name: `RentalOrderDW`

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
