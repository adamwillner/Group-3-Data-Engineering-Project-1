DROP DATABASE IF EXISTS RentalOrderOperationalDB;
GO
CREATE DATABASE RentalOrderOperationalDB;

USE RentalOrderOperationalDB;

CREATE TABLE Category (
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	description NVARCHAR(50) NOT NULL
);

CREATE TABLE SubCategory (
	subcategory_id INT IDENTITY(1,1) PRIMARY KEY,
	subcat_description NVARCHAR(50) NOT NULL,
	category_id INT NOT NULL,
	CONSTRAINT FK_Subcategory_Category FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Item (
	item_id INT IDENTITY(1,1) PRIMARY KEY,
	models_name NVARCHAR(50) NOT NULL,
	item_description NVARCHAR(50) NOT NULL,
	price DECIMAL(10,2) NOT NULL,
	discount FLOAT NOT NULL,
	rental_days_allowed INT NOT NULL,
	subcategory_id INT NOT NULL,
	CONSTRAINT FK_Item_Subcategory FOREIGN KEY (subcategory_id) REFERENCES Subcategory(subcategory_id)
);

CREATE TABLE ItemInstance (
	instance_id INT IDENTITY(1,1) PRIMARY KEY,
	item_state NVARCHAR(50) NOT NULL,
	distance_km FLOAT NOT NULL,
	item_status BIT NOT NULL,
	item_id INT NOT NULL,
	CONSTRAINT FK_ItemInstance_Item FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

CREATE TABLE Address
(
    address_id INT IDENTITY(1,1) PRIMARY KEY,
    address NVARCHAR(50) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    city NVARCHAR(50) NOT NULL
);

CREATE TABLE Customer 
(
	customer_id INT IDENTITY(1,1) PRIMARY KEY,
	customer_name NVARCHAR(50) NOT NULL,
	address_id INT NOT NULL,
	customer_type NVARCHAR(50) NOT NULL,

	CONSTRAINT FK_Customer_Address
        FOREIGN KEY (address_id) REFERENCES Address (address_id) 
);

CREATE TABLE Location 
(
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    location_type NVARCHAR(50) NOT NULL,
    address_id INT NOT NULL,
    location_name NVARCHAR(50) NULL,

    CONSTRAINT FK_Location_Address
        FOREIGN KEY (address_id) REFERENCES Address (address_id)
); 

CREATE TABLE Employee
(
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    location_id INT NOT NULL,
    employee_name NVARCHAR(50) NOT NULL,

    CONSTRAINT FK_Employee_Location
        FOREIGN KEY (location_id) REFERENCES Location (location_id)
);

CREATE TABLE Rental (
	rental_id INT IDENTITY(1,1) PRIMARY KEY,
	start_date_time DATETIME NOT NULL,
	return_date_time DATETIME NULL,
	end_date_time DATETIME NOT NULL,
	rental_status NVARCHAR(50) NOT NULL,
	customer_id INT NOT NULL,
	employee_id INT NULL,
	rental_location_id INT NOT NULL,
	return_location_id INT NULL,
	CONSTRAINT FK_Rental_Customer FOREIGN KEY (customer_id) REFERENCES Customer (customer_id),
	CONSTRAINT FK_Rental_Employee FOREIGN KEY (employee_id) REFERENCES Employee (employee_id),
	CONSTRAINT FK_Rental_Location_Rental FOREIGN KEY (rental_location_id) REFERENCES Location (location_id),
	CONSTRAINT FK_Rental_Location_Return FOREIGN KEY (return_location_id) REFERENCES Location (location_id)
);

CREATE TABLE RentalLineOrder (
	rental_line_id INT IDENTITY(1,1) PRIMARY KEY,
	price_paid DECIMAL(10,2) NOT NULL,
	discount_offered FLOAT NOT NULL,
	instance_id INT NOT NULL,
	rental_id INT NOT NULL,
	CONSTRAINT FK_RentalLineOrder_ItemInstance FOREIGN KEY (instance_id) REFERENCES ItemInstance(instance_id),
	CONSTRAINT FK_RentalLineOrder_Rental FOREIGN KEY(rental_id) REFERENCES Rental(rental_id)
);


