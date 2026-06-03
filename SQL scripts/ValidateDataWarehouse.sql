-- Validation scripts for RentalOrderDW with matching table queries from OP DB
-- ==============================================================================================--
-- Seems about right.. Some oddities when checking the metrics but expected from the data generated

-- #################################################
-- ## Data Warehous 
-- #################################################

USE RentalOrderDW;
GO

/* 1. Row counts for all DW tables */
SELECT 'DimLocation' AS table_name, COUNT(*) AS row_count FROM DimLocation
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM DimEmployee
UNION ALL SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL SELECT 'DimItemInstance', COUNT(*) FROM DimItemInstance
UNION ALL SELECT 'DimCustomer', COUNT(*) FROM DimCustomer
UNION ALL SELECT 'FactRentalLineOrder', COUNT(*) FROM FactRentalLineOrder;

/* 2. Duplicate natural / alternate keys in dimensions */
SELECT alt_location_key, COUNT(*) AS duplicate_count
FROM DimLocation
GROUP BY alt_location_key
HAVING COUNT(*) > 1;

SELECT alt_employee_key, COUNT(*) AS duplicate_count
FROM DimEmployee
GROUP BY alt_employee_key
HAVING COUNT(*) > 1;

SELECT alt_instance_key, COUNT(*) AS duplicate_count
FROM DimItemInstance
GROUP BY alt_instance_key
HAVING COUNT(*) > 1;

SELECT alt_customer_key, COUNT(*) AS duplicate_count
FROM DimCustomer
GROUP BY alt_customer_key
HAVING COUNT(*) > 1;

/* 3. Fact rows with missing dimension references */
SELECT f.*
FROM FactRentalLineOrder f
LEFT JOIN DimDate ds ON f.start_date_id = ds.date_id
LEFT JOIN DimDate de ON f.end_date_id = de.date_id
LEFT JOIN DimDate dr ON f.return_date_id = dr.date_id
LEFT JOIN DimCustomer c ON f.customer_id = c.customer_id
LEFT JOIN DimEmployee e ON f.employee_id = e.employee_id
LEFT JOIN DimLocation rl ON f.rental_location_id = rl.location_id
LEFT JOIN DimLocation retl ON f.return_location_id = retl.location_id
LEFT JOIN DimItemInstance i ON f.instance_id = i.instance_id
WHERE ds.date_id IS NULL
   OR de.date_id IS NULL
   OR (f.return_date_id IS NOT NULL AND dr.date_id IS NULL)
   OR c.customer_id IS NULL
   OR (f.employee_id IS NOT NULL AND e.employee_id IS NULL)
   OR rl.location_id IS NULL
   OR (f.return_location_id IS NOT NULL AND retl.location_id IS NULL)
   OR i.instance_id IS NULL;

/* 4. Invalid date logic */
SELECT *
FROM FactRentalLineOrder
WHERE end_date_id < start_date_id
   OR return_date_id < start_date_id
   OR return_date_id > end_date_id;

/* 5. Invalid money or quantity values */
SELECT *
FROM FactRentalLineOrder
WHERE price_paid < 0
   OR rental_amount < 0
   OR discount_offered < 0
   OR discount_offered > 1
   OR rental_count < 0
   OR rental_duration_minutes < 0;

/* 6. Validate rental_count should probably be 1 per fact line */
SELECT *
FROM FactRentalLineOrder
WHERE rental_count <> 1;

/* 7. Rental amount consistency check */
SELECT *
FROM FactRentalLineOrder
WHERE rental_amount <> price_paid * rental_count;

/* 8. Return fields should match rental status */
SELECT *
FROM FactRentalLineOrder
WHERE rental_status IN ('Returned', 'Completed', 'Closed')
  AND (return_date_id IS NULL OR return_time IS NULL OR return_location_id IS NULL);

/* 9. Open rentals should not have return details */
SELECT *
FROM FactRentalLineOrder
WHERE rental_status IN ('Open', 'Active', 'Rented')
  AND (return_date_id IS NOT NULL OR return_time IS NOT NULL OR return_location_id IS NOT NULL);

/* 10. Invalid date dimension values */
SELECT *
FROM DimDate
WHERE month_number NOT BETWEEN 1 AND 12
   OR year <> YEAR(date)
   OR month_number <> MONTH(date)
   OR month_name <> DATENAME(MONTH, date)
   OR day <> DATENAME(WEEKDAY, date);

