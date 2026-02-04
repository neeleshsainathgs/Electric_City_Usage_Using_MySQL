-- ELECTRICITY CITY PROJECT


-- DATABASE CREATION

create database electric_project;
use electric_project;

-- IMPORTING TABLES

show tables;

SELECT 
    *
FROM
    appliance_usage;
SELECT 
    *
FROM
    billing_info;
SELECT 
    *
FROM
    calculated_metrics;
SELECT 
    *
FROM
    environmental_data;
SELECT 
    *
FROM
    household_info;

desc appliance_usage;
desc billing_info;
desc calculated_metrics;
desc environmental_data;
desc household_info;


-- Project Task 1: Update the payment_status in the billing_info table based on the cost_usd value. Use CASE...END logic.

-- Cost_usd > 200 set “high”
-- Cost_usd >  100 and 200  set “medium”
-- Else “Low”
-- Use the UPDATE statement along with CASE to set values conditionally.


SELECT 
    *
FROM
    billing_info;
desc billing_info;


UPDATE billing_info 
SET 
    payment_status = CASE
        WHEN cost_usd > 200 THEN 'High'
        WHEN cost_usd BETWEEN 100 AND 200 THEN 'Medium'
        ELSE 'Low'
    END;

SELECT 
    *
FROM
    billing_info;



-- Project Task 2: (Using Group by) For each household, show the monthly electricity usage, rank of usage within each year, and classify usage level.

