# Vehicle Rental System - SQL Queries Documentation

## Overview

This document provides comprehensive documentation for SQL queries designed for a vehicle rental management system. The system manages users, vehicles, and bookings with various query requirements to retrieve and analyze data efficiently.

---

## Database Schema

### Users Table
Stores customer and admin information.

| Column | Type | Description |
|--------|------|-------------|
| user_id | UUID | Primary key, unique identifier |
| role | ENUM | User role (Customer/Admin) |
| name | VARCHAR | User's full name |
| email | VARCHAR | User's email address, unique identifier |
| phone | VARCHAR | Contact phone number |
| password | VARCHAR | User's password |


### Vehicles Table
Contains information about available vehicles for rent.

| Column | Type | Description |
|--------|------|-------------|
| vehicle_id | UUID | Primary key, unique identifier |
| name | VARCHAR | Vehicle name/brand |
| type | ENUM | Vehicle type (car/bike/truck) |
| model | VARCHAR | Model year |
| registration_number | VARCHAR | Vehicle registration plate |
| rental_price | INT | Daily rental price |
| status | ENUM | Current status (available/rented/maintenance) |

### Bookings Table
Records all vehicle booking transactions.

| Column | Type | Description |
|--------|------|-------------|
| booking_id | UUID | Primary key, unique identifier |
| user_id | UUID | Foreign key to Users table |
| vehicle_id | UUID | Foreign key to Vehicles table |
| start_date | DATE | Booking start date |
| end_date | DATE | Booking end date |
| status | ENUM | Booking status (completed/confirmed/pending) |
| total_cost | INT | Total booking cost |

---

## Sample Data

### Users

| user_id | name | email | phone | role |
|---------|------|-------|-------|------|
| 1 | Alice | alice@example.com | 1234567890 | Customer |
| 2 | Bob | bob@example.com | 0987654321 | Admin |
| 3 | Charlie | charlie@example.com | 1122334455 | Customer |

### Vehicles

| vehicle_id | name | type | model | registration_number | rental_price | status |
|------------|------|------|-------|---------------------|--------------|--------|
| 1 | Toyota Corolla | car | 2022 | ABC-123 | 50 | available |
| 2 | Honda Civic | car | 2021 | DEF-456 | 60 | rented |
| 3 | Yamaha R15 | bike | 2023 | GHI-789 | 30 | available |
| 4 | Ford F-150 | truck | 2020 | JKL-012 | 100 | maintenance |

### Bookings

| booking_id | user_id | vehicle_id | start_date | end_date | status | total_cost |
|------------|---------|------------|------------|----------|--------|------------|
| 1 | 1 | 2 | 2023-10-01 | 2023-10-05 | completed | 240 |
| 2 | 1 | 2 | 2023-11-01 | 2023-11-03 | completed | 120 |
| 3 | 3 | 2 | 2023-12-01 | 2023-12-02 | confirmed | 60 |
| 4 | 1 | 1 | 2023-12-10 | 2023-12-12 | pending | 100 |

---

## Query 1: JOIN - Booking Information

### Problem Statement

Retrieve comprehensive booking information by combining data from multiple tables. The query should display the booking ID, customer name, vehicle name, start date, end date, and booking status for all bookings in the system.

### Solution

```sql
select
  b.booking_id,u.name as customer_name,v.name as vehicle_name,b.start_date,b.end_date,b.status 
  from bookings as b 
  inner join users as u on b.user_id=u.user_id
  inner join vehicles as v on b.vehicle_id=v.vehicle_id;
```

### Explanation

**How It Works:**

1. **Base Table**: The query starts with the `bookings` table (aliased as `b`) as the primary data source.

2. **First JOIN**: `INNER JOIN users AS u ON b.user_id = u.user_id`
   - Connects the bookings table with the users table
   - Matches records where the `user_id` in bookings corresponds to the `user_id` in users
   - This allows us to retrieve customer information (specifically the customer name)

3. **Second JOIN**: `INNER JOIN vehicles AS v ON b.vehicle_id = v.vehicle_id`
   - Connects the result set with the vehicles table
   - Matches records where the `vehicle_id` in bookings corresponds to the `vehicle_id` in vehicles
   - This provides vehicle details (specifically the vehicle name)

4. **Column Aliases**: Uses `AS` to create readable column names:
   - `u.name AS customer_name` - Displays the user's name as "customer_name"
   - `v.name AS vehicle_name` - Displays the vehicle's name as "vehicle_name"

**Why INNER JOIN?**
- INNER JOIN ensures that only bookings with valid user and vehicle references are returned
- If a booking references a non-existent user or vehicle, it will be excluded from results
- This maintains data integrity in the output

### Output

| booking_id | customer_name | vehicle_name | start_date | end_date | status |
|------------|---------------|--------------|------------|----------|---------|
| 1 | Alice | Honda Civic | 2023-10-01 | 2023-10-05 | completed |
| 2 | Alice | Honda Civic | 2023-11-01 | 2023-11-03 | completed |
| 3 | Charlie | Honda Civic | 2023-12-01 | 2023-12-02 | confirmed |
| 4 | Alice | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending |

---

## Query 2: EXISTS - Unbooked Vehicles

