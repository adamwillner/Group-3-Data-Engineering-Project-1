DROP DATABASE IF EXISTS RentalOrderOperationalDB;
GO
CREATE DATABASE RentalOrderOperationalDB;

USE RentalOrderOperationalDB;

CREATE TABLE Category (
	category_id INT PRIMARY KEY,
	description NVARCHAR(50)
);

CREATE TABLE SubCategory (
	subcategory_id INT PRIMARY KEY,
	subcat_description NVARCHAR(50),
	category_id INT,
	CONSTRAINT FK_Subcategory_Category FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Item (
	item_id INT PRIMARY KEY,
	models_name NVARCHAR(50),
	item_description NVARCHAR(50),
	price DECIMAL(10,2),
	discount FLOAT,
	rental_days_allowed INT,
	subcategory_id INT,
	CONSTRAINT FK_Item_Subcategory FOREIGN KEY (subcategory_id) REFERENCES Subcategory(subcategory_id)
);

CREATE TABLE ItemInstance (
	instance_id INT PRIMARY KEY,
	item_state NVARCHAR(50),
	distance_km FLOAT,
	item_status BIT,
	item_id INT,
	CONSTRAINT FK_ItemInstance_Item FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

CREATE TABLE Address
(
    address_id INT PRIMARY KEY,
    address NVARCHAR(50) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    city NVARCHAR(50) NOT NULL
);

CREATE TABLE Customer 
(
	customer_id INT PRIMARY KEY,
	customer_name NVARCHAR(50) NOT NULL,
	address_id INT NOT NULL,
	customer_type NVARCHAR(50) NOT NULL,

	CONSTRAINT FK_Customer_Address
        FOREIGN KEY (address_id) REFERENCES Address (address_id) 
);

CREATE TABLE Location 
(
    location_id INT PRIMARY KEY,
    location_type NVARCHAR(50) NOT NULL,
    address_id INT NOT NULL,
    location_name NVARCHAR(50) NULL,

    CONSTRAINT FK_Location_Address
        FOREIGN KEY (address_id) REFERENCES Address (address_id)
); 

CREATE TABLE Employee
(
    employee_id INT PRIMARY KEY,
    location_id INT,
    employee_name NVARCHAR(50),

    CONSTRAINT FK_Employee_Location
        FOREIGN KEY (location_id) REFERENCES Location (location_id)
);

CREATE TABLE Rental (
	rental_id INT PRIMARY KEY,
	start_date_time DATETIME,
	return_date_time DATETIME NULL,
	end_date_time DATETIME,
	rental_status NVARCHAR(50),
	customer_id INT,
	employee_id INT NULL,
	rental_location_id INT,
	return_location_id INT,
	CONSTRAINT FK_Rental_Customer FOREIGN KEY (customer_id) REFERENCES Customer (customer_id),
	CONSTRAINT FK_Rental_Employee FOREIGN KEY (employee_id) REFERENCES Employee (employee_id),
	CONSTRAINT FK_Rental_Location_Rental FOREIGN KEY (rental_location_id) REFERENCES Location (location_id),
	CONSTRAINT FK_Rental_Location_Return FOREIGN KEY (return_location_id) REFERENCES Location (location_id)
);

CREATE TABLE RentalLineOrder (
	rental_line_id INT PRIMARY KEY,
	price_paid DECIMAL(10,2),
	discount_offered FLOAT,
	instance_id INT,
	rental_id INT,
	CONSTRAINT FK_RentalLineOrder_ItemInstance FOREIGN KEY (instance_id) REFERENCES ItemInstance(instance_id),
	CONSTRAINT FK_RentalLineOrder_Rental FOREIGN KEY(rental_id) REFERENCES Rental(rental_id)
);