-- Hint1: Use SUM, MONTHNAME, Date_format, RANK() OVER, and CASE.
-- Hint2: update Usage level criteria using total Kwh
-- Sum(total kwh > 500 then “High”
-- Else “Low”


SELECT 
    *
FROM
    appliance_usage;
desc appliance_usage;


select household_id, count(*) as appliance_count,
    rank() over (order by count(*) desc) as usage_rank,
    case
        when count(*) > 5 then 'High'
        else 'Low'
    end as usage_level
from appliance_usage
group by household_id;



-- Project Task 3: Create a monthly usage pivot table showing usage for January, February, and March.

-- Hint: Use conditional aggregation using Pivot concept with CASE WHEN.


select * from billing_info;
desc billing_info;


SELECT household_id,
    ROUND(SUM(CASE
                WHEN month = 'Jan' THEN total_kwh
                ELSE 0
            END),
            2) AS January,
    ROUND(SUM(CASE
                WHEN month = 'Feb' THEN total_kwh
                ELSE 0
            END),
            2) AS February,
    ROUND(SUM(CASE
                WHEN month = 'Mar' THEN total_kwh
                ELSE 0
            END),
            2) AS March,
    ROUND(SUM(CASE
                WHEN month = 'Apr' THEN total_kwh
                ELSE 0
            END),
            2) AS April,
    ROUND(SUM(CASE
                WHEN month = 'May' THEN total_kwh
                ELSE 0
            END),
            2) AS May,
    ROUND(SUM(CASE
                WHEN month = 'Jun' THEN total_kwh
                ELSE 0
            END),
            2) AS June,
    ROUND(SUM(CASE
                WHEN month = 'Jul' THEN total_kwh
                ELSE 0
            END),
            2) AS July,
    ROUND(SUM(CASE
                WHEN month = 'Aug' THEN total_kwh
                ELSE 0
            END),
            2) AS August,
    ROUND(SUM(CASE
                WHEN month = 'Sep' THEN total_kwh
                ELSE 0
            END),
            2) AS September,
    ROUND(SUM(CASE
                WHEN month = 'Oct' THEN total_kwh
                ELSE 0
            END),
            2) AS October,
    ROUND(SUM(CASE
                WHEN month = 'Nov' THEN total_kwh
                ELSE 0
            END),
            2) AS November,
    ROUND(SUM(CASE
                WHEN month = 'Dec' THEN total_kwh
                ELSE 0
            END),
            2) AS December
FROM
    billing_info
GROUP BY household_id;



-- Project Task 4: Show average monthly usage per household with city name.

-- Hint: Use a subquery grouped by household and month.


SELECT 
    *
FROM
    appliance_usage;
SELECT 
    *
FROM
    household_info;
desc appliance_usage;
desc household_usage;


SELECT 
    h.household_id, h.city, COUNT(*) AS Household_Activity_Count
FROM
    household_info h
        JOIN
    appliance_usage a ON h.household_id = a.household_id
GROUP BY h.household_id , h.city;



-- Project Task 5: Retrieve AC usage and outdoor temperature for households where AC usage is high.

-- Hint: Use a subquery to filter AC usage above 100.(High)


SELECT 
    *
FROM
    appliance_usage;
SELECT 
    *
FROM
    environmental_data;
desc appliance_usage;
desc environmental_data;


SELECT 
    a.household_id,
    a.kwh_usage_AC AS ac_usage_kwh,
    e.avg_outdoor_temp
FROM
    appliance_usage a
        JOIN
    environmental_data e ON a.household_id = e.household_id
WHERE
    a.kwh_usage_AC > 100;



-- Project Task 6: Create a procedure to return billing info for a given region.

-- Hint: Use IN parameter in a CREATE PROCEDURE


SELECT 
    *
FROM
    billing_info;
SELECT 
    *
FROM
    household_info;
desc billing_info;
desc household_info;


DELIMITER //

CREATE PROCEDURE billing_info(IN region_name VARCHAR(50))
BEGIN
    SELECT b.*
    FROM billing_info b
    JOIN household_info h
    ON b.household_id = h.household_id
    WHERE h.region = region_name;
END //

DELIMITER ;

call billing_info('West');



-- Project Task 7: Create a procedure to calculate total usage for a household and return it.

-- Hint: Use INOUT parameter and assign with SELECT INTO.


SELECT 
    *
FROM
    appliance_usage;
desc appliance_usage;


DELIMITER //

CREATE PROCEDURE total_usage(
    IN p_household_id INT,
    INOUT p_total_usage DECIMAL(10,2)
)
BEGIN
    SELECT
        SUM(
            kwh_usage_fridge +
            kwh_usage_heater +
            kwh_usage_ac +
            kwh_usage_washer +
            kwh_usage_dryer +
            kwh_usage_oven +
            kwh_usage_microwave +
            kwh_usage_tv +
            kwh_usage_computer +
            kwh_usage_lighting
        )
    INTO p_total_usage
    FROM appliance_usage
    WHERE household_id = p_household_id;
END //

DELIMITER ;

set @result = 0;
call total_usage(1, @result);
SELECT @result AS total_usage_kwh;



-- Project Task 8: Automatically calculate cost_usd before inserting into billing_info.

-- Hint: Use BEFORE INSERT trigger and assign NEW.cost_usd.


SELECT 
    *
FROM
    billing_info;
desc billing_info;

DELIMITER //

CREATE TRIGGER before_billing_insert
BEFORE INSERT ON billing_info
FOR EACH ROW
BEGIN
    SET NEW.cost_usd = NEW.total_kwh * 0.12;
END //

DELIMITER ;

SHOW TRIGGERS;

INSERT INTO billing_info (
    household_id,
    total_kwh,
    payment_status
)
VALUES (
    1,
    350,
    NULL
);

SELECT 
    household_id, total_kwh, cost_usd
FROM
    billing_info
WHERE
    household_id = 1;



-- Project Task 9 : After a new billing entry, insert calculated metrics into calculated_metrics.

-- Hint1: Use AFTER INSERT trigger and NEW keyword.

-- Hint 2:  Calculations(metrics)

-- House hold_id = new.house_hold_id
-- KWH per_occupant = total_kwh /Num_occupants
-- Usage category = total_kwh > 600 set “High” else “Moderate”


SELECT 
    *
FROM
    billing_info;
SELECT 
    *
FROM
    household_info;
SELECT 
    *
FROM
    calculated_metrics;

desc billing_info;
desc household_info;
desc calculated_metrics;

DELIMITER //

CREATE TRIGGER after_billing_insert
AFTER INSERT ON billing_info
FOR EACH ROW
BEGIN
    DECLARE occupants INT;

    SELECT num_occupants
    INTO occupants
    FROM household_info
    WHERE household_id = NEW.household_id;

    INSERT INTO calculated_metrics (
        household_id,
        kwh_per_occupant,
        usage_category
    )
    VALUES (
        NEW.household_id,
        NEW.total_kwh / occupants,
        CASE
            WHEN NEW.total_kwh > 600 THEN 'High'
            ELSE 'Moderate'
        END
    );
END //

DELIMITER ;

INSERT INTO billing_info (
    household_id,
    total_kwh,
    payment_status
)
VALUES (
    2,
    720,
    NULL
);

SELECT 
    *
FROM
    calculated_metrics
WHERE
    household_id = 2;


-- ER DIAGRAM and FOREIGN KEY


create database er_diagrams;
use er_diagrams;

-- FACT TABLE

CREATE TABLE fact_electricity_usage (
    household_id INT PRIMARY KEY,
    month VARCHAR(20),
    year DATE,
    Total_kwh INT,
    Bill_amount BIGINT,
    Kwh_per_sqft DECIMAL(10 , 2 ),
    Kwh_per_occupant INT,
    Usage_category INT
);


-- DIMENSION TABLE
CREATE TABLE dim_household (
    household_id INT PRIMARY KEY,
    city VARCHAR(20),
    num_occupants INT,
    floor_area_sqft INT,
    FOREIGN KEY (household_id)
        REFERENCES fact_electricity_usage (household_id)
);

CREATE TABLE dim_time (
    household_id INT PRIMARY KEY,
    billing_month DATE,
    billing_year DATE,
    quarter INT,
    FOREIGN KEY (household_id)
        REFERENCES fact_electricity_usage (household_id)
);

CREATE TABLE dim_appliance (
    household_id INT PRIMARY KEY,
    appliance_name VARCHAR(20),
    appliance_type VARCHAR(20),
    FOREIGN KEY (household_id)
        REFERENCES fact_electricity_usage (household_id)
);

CREATE TABLE dim_environmental_data (
    household_id INT PRIMARY KEY,
    temperature INT,
    humidity INT,
    season VARCHAR(20),
    FOREIGN KEY (household_id)
        REFERENCES fact_electricity_usage (household_id)
);


show tables;