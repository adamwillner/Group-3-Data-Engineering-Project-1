USE RentalOrderOperationalDB;
GO

BULK INSERT Category
FROM 'C:\SQLData\Category.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT SubCategory
FROM 'C:\SQLData\SubCategory.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Item
FROM 'C:\SQLData\Item.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT ItemInstance
FROM 'C:\SQLData\ItemInstance.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Address
FROM 'C:\SQLData\Address.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Customer
FROM 'C:\SQLData\Customer.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Location
FROM 'C:\SQLData\Location.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Employee
FROM 'C:\SQLData\Employee.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT Rental
FROM 'C:\SQLData\Rental.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);

BULK INSERT RentalLineOrder
FROM 'C:\SQLData\RentalLineOrder.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    KEEPNULLS,
    TABLOCK
);