/* 11. Missing dates in DimDate */
WITH DateRange AS (
    SELECT MIN(date) AS min_date, MAX(date) AS max_date
    FROM DimDate
),
CalendarDates AS (
    SELECT min_date AS date
    FROM DateRange

    UNION ALL

    SELECT DATEADD(DAY, 1, date)
    FROM CalendarDates
    CROSS JOIN DateRange
    WHERE date < max_date
)
SELECT c.date
FROM CalendarDates c
LEFT JOIN DimDate d ON c.date = d.date
WHERE d.date IS NULL
OPTION (MAXRECURSION 0);

/* 12. Dimension relationship consistency: employee location */
SELECT e.*
FROM DimEmployee e
LEFT JOIN DimLocation l
    ON e.location_id = l.location_id
WHERE l.location_id IS NULL
   OR e.location_name <> l.location_name;

/* 13. Invalid item values */
SELECT *
FROM DimItemInstance
WHERE distance_km < 0
   OR item_status NOT IN (0, 1);

/* 14. Duplicate fact business keys */
SELECT rental_id, instance_id, start_date_id, start_time, COUNT(*) AS duplicate_count
FROM FactRentalLineOrder
GROUP BY rental_id, instance_id, start_date_id, start_time
HAVING COUNT(*) > 1;

/* 15. Fact records with impossible same-day return time */
SELECT *
FROM FactRentalLineOrder
WHERE return_date_id = start_date_id
  AND return_time < start_time;

-- #################################################
-- ## Operational DB for comparisons
-- #################################################

USE RentalOrderOperationalDB;
GO

/* 1. Row counts for all operational tables */
SELECT 'Category' AS table_name, COUNT(*) AS row_count FROM Category
UNION ALL SELECT 'SubCategory', COUNT(*) FROM SubCategory
UNION ALL SELECT 'Item', COUNT(*) FROM Item
UNION ALL SELECT 'ItemInstance', COUNT(*) FROM ItemInstance
UNION ALL SELECT 'Address', COUNT(*) FROM Address
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL SELECT 'Location', COUNT(*) FROM Location
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Rental', COUNT(*) FROM Rental
UNION ALL SELECT 'RentalLineOrder', COUNT(*) FROM RentalLineOrder;

/* 2. Missing foreign key references */
SELECT r.*
FROM Rental r
LEFT JOIN Customer c ON r.customer_id = c.customer_id
LEFT JOIN Employee e ON r.employee_id = e.employee_id
LEFT JOIN Location rl ON r.rental_location_id = rl.location_id
LEFT JOIN Location retl ON r.return_location_id = retl.location_id
WHERE c.customer_id IS NULL
   OR (r.employee_id IS NOT NULL AND e.employee_id IS NULL)
   OR rl.location_id IS NULL
   OR retl.location_id IS NULL;

SELECT rlo.*
FROM RentalLineOrder rlo
LEFT JOIN Rental r ON rlo.rental_id = r.rental_id
LEFT JOIN ItemInstance ii ON rlo.instance_id = ii.instance_id
WHERE r.rental_id IS NULL
   OR ii.instance_id IS NULL;

/* 3. Dimension/source hierarchy checks */
SELECT sc.*
FROM SubCategory sc
LEFT JOIN Category c ON sc.category_id = c.category_id
WHERE c.category_id IS NULL;

SELECT i.*
FROM Item i
LEFT JOIN SubCategory sc ON i.subcategory_id = sc.subcategory_id
WHERE sc.subcategory_id IS NULL;

SELECT ii.*
FROM ItemInstance ii
LEFT JOIN Item i ON ii.item_id = i.item_id
WHERE i.item_id IS NULL;

/* 4. Customer, location, and employee address/location checks */
SELECT c.*
FROM Customer c
LEFT JOIN Address a ON c.address_id = a.address_id
WHERE a.address_id IS NULL;

SELECT l.*
FROM Location l
LEFT JOIN Address a ON l.address_id = a.address_id
WHERE a.address_id IS NULL;

SELECT e.*
FROM Employee e
LEFT JOIN Location l ON e.location_id = l.location_id
WHERE l.location_id IS NULL;

/* 5. Invalid date logic in Rental */
SELECT *
FROM Rental
WHERE end_date_time < start_date_time
   OR return_date_time < start_date_time
   OR return_date_time > end_date_time;

/* 6. Same-day return time before start time */
SELECT *
FROM Rental
WHERE CAST(return_date_time AS DATE) = CAST(start_date_time AS DATE)
  AND CAST(return_date_time AS TIME) < CAST(start_date_time AS TIME);

/* 7. Invalid monetary or numeric values */
SELECT *
FROM Item
WHERE price < 0
   OR discount < 0
   OR discount > 1
   OR rental_days_allowed < 0;

SELECT *
FROM ItemInstance
WHERE distance_km < 0;

