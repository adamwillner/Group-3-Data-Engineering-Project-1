/* Load data into DimCustomer table*/

INSERT INTO RentalOrderDW.dbo.DimCustomer (
    customer_name,
    address_id,
    address,
    city,
    country,
    customer_type,
    alt_customer_key
)
SELECT
    COALESCE(c.customer_name, 'Missing'),
    a.address_id,
    COALESCE(a.address, 'Missing'),
    COALESCE(a.city, 'Missing'),
    COALESCE(a.country, 'Missing'),
    COALESCE(c.customer_type, 'Missing'),
    c.customer_id
FROM RentalOrderOperationalDB.dbo.Customer AS c
LEFT JOIN RentalOrderOperationalDB.dbo.Address AS a
    ON c.address_id = a.address_id;

/* Load data into DimEmployee table*/

INSERT INTO RentalOrderDW.dbo.DimEmployee (
    employee_name,
    location_id,
    location_name,
    alt_employee_key
)
SELECT
    COALESCE(e.employee_name, 'Missing'),
    COALESCE(e.location_id, -1),
    COALESCE(l.location_name, 'Missing'),
    e.employee_id -- becomes alt key
FROM RentalOrderOperationalDB.dbo.Employee AS e
LEFT JOIN RentalOrderOperationalDB.dbo.Location AS l
    ON e.location_id = l.location_id;

-- placeholder value for when no employee is connected to a sale
SET IDENTITY_INSERT DimEmployee ON; -- Override identity function temporarily
INSERT INTO RentalOrderDW.dbo.DimEmployee (employee_id, employee_name, location_id, location_name, alt_employee_key)
VALUES (-1, 'No Employee', -1, 'No Location', -1);
SET IDENTITY_INSERT DimEmployee OFF; -- Enable identity function again

SELECT * FROM RentalOrderDW.dbo.DimEmployee

/* Load data into DimLocation table */

INSERT INTO RentalOrderDW.dbo.DimLocation (
    location_type,
    address_id,
    address,
    city,
    country,
    location_name,
    alt_location_key
)
SELECT
    COALESCE(l.location_type, 'Missing'),
    a.address_id,
    COALESCE(a.address, 'Missing'),
    COALESCE(a.city, 'Missing'),
    COALESCE(a.country, 'Missing'),
    COALESCE(l.location_name, 'Missing'),
    l.location_id -- becomes alt key
FROM RentalOrderOperationalDB.dbo.Location AS l
LEFT JOIN RentalOrderOperationalDB.dbo.Address AS a
    ON l.address_id = a.address_id;

/* Load data into DimItemInstance */

INSERT INTO RentalOrderDW.dbo.DimItemInstance (
    item_state,
    distance_km,
    item_id,
    model_name,
    item_status,
    subcategory_id,
    subcat_description,
    category_id,
    cat_description,
    alt_instance_key
)
SELECT
    COALESCE(ii.item_state, 'Missing'),
    COALESCE(ii.distance_km, -1.0),
    i.item_id,
    COALESCE(i.models_name, 'Missing'),
    ii.item_status,
    sc.subcategory_id,
    COALESCE(sc.subcat_description, 'Missing'),
    c.category_id,
    COALESCE(c.description, 'Missing'),
    ii.instance_id -- becomes alt key
FROM RentalOrderOperationalDB.dbo.ItemInstance AS ii
LEFT JOIN RentalOrderOperationalDB.dbo.Item AS i
    ON ii.item_id = i.item_id
LEFT JOIN RentalOrderOperationalDB.dbo.SubCategory AS sc
    ON i.subcategory_id = sc.subcategory_id
LEFT JOIN RentalOrderOperationalDB.dbo.Category AS c
    ON sc.category_id = c.category_id;

/* Load data into DimDates */

DECLARE @StartDate date = '2020-01-01';
DECLARE @EndDate date = '2030-12-31';

WITH DateSeries AS (
    SELECT @StartDate AS dt
    UNION ALL
    SELECT DATEADD(day, 1, dt)
    FROM DateSeries
    WHERE dt < @EndDate
)
INSERT INTO RentalOrderDW.dbo.DimDate (
    date_id,
    [date],
    [day],
    month_number,
    month_name,
    [year]
)
SELECT
    YEAR(dt) * 10000 + MONTH(dt) * 100 + DAY(dt) AS date_id,
    dt AS [date],
    DATENAME(weekday, dt) AS [day],
    MONTH(dt) AS month_number,
    DATENAME(month, dt) AS month_name,
    YEAR(dt) AS [year]
FROM DateSeries
OPTION (MAXRECURSION 0);

/* Load data into FactRentalLineOrder */

INSERT INTO RentalOrderDW.dbo.FactRentalLineOrder (
    rental_id,
    rental_status,
    price_paid,
    discount_offered,
    start_date_id,
    return_date_id,
    end_date_id,
    customer_id,
    employee_id,
    rental_location_id,
    return_location_id,
    instance_id,
    start_time,
    return_time,
    rental_count,
    rental_amount,
    rental_duration_minutes
)
SELECT
    r.rental_id,
    COALESCE(r.rental_status, 'Missing'),
    COALESCE(rli.price_paid, 0),
    COALESCE(rli.discount_offered, 0),
    CONVERT(int, FORMAT(r.start_date_time, 'yyyyMMdd')),
    CONVERT(int, FORMAT(r.return_date_time, 'yyyyMMdd')),
    CONVERT(int, FORMAT(r.end_date_time, 'yyyyMMdd')),
    dc.customer_id,
    COALESCE(de.employee_id, -1),
    r.rental_location_id,
    r.return_location_id,
    dii.instance_id,
    COALESCE(CAST(r.start_date_time AS TIME), '00:00:00') AS start_time,
    CAST(r.return_date_time AS time),
    1,
    SUM(rli.price_paid) OVER (PARTITION BY rli.rental_id) AS rental_amount,
    DATEDIFF(minute, r.start_date_time, r.return_date_time)
FROM RentalOrderOperationalDB.dbo.RentalLineOrder AS rli
LEFT JOIN RentalOrderOperationalDB.dbo.Rental AS r
    ON rli.rental_id = r.rental_id
LEFT JOIN RentalOrderDW.dbo.DimEmployee AS de
    ON r.employee_id = de.alt_employee_key
LEFT JOIN RentalOrderDW.dbo.DimCustomer AS dc
    ON r.customer_id = dc.alt_customer_key
LEFT JOIN RentalOrderDW.dbo.DimItemInstance AS dii
    ON rli.instance_id = dii.alt_instance_key
LEFT JOIN RentalOrderDW.dbo.DimLocation AS dl_rental
    ON r.rental_location_id = dl_rental.location_id
LEFT JOIN RentalOrderDW.dbo.DimLocation AS dl_return
    ON r.return_location_id = dl_return.location_id
