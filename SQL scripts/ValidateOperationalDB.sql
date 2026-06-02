
USE RentalOrderOperationalDB

---Counting the rows
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


---Counting cities and countries
SELECT 
    COUNT(DISTINCT country) AS country_count,
    COUNT(DISTINCT city) AS city_count
FROM Address;


---Checking Foreign Keys
SELECT 
    COUNT(*) AS bad_fk_rows
FROM RentalLineOrder rlo
LEFT JOIN Rental r 
    ON rlo.rental_id = r.rental_id
LEFT JOIN ItemInstance ii 
    ON rlo.instance_id = ii.instance_id
LEFT JOIN Item i 
    ON ii.item_id = i.item_id
LEFT JOIN SubCategory sc 
    ON i.subcategory_id = sc.subcategory_id
LEFT JOIN Category c 
    ON sc.category_id = c.category_id
WHERE r.rental_id IS NULL
   OR ii.instance_id IS NULL
   OR i.item_id IS NULL
   OR sc.subcategory_id IS NULL
   OR c.category_id IS NULL;

---Date and price sanity check
SELECT
    SUM(CASE WHEN end_date_time < start_date_time THEN 1 ELSE 0 END) AS bad_end_dates,
    SUM(CASE WHEN return_date_time < start_date_time THEN 1 ELSE 0 END) AS bad_return_dates,
    SUM(CASE WHEN rlo.price_paid < 0 THEN 1 ELSE 0 END) AS bad_prices
FROM Rental r
JOIN RentalLineOrder rlo 
    ON r.rental_id = rlo.rental_id;

---Main join test
SELECT TOP 20
    r.rental_id,
    r.start_date_time,
    r.rental_status,
    c.customer_type,
    a.country,
    a.city,
    l.location_name,
    cat.description AS category,
    sc.subcat_description AS subcategory,
    i.models_name,
    rlo.price_paid
FROM Rental r
JOIN Customer c 
    ON r.customer_id = c.customer_id
JOIN Location l 
    ON r.rental_location_id = l.location_id
JOIN Address a 
    ON l.address_id = a.address_id
JOIN RentalLineOrder rlo 
    ON r.rental_id = rlo.rental_id
JOIN ItemInstance ii 
    ON rlo.instance_id = ii.instance_id
JOIN Item i 
    ON ii.item_id = i.item_id
JOIN SubCategory sc 
    ON i.subcategory_id = sc.subcategory_id
JOIN Category cat 
    ON sc.category_id = cat.category_id
ORDER BY r.start_date_time;