SELECT *
FROM RentalLineOrder
WHERE price_paid < 0
   OR discount_offered < 0
   OR discount_offered > 1;

/* 7. Invalid monetary or numeric values */
SELECT *
FROM Item
WHERE price < 0
   OR discount < 0
   OR discount > 1
   OR rental_days_allowed < 0;

SELECT *
FROM ItemInstance
WHERE distance_km < 0;

SELECT *
FROM RentalLineOrder
WHERE price_paid < 0
   OR discount_offered < 0
   OR discount_offered > 1;

/* 8. Rental status versus return date consistency */
SELECT *
FROM Rental
WHERE rental_status IN ('Returned', 'Completed', 'Closed')
  AND return_date_time IS NULL;

/* 9. Open rentals should not have return datetime */
SELECT *
FROM Rental
WHERE rental_status IN ('Open', 'Active', 'Rented')
  AND return_date_time IS NOT NULL;

/* 10. Duplicate likely business keys */
SELECT description, COUNT(*) AS duplicate_count
FROM Category
GROUP BY description
HAVING COUNT(*) > 1;

SELECT subcat_description, category_id, COUNT(*) AS duplicate_count
FROM SubCategory
GROUP BY subcat_description, category_id
HAVING COUNT(*) > 1;

SELECT models_name, item_description, subcategory_id, COUNT(*) AS duplicate_count
FROM Item
GROUP BY models_name, item_description, subcategory_id
HAVING COUNT(*) > 1;

SELECT address, city, country, COUNT(*) AS duplicate_count
FROM Address
GROUP BY address, city, country
HAVING COUNT(*) > 1;

SELECT customer_name, address_id, customer_type, COUNT(*) AS duplicate_count
FROM Customer
GROUP BY customer_name, address_id, customer_type
HAVING COUNT(*) > 1;

SELECT location_name, address_id, location_type, COUNT(*) AS duplicate_count
FROM Location
GROUP BY location_name, address_id, location_type
HAVING COUNT(*) > 1;

SELECT employee_name, location_id, COUNT(*) AS duplicate_count
FROM Employee
GROUP BY employee_name, location_id
HAVING COUNT(*) > 1;

/* 11. Duplicate rental line rows */
SELECT rental_id, instance_id, price_paid, discount_offered, COUNT(*) AS duplicate_count
FROM RentalLineOrder
GROUP BY rental_id, instance_id, price_paid, discount_offered
HAVING COUNT(*) > 1;

/* 12. Rental lines with price/discount mismatch compared to Item */
SELECT 
    rlo.rental_line_id,
    rlo.rental_id,
    rlo.instance_id,
    rlo.price_paid,
    i.price AS item_price,
    rlo.discount_offered,
    i.discount AS item_discount
FROM RentalLineOrder rlo
JOIN ItemInstance ii ON rlo.instance_id = ii.instance_id
JOIN Item i ON ii.item_id = i.item_id
WHERE rlo.price_paid < 0
   OR rlo.discount_offered <> i.discount;

/* 13. Rentals exceeding allowed rental period */
SELECT 
    r.rental_id,
    r.start_date_time,
    r.end_date_time,
    i.rental_days_allowed,
    DATEDIFF(DAY, r.start_date_time, r.end_date_time) AS planned_rental_days
FROM Rental r
JOIN RentalLineOrder rlo ON r.rental_id = rlo.rental_id
JOIN ItemInstance ii ON rlo.instance_id = ii.instance_id
JOIN Item i ON ii.item_id = i.item_id
WHERE DATEDIFF(DAY, r.start_date_time, r.end_date_time) > i.rental_days_allowed;

/* 14. Item instances used in overlapping rentals */
SELECT 
    rlo1.instance_id,
    r1.rental_id AS rental_id_1,
    r2.rental_id AS rental_id_2,
    r1.start_date_time AS rental_1_start,
    r1.end_date_time AS rental_1_end,
    r2.start_date_time AS rental_2_start,
    r2.end_date_time AS rental_2_end
FROM RentalLineOrder rlo1
JOIN Rental r1 ON rlo1.rental_id = r1.rental_id
JOIN RentalLineOrder rlo2 
    ON rlo1.instance_id = rlo2.instance_id
   AND rlo1.rental_line_id < rlo2.rental_line_id
JOIN Rental r2 ON rlo2.rental_id = r2.rental_id
WHERE r1.start_date_time < r2.end_date_time
  AND r2.start_date_time < r1.end_date_time;

/* 15. Check source rows expected for DimLocation */
SELECT 
    l.location_id AS alt_location_key,
    l.location_type,
    l.address_id,
    a.address,
    a.city,
    a.country,
    l.location_name
