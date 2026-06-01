USE RentalOrderOperationalDB

SELECT 'Category' table_name, COUNT(*) row_count FROM Category
UNION ALL SELECT 'SubCategory', COUNT(*) FROM SubCategory
UNION ALL SELECT 'Item', COUNT(*) FROM Item
UNION ALL SELECT 'ItemInstance', COUNT(*) FROM ItemInstance
UNION ALL SELECT 'Address', COUNT(*) FROM Address
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL SELECT 'Location', COUNT(*) FROM Location
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Rental', COUNT(*) FROM Rental
UNION ALL SELECT 'RentalLineOrder', COUNT(*) FROM RentalLineOrder;

SELECT
	COUNT(*) nr_of_countries
FROM
(
	SELECT DISTINCT
		country
	FROM Address
)t

SELECT
	COUNT(*) nr_of_cities
FROM
(
	SELECT DISTINCT
		city
	FROM Address
)t
