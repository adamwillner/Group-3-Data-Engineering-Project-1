# Operational Database Documentation
## Overview
The RentalOrderOperationalDB supports the daily operations of a rental business. It stores information about rental items, customers, locations, employees, and rental transactions.
<img width="975" height="684" alt="image" src="https://github.com/user-attachments/assets/e4567e32-1924-4e0d-8d69-643f196454c2" />

## Tables
### Category
Stores the main categories of rental items.

| Column | Description |
|---|---|
|category_id | Unique category identifier
|description |	Category description, type of category


### SubCategory
Stores subcategories belonging to a category.

| Column | Description |
|---|---|
|subcategory_id	| Unique subcategory identifier
subcat_description | Subcategory description, type of subcategory
category_i | Reference to Category

### Item
Stores rentable products.

| Column | Description |
|---|---|
item_id | Unique item identifier
models_name | Item model name
item_description | Item description
price | Rental price per rental
discount | Discount proportion
rental_days_allowed | Maximum rental period
subcategory_id | Reference to SubCategory


### ItemInstance
Stores individual physical instances of an item

| Column | Description |
|---|---|
instance_id | Unique instance identifier
item_state |	Condition of the item
distance_km |	Distance travelled (if applicable)
item_status |	Availability status (0 = Free, 1 = Taken)
item_id |	Reference to Item


### Customer
Stores customers, which can be either individuals or companies.

| Column | Description |
|---|---|
customer_id | Unique customer identifier
customer_name |	Customer name
customer_type |	Person or company
address_id |	Reference to Address

### Address
Stores address information for customers and locations.

| Column | Description |
|---|---|
address_id |	Unique address identifier
address |	Street address
city |	City
country |	Country

### Location
Stores rental locations and shops.

| Column | Description |
|---|---|
location_id |	Unique location identifier
location_type	|Type of location, either a store or a station
location_name |	Name of the shop/location
address_id |	Reference to Address

### Employee
Stores employee information.

| Column | Description |
|---|---|
employee_id |	Unique employee identifier
employee_name |	Employee name
location_id |	Reference to Location

### Rental
Stores rental transactions.

| Column | Description |
|---|---|
rental_id |	Unique rental identifier
start_date_time |	Rental start date and time
end_date_time |	Planned return date and time
return_date_time |	Actual return date and time
rental_status |	Current rental status; completed, cancelled, overdue or active
customer_id |	Reference to Customer
employee_id |	Reference to Employee
rental_location_id |	Pickup location
return_location_id |	Return location

### RentalLineOrder
Stores the rented item instances connected to a rental.

| Column | Description |
|---|---|
rental_line_id | Unique rental line identifier
price_paid |	Final price paid
discount_offered |	Discount applied
instance_id |	Reference to ItemInstance
rental_id |	Reference to Rental


### Relationships
- Categories contain multiple SubCategories.
- SubCategories contain multiple Items.
- Items can have multiple ItemInstances.
- Customers create Rentals.
- Employees can manage Rentals at Locations, but are not needed.
- Rentals contain one or more RentalLineOrders.
- RentalLineOrders connect Rentals to ItemInstances.
