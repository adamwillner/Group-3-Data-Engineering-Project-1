
SELECT 'Category' AS table_name, COUNT(*) AS rows FROM Category
UNION ALL SELECT 'SubCategory', COUNT(*) FROM SubCategory
UNION ALL SELECT 'Item', COUNT(*) FROM Item
UNION ALL SELECT 'ItemInstance', COUNT(*) FROM ItemInstance
UNION ALL SELECT 'Address', COUNT(*) FROM Address
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL SELECT 'Location', COUNT(*) FROM Location
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Rental', COUNT(*) FROM Rental
UNION ALL SELECT 'RentalLineOrder', COUNT(*) FROM RentalLineOrder;


---Instance overlap checks
--1
SELECT
    rlo1.instance_id,
    r1.rental_id AS rental_1,
    r2.rental_id AS rental_2,
    r1.start_date_time AS rental_1_start,
    ISNULL(r1.return_date_time, r1.end_date_time) AS rental_1_effective_end,
    r2.start_date_time AS rental_2_start,
    ISNULL(r2.return_date_time, r2.end_date_time) AS rental_2_effective_end
FROM RentalLineOrder rlo1
JOIN Rental r1 ON rlo1.rental_id = r1.rental_id
JOIN RentalLineOrder rlo2 ON rlo1.instance_id = rlo2.instance_id
JOIN Rental r2 ON rlo2.rental_id = r2.rental_id
WHERE r1.rental_id < r2.rental_id
  AND r1.start_date_time < ISNULL(r2.return_date_time, r2.end_date_time)
  AND r2.start_date_time < ISNULL(r1.return_date_time, r1.end_date_time);

--2
WITH InstanceRentals AS
(
    SELECT
        rlo.instance_id,
        r.rental_id,
        r.start_date_time,
        COALESCE(r.return_date_time, r.end_date_time) AS occupied_until,
        LEAD(r.start_date_time) OVER
        (
            PARTITION BY rlo.instance_id
            ORDER BY r.start_date_time
        ) AS next_start
    FROM RentalLineOrder rlo
    JOIN Rental r
        ON rlo.rental_id = r.rental_id
)
SELECT *
FROM InstanceRentals
WHERE next_start IS NOT NULL
    AND next_start < occupied_until;

---Store/station employee rule
SELECT r.*
FROM Rental r
JOIN Location l ON r.rental_location_id = l.location_id
WHERE (l.location_type = 'store' AND r.employee_id IS NULL)
   OR (l.location_type = 'station' AND r.employee_id IS NOT NULL);

---Overdue rule
SELECT *
FROM Rental
WHERE return_date_time > end_date_time
  AND rental_status <> 'overdue';

---Cancelled rentals should have no lines
SELECT r.rental_id, COUNT(rlo.rental_line_id) AS line_count
FROM Rental r
JOIN RentalLineOrder rlo ON r.rental_id = rlo.rental_id
WHERE r.rental_status = 'cancelled'
GROUP BY r.rental_id;

---Rentals without rental lines, excluding cancelled
SELECT 
    r.rental_id, 
    r.rental_status
FROM Rental r
LEFT JOIN RentalLineOrder rlo ON r.rental_id = rlo.rental_id
WHERE rlo.rental_id IS NULL AND r.rental_status <> 'cancelled';

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

---checks that one instance cannot be rented and returned in many counties
SELECT
    rlo.instance_id,
    COUNT(DISTINCT a.country) AS country_count
FROM RentalLineOrder rlo
JOIN Rental r
    ON rlo.rental_id = r.rental_id
JOIN Location l
    ON r.rental_location_id = l.location_id
JOIN Address a
    ON l.address_id = a.address_id
GROUP BY rlo.instance_id
HAVING COUNT(DISTINCT a.country) > 1;
