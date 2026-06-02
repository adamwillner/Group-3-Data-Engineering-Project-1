CREATE DATABASE RentalOrderDW
GO

USE RentalOrderDW

CREATE TABLE DimLocation
(
	location_id INT PRIMARY KEY,
	location_type NVARCHAR(50) NOT NULL,
	address_id INT NOT NULL,
	address NVARCHAR(50) NOT NULL,
	city NVARCHAR(50) NOT NULL,
	country NVARCHAR(50) NOT NULL,
	location_name NVARCHAR(50) NULL,
	alt_location_key INT
);

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

CREATE TABLE FactRentalLineOrder
(
	rental_line_id INT PRIMARY KEY,
	rental_id INT NOT NULL,
	rental_status NVARCHAR(50) NOT NULL,
	price_paid DECIMAL(10,2) NOT NULL,
	discount_offered FLOAT NOT NULL,
	start_date_id INT NOT NULL,
	return_date_id INT NOT NULL,
	end_date_id INT NOT NULL,
	customer_id INT NOT NULL,
	employee_id INT NOT NULL,
	rental_location_id INT NOT NULL,
	return_location_id INT NOT NULL,
	instance_id INT NOT NULL,
	start_time TIME NOT NULL,
	end_time TIME NOT NULL,
	rental_count INT NOT NULL,
	rental_amount DECIMAL(10,2) NOT NULL,
	rental_duration_minutes INT NOT NULL,

	CONSTRAINT FK_FactRentalLineOrder_DimDate_start
		FOREIGN KEY (start_date_id) REFERENCES DimDate(date_id),

	CONSTRAINT FK_FactRentalLineOrder_DimDate_return
		FOREIGN KEY (return_date_id) REFERENCES DimDate(date_id),

	CONSTRAINT FK_FactRentalLineOrder_DimDate_end
		FOREIGN KEY (end_date_id) REFERENCES DimDate(date_id),

	CONSTRAINT FK_FactRentalLineOrder_DimCustomer
		FOREIGN KEY (customer_id) REFERENCES DimCustomer(customer_id),
	
	CONSTRAINT FK_FactRentalLineOrder_DimEmployee
		FOREIGN KEY (employee_id) REFERENCES DimEmployee(employee_id),

	CONSTRAINT FK_FactRentalLineOrder_DimLocation_rental
		FOREIGN KEY (rental_location_id) REFERENCES DimLocation(location_id),

	CONSTRAINT FK_FactRentalLineOrder_DimLocation_return
		FOREIGN KEY (return_location_id) REFERENCES DimLocation(location_id),

	CONSTRAINT FK_FactRentalLineOrder_DimItemInstance
		FOREIGN KEY (instance_id) REFERENCES DimItemInstance(instance_id)
)

