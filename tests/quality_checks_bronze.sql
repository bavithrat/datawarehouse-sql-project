/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks before loading the data into the Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
    - After cleaning the data, insert it into the Silver layer
===============================================================================
*/

--------------- Start of Quality check queries for bronze layer crm_cust_info table ---------------

-- check for nulls or duplicate values in the primary keys
-- expectation: no result

select cst_id, count(*) from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

select * from bronze.crm_cust_info where cst_id is null;

-- unique cst_id
select * from
(select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id is not null)t
where t.flag_last != 1

-- check for unwanted spaces
-- expectation: no results

select cst_firstname from bronze.crm_cust_info
where len(cst_firstname) != len(trim(cst_firstname))

select cst_lastname from bronze.crm_cust_info
where len(cst_lastname) != len(trim(cst_lastname))


select distinct cst_marital_status
from bronze.crm_cust_info

select distinct cst_gndr
from bronze.crm_cust_info

--------------- End of Quality check queries for bronze layer crm_cust_info table ---------------


--------------- Start of Quality check queries for bronze layer crm_prd_info table ---------------

-- check for nulls or duplicate values in the primary keys
-- expectation: no result

select prd_id, count(prd_id)
from bronze.crm_prd_info
group by prd_id
having count(prd_id) > 1 or prd_id is null

select * from bronze.crm_prd_info where prd_id is null

-- check for unwanted spaces
-- expectation: no result

select prd_nm from 
bronze.crm_prd_info
where LEN(prd_nm) != len(trim(prd_nm))


--check for nulls or negative numbers
-- expectation: no result

select prd_cost from 
bronze.crm_prd_info
where prd_cost <= 0 or prd_cost is null

-- data standardization and consistency

select distinct prd_line from bronze.crm_prd_info

-- check for invalid date orders that is end date must not be earlier than the start date
-- expectation: no result

select * from bronze.crm_prd_info
where prd_start_dt > prd_end_dt 

select *, 
dateadd(day, -1, lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) as prd_end_dt
from bronze.crm_prd_info
where prd_key = 'AC-HE-HL-U509-R'

--------------- End of Quality check queries for bronze layer crm_prd_info table ---------------

--------------- Start of Quality check queries for bronze layer crm_sales_details table ---------------

-- check for unwanted spaces
SELECT * FROM bronze.crm_sales_details
where len(sls_ord_num) != len(sls_ord_num)

SELECT * FROM bronze.crm_sales_details
where len(sls_prd_key) != len(sls_prd_key)

-- check for missing datas
SELECT * FROM bronze.crm_sales_details
where sls_cust_id is null

--check for invalid dates
-- length of the date must be eight
-- check for the outliers by validating the boundaries of the date range; 
-- for example if your business started after 19990626 then we should not have any sales date before that

select 
nullif(sls_order_dt, 0) as sles_order_dt
FROM bronze.crm_sales_details
where sls_order_dt <= 0 or len(sls_order_dt) != 8 or 
sls_order_dt < 19990626 or 
sls_order_dt > 20500101

--check for invalid dates
-- length of the date must be eight
-- check for the outliers by validating the boundaries of the date range; 
-- for example if your business started after 19990626 then we should not have any sales date before that

select 
nullif(sls_ship_dt, 0) as sls_ship_dt
FROM bronze.crm_sales_details
where sls_ship_dt <= 0 or len(sls_ship_dt) != 8 or 
sls_ship_dt < 19990626 or 
sls_ship_dt > 20500101

--check for invalid dates
-- length of the date must be eight
-- check for the outliers by validating the boundaries of the date range; 
-- for example if your business started after 19990626 then we should not have any sales date before that

select 
nullif(sls_due_dt, 0) as sls_due_dt
FROM bronze.crm_sales_details
where sls_due_dt <= 0 or len(sls_due_dt) != 8 or 
sls_due_dt < 19990626 or 
sls_due_dt > 20500101

-- order date must be earlier than the shipping date or due date
select * FROM bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- check for invalid data, missing data
select 
case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
sls_quantity,
case when sls_price <= 0 or sls_price is null then sls_sales / nullif(sls_quantity, 0)
	else sls_price
end as sls_price
FROM bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price or 
sls_sales is null or sls_quantity is null or sls_price is null or
sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price

--------------- End of Quality check queries for bronze layer crm_sales_details table ---------------

--------------- Start of Quality check queries for bronze layer erp_cust_az12 table ---------------

-- check for invalid dates
select bdate from bronze.erp_cust_az12
where bdate < '1925-01-01' or bdate > GETDATE()

-- data standardization and normalization
select distinct gen, 
case when upper(trim(gen)) in  ('F', 'FEMALE') then 'Female'
	when upper(trim(gen)) in ('M', 'MALE') then 'Male'
	else 'NA'
end as gen
from bronze.erp_cust_az12

--------------- End of Quality check queries for bronze layer erp_cust_az12 table ---------------

--------------- Start of Quality check queries for bronze layer erp_loc_a101 table ---------------

-- data standardization and consistency
select distinct cntry
from bronze.erp_loc_a101

--------------- End of Quality check queries for bronze layer erp_loc_a101 table ---------------

--------------- Start of Quality check queries for bronze layer erp_px_cat_g1v2 table ---------------

-- check for unwanted spaces, data consistency and normalization

select * from bronze.erp_px_cat_g1v2
where id != trim(id)


select * from bronze.erp_px_cat_g1v2
where cat != trim(cat)

select distinct cat from bronze.erp_px_cat_g1v2

select * from bronze.erp_px_cat_g1v2
where subcat != trim(subcat)

select distinct subcat from bronze.erp_px_cat_g1v2

select * from bronze.erp_px_cat_g1v2
where maintenance != trim(maintenance)

--------------- End of Quality check queries for bronze layer erp_px_cat_g1v2 table ---------------