FROM Location l
JOIN Address a ON l.address_id = a.address_id;

/* 16. Check source rows expected for DimEmployee */
SELECT 
    e.employee_id AS alt_employee_key,
    e.employee_name,
    e.location_id,
    l.location_name
FROM Employee e
JOIN Location l ON e.location_id = l.location_id;

/* 17. Check source rows expected for DimCustomer */
SELECT 
    c.customer_id AS alt_customer_key,
    c.customer_name,
    c.address_id,
    a.address,
    a.city,
    a.country,
    c.customer_type
FROM Customer c
JOIN Address a ON c.address_id = a.address_id;

/* 18. Check source rows expected for DimItemInstance */
SELECT 
    ii.instance_id AS alt_instance_key,
    ii.item_state,
    ii.distance_km,
    ii.item_id,
    i.models_name,
    ii.item_status,
    sc.subcategory_id,
    sc.subcat_description,
    cat.category_id,
    cat.description AS cat_description
FROM ItemInstance ii
JOIN Item i ON ii.item_id = i.item_id
JOIN SubCategory sc ON i.subcategory_id = sc.subcategory_id
JOIN Category cat ON sc.category_id = cat.category_id;

/* 19. Check source rows expected for FactRentalLineOrder */
SELECT
    rlo.rental_line_id,
    r.rental_id,
    r.rental_status,
    rlo.price_paid,
    rlo.discount_offered,
    CONVERT(INT, FORMAT(r.start_date_time, 'yyyyMMdd')) AS start_date_id,
    CONVERT(INT, FORMAT(r.return_date_time, 'yyyyMMdd')) AS return_date_id,
    CONVERT(INT, FORMAT(r.end_date_time, 'yyyyMMdd')) AS end_date_id,
    r.customer_id,
    r.employee_id,
    r.rental_location_id,
    r.return_location_id,
    rlo.instance_id,
    CAST(r.start_date_time AS TIME) AS start_time,
    CAST(r.return_date_time AS TIME) AS return_time,
    1 AS rental_count,
    rlo.price_paid AS rental_amount,
    DATEDIFF(MINUTE, r.start_date_time, r.return_date_time) AS rental_duration_minutes
FROM RentalLineOrder rlo
JOIN Rental r ON rlo.rental_id = r.rental_id;

/* 20. Compare operational expected fact rows against DW fact rows */
SELECT
    src.rental_id,
    src.instance_id,
    src.start_date_id,
    src.price_paid,
    src.discount_offered,
    src.rental_amount
FROM (
    SELECT
        r.rental_id,
        rlo.instance_id,
        CONVERT(INT, FORMAT(r.start_date_time, 'yyyyMMdd')) AS start_date_id,
        rlo.price_paid,
        rlo.discount_offered,
        rlo.price_paid AS rental_amount
    FROM RentalOrderOperationalDB.dbo.RentalLineOrder rlo
    JOIN RentalOrderOperationalDB.dbo.Rental r 
        ON rlo.rental_id = r.rental_id
) src
LEFT JOIN RentalOrderDW.dbo.FactRentalLineOrder dw
    ON src.rental_id = dw.rental_id
   AND src.instance_id = dw.instance_id
   AND src.start_date_id = dw.start_date_id
WHERE dw.rental_line_id IS NULL;

/* 21. Compare operational expected dimension counts against DW counts */
SELECT 'Location' AS entity, 
       (SELECT COUNT(*) FROM RentalOrderOperationalDB.dbo.Location) AS operational_count,
       (SELECT COUNT(*) FROM RentalOrderDW.dbo.DimLocation) AS dw_count
UNION ALL
SELECT 'Employee',
       (SELECT COUNT(*) FROM RentalOrderOperationalDB.dbo.Employee),
       (SELECT COUNT(*) FROM RentalOrderDW.dbo.DimEmployee)
UNION ALL
SELECT 'Customer',
       (SELECT COUNT(*) FROM RentalOrderOperationalDB.dbo.Customer),
       (SELECT COUNT(*) FROM RentalOrderDW.dbo.DimCustomer)
UNION ALL
SELECT 'ItemInstance',
       (SELECT COUNT(*) FROM RentalOrderOperationalDB.dbo.ItemInstance),
       (SELECT COUNT(*) FROM RentalOrderDW.dbo.DimItemInstance)
UNION ALL
SELECT 'RentalLineOrder',
       (SELECT COUNT(*) FROM RentalOrderOperationalDB.dbo.RentalLineOrder),
       (SELECT COUNT(*) FROM RentalOrderDW.dbo.FactRentalLineOrder);

