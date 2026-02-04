create database er;
use er;
drop table fact_electricity_usage;
create table fact_electricity_usage (
household_id int primary key,
month varchar(20),
year date,
Total_kwh int,
Bill_amount bigint,
Kwh_per_sqft decimal(10,2),
Kwh_per_occupant int,
Usage_category int
);
drop table dim_household;
create table dim_household 
(household_id int primary key,
city varchar(20),
num_occupants int,
floor_area_sqft int,
foreign key (household_id) references fact_electricity_usage (household_id)
);
create table dim_time (
household_id int primary key,
billing_month date,
billing_year date,
quarter int,
foreign key (household_id) references fact_electricity_usage (household_id));
create table dim_appliance (

household_id int primary Key,
appliance_name varchar(20),
appliance_type varchar(20),
foreign key (household_id) references fact_electricity_usage(household_id));
create table dim_environmental_data (
household_id int primary key,
temperature int,
humidity int,
season varchar(20),
foreign key (household_id) references fact_electricity_usage(household_id));



show tables;