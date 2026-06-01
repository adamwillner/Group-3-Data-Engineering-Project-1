# Naming Conventions

## Purpose

This document defines naming standards used throughout the project to ensure consistency, readability, maintainability, and collaboration across the Operational Database, Data Warehouse, ETL processes, and Power BI reports.

---

# General Rules

## Naming Style

| Object Type | Convention |
|------------|------------|
| Tables | PascalCase |
| Views | PascalCase |
| Stored Procedures | PascalCase |
| Functions | PascalCase |
| Columns | snake_case |
| Constraints | PascalCase |
| Indexes | PascalCase |

## General Guidelines

- Use English for all object names.
- Avoid abbreviations unless widely understood.
- Use singular table names.
- Do not use spaces.
- Do not use special characters.
- Avoid SQL reserved keywords.
- Names should clearly describe the business meaning.

---

# Schemas

## Operational Database

| Schema | Purpose |
|----------|----------|
| dbo | Default business tables |

## Data Warehouse

| Schema | Purpose |
|----------|----------|
| dbo | Warehouse objects |

---

# Tables

## Operational Tables

Format:

```
PascalCase
```

Examples:

```
Customer
Order
Product
Supplier
```

### Rules

- Use singular nouns.
- Table names should represent an entity.

---

## Dimension Tables

Format:

```
Dim<Entity>
```

Examples:

```
DimCustomer
DimProduct
DimDate
DimEmployee
```

---

## Fact Tables

Format:

```
Fact<Process>
```

Examples:

```
FactSales
FactInventory
FactOrders
```

---

## Staging Tables (if used)

Format:

```
Stg<Entity>
```

Examples:

```
StgCustomer
StgSales
StgProduct
```

---

# Columns

## Naming Style

Use:

```
snake_case
```

Examples:

```
customer_id
customer_name
created_date
order_total
```

---

## Primary Keys

Format:

```
<table>_id
```

Examples:

```
customer_id
product_id
order_id
```

## Foreign Keys

Format:

```
<referenced_table>_id
```

Examples:

```
customer_id
product_id
employee_id
```

---

# Constraints

## Primary Key Constraints

Format:

```
PK_<TableName>
```

Examples:

```
PK_Customer
PK_DimCustomer
PK_FactSales
```

---

## Foreign Key Constraints

Format:

```
FK_<SourceTable>_<TargetTable>
```

Examples:

```
FK_Order_Customer
FK_Order_Product
```

---

## Unique Constraints

Format:

```
UQ_<TableName>_<ColumnName>
```

Example:

```
UQ_Customer_email
```

---

## Check Constraints

Format:

```
CHK_<TableName>_<Rule>
```

Examples:

```
CHK_Product_PricePositive
CHK_Order_QuantityPositive
```

---

# Indexes

## Clustered Index

Format:

```
IX_<TableName>_<ColumnName>
```

Example:

```
IX_Customer_customer_name
```

## Composite Index

Format:

```
IX_<TableName>_<Column1>_<Column2>
```

Example:

```
IX_Order_customer_id_order_date
```

---

# Views

Format:

```
View_<Description>
```

Examples:

```
View_CustomerOrders
View_SalesSummary
```

---

# Stored Procedures

Format:

```
Usp_<Action><Object>
```

Examples:

```
Usp_LoadDimCustomer
Usp_LoadFactSales
Usp_GetCustomerOrders
```

---

# Functions

## Scalar Functions

Format:

```
Fn_<Description>
```

Examples:

```
Fn_CalculateDiscount
Fn_FormatPhoneNumber
```

## Table-Valued Functions

Format:

```
Fn_<Description>
```

Examples:

```
Fn_CustomerSales
Fn_ProductPerformance
```

---

# ETL Processes

## Stored Procedures

Format:

```
Usp_Load<Destination>
```

Examples:

```
Usp_LoadDimCustomer
Usp_LoadDimProduct
Usp_LoadFactSales
```

---

# Data Warehouse Standards

## Business Keys

Format:

```
<entity>_id
```

Examples:

```
customer_id
product_id
```

## Surrogate Keys
(Common, but I'm fine with us using _id for the surrogate keys as well, _key can make things clearer though...)

Format:

```
<entity>_key
```

Examples:

```
customer_key
product_key
date_key
```

## Audit Columns

(Used for traceability - Not needed for our project but I included it all the same)

Required columns:

```
created_date
updated_date
load_date
source_system
```

---

# Power BI

## Reports

Format:

```
Subject Area - Report Purpose
```

Examples:

```
Sales - Executive Dashboard
Inventory - Monthly Analysis
```

---

## Measures

(USE SEPARATE MEASURES TABLE)

Format:

```
PascalCase
```

Examples:

```
TotalSales
AverageOrderValue
CustomerCount
```

---

## Calculated Columns

Format:

```
PascalCase
```

Examples:

```
OrderYear
CustomerCategory
ProfitMargin
```

---

# Reserved Prefixes

| Prefix | Meaning |
|----------|----------|
| Dim | Dimension table |
| Fact | Fact table |
| Stg | Staging table |
| View | View |
| Usp | Stored Procedure |
| Fn | Function |
| PK | Primary Key Constraint |
| FK | Foreign Key Constraint |
| UQ | Unique Constraint |
| CHK | Check Constraint |
| IX | Index |

---

# Example

## Operational Database

Customer

| Column |
|----------|
| customer_id |
| first_name |
| last_name |
| email |
| created_date |

## Data Warehouse

DimCustomer

| Column |
|----------|
| customer_key |
| customer_id |
| first_name |
| last_name |
| customer_type |

FactSales

| Column |
|----------|
| sales_key |
| customer_key |
| product_key |
| date_key |
| sales_amount |
| quantity |
