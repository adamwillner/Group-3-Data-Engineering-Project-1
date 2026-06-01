CREATE TABLE DimEmployee (
	employee_id INT PRIMARY KEY,
	employee_name NVARCHAR(50),
	location_id INT,
	location_name NVARCHAR(50),
	alt_employee_key INT
);

CREATE TABLE DimDate (
	date_id INT PRIMARY KEY,
	date DATE,
	day NVARCHAR(20),
	month_number INT,
	month_name NVARCHAR(20),
	year INT
);

CREATE TABLE DimItemInstance (
	instance_id INT PRIMARY KEY,
	item_state NVARCHAR(50),
	distance_km FLOAT,
	item_id INT,
	model_name NVARCHAR(50),
	item_status BIT,
	subcategory_id INT,
	subcat_description NVARCHAR(50),
	category_id INT,
	cat_description NVARCHAR(50),
	alt_instance_key INT
);

CREATE TABLE DimCustomer (
	customer_id INT PRIMARY KEY,
	customer_name NVARCHAR(50),
	adress_id INT,
	adress NVARCHAR(50),
	city NVARCHAR(50),
	country NVARCHAR(50),
	customer_type NVARCHAR(50),
	alt_customer_key INT
);