### Problem Statement

Identify all vehicles in the system that have never been booked by any customer. This helps the business understand which vehicles are underutilized and may need marketing attention or pricing adjustments.

### Solution

```sql
select 
  vehicle_id,name,type,model,registration_number,rental_price,status
  from vehicles
  where not exists( select * from bookings where vehicle_id=vehicles.vehicle_id);
```

### Explanation

**How It Works:**

1. **Main Query**: Selects all columns from the `vehicles` table to provide complete vehicle information.

2. **Subquery with EXISTS**:
   ```sql
   SELECT * FROM bookings WHERE vehicle_id = vehicles.vehicle_id
   ```
   - This correlated subquery checks if there are any bookings for each vehicle
   - For each vehicle row, it searches the bookings table for matching vehicle_id
   - Returns TRUE if at least one booking exists, FALSE if no bookings exist

3. **NOT EXISTS Operator**:
   - Inverts the result of the EXISTS check
   - Returns vehicles where NO bookings exist
   - Efficiently filters out vehicles that have been booked at least once

### Output

| vehicle_id | name | type | model | registration_number | rental_price | status |
|------------|------|------|-------|---------------------|--------------|--------|
| 3 | Yamaha R15 | bike | 2023 | GHI-789 | 30 | available |
| 4 | Ford F-150 | truck | 2020 | JKL-012 | 100 | maintenance |

---

## Query 3: WHERE - Available Vehicles by Type

### Problem Statement

Retrieve all vehicles of a specific type (e.g., "car") that are currently available for rent. This query is essential for customers searching for available vehicles of their preferred type.

### Solution

```sql
select  * from vehicles where type='car' and status='available';
```

### Explanation

**How It Works:**

1. **SELECT * FROM vehicles**: Retrieves all columns from the vehicles table.

2. **WHERE Clause with Multiple Conditions**:
   - `type = 'car'`: Filters vehicles to only include cars (excludes bikes, trucks, etc.)
   - `status = 'available'`: Filters to only show vehicles currently available for rental
   - `AND` operator: Both conditions must be TRUE for a row to be included

### Output

| vehicle_id | name | type | model | registration_number | rental_price | status |
|------------|------|------|-------|---------------------|--------------|--------|
| 1 | Toyota Corolla | car | 2022 | ABC-123 | 50 | available |

---

## Query 4: GROUP BY & HAVING - Popular Vehicles

### Problem Statement

Identify vehicles that are frequently booked by finding the total number of bookings for each vehicle and displaying only those vehicles with more than 2 bookings. This helps identify popular vehicles that may need fleet expansion or higher pricing.

### Solution

```sql
select
    v.name as vehicle_name,
    count(v.vehicle_id) as total_bookings
from
    bookings as b
left join
    vehicles as v on b.vehicle_id = v.vehicle_id
group by
    v.name having count(v.vehicle_id) > 2;
```

### Explanation

**How It Works:**

1. **FROM and JOIN**:
   ```sql
   FROM bookings AS b
   LEFT JOIN vehicles AS v ON b.vehicle_id = v.vehicle_id
   ```
   - Starts with the bookings table (since we're counting bookings)
   - LEFT JOIN ensures all bookings are included even if vehicle details are missing
   - Links bookings to vehicles to get vehicle names

2. **Aggregation**:
   ```sql
   COUNT(v.vehicle_id) AS total_bookings
   ```
   - Counts the number of bookings for each vehicle
   - Each booking record contributes 1 to the count
   - Aliased as `total_bookings` for clarity

3. **GROUP BY**:
   ```sql
   GROUP BY v.name
   ```
   - Groups all bookings by vehicle name
   - Creates aggregated rows, one per unique vehicle
   - Required when using aggregate functions like COUNT

4. **HAVING Clause**:
   ```sql
   HAVING COUNT(v.vehicle_id) > 2
   ```
   - Filters the grouped results (works like WHERE but for aggregated data)
   - Only includes vehicles with MORE than 2 bookings
   - Applied AFTER grouping, unlike WHERE which is applied before

**Why LEFT JOIN Instead of INNER JOIN?**
- While INNER JOIN would work in this scenario, LEFT JOIN is safer
- It ensures all bookings are counted even if there's data integrity issue
- In a well-maintained database, both would produce the same results

**Step-by-Step Execution:**

1. **Join Phase**: Combine bookings with vehicle names
   ```
   Honda Civic (booking 1)
   Honda Civic (booking 2)
   Honda Civic (booking 3)
   Toyota Corolla (booking 4)
   ```

2. **Group Phase**: Group by vehicle name
   ```
   Honda Civic: [booking 1, booking 2, booking 3]
   Toyota Corolla: [booking 4]
   ```

3. **Count Phase**: Count bookings per group
   ```
   Honda Civic: 3 bookings
   Toyota Corolla: 1 booking
   ```

4. **Having Phase**: Filter groups where count > 2
   ```
   Honda Civic: 3 bookings ✓ (included)
   Toyota Corolla: 1 booking ✗ (excluded)
   ```

### Output

| vehicle_name | total_bookings |
|--------------|----------------|
| Honda Civic | 3 |


---


