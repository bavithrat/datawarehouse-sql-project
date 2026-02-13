--------------- Start of Quality check queries for silver layer crm_cust_info table ---------------

-- check for nulls or duplicate values in the primary keys
-- expectation: no result

select cst_id, count(*) from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

select * from silver.crm_cust_info where cst_id is null;

-- unique cst_id
select * from
(select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
from silver.crm_cust_info
where cst_id is not null)t
where t.flag_last != 1

-- check for unwanted spaces
-- expectation: no results

select cst_firstname from silver.crm_cust_info
where len(cst_firstname) != len(trim(cst_firstname))

select cst_lastname from silver.crm_cust_info
where len(cst_lastname) != len(trim(cst_lastname))


select distinct cst_marital_status
from silver.crm_cust_info

select distinct cst_gndr
from silver.crm_cust_info

--------------- End of Quality check queries for silver layer crm_cust_info table ---------------


--------------- Start of Quality check queries for silver layer crm_prd_info table ---------------

-- check for nulls or duplicate values in the primary keys
-- expectation: no result

select prd_id, count(prd_id)
from silver.crm_prd_info
group by prd_id
having count(prd_id) > 1 or prd_id is null

select * from silver.crm_prd_info where prd_id is null

-- check for unwanted spaces
-- expectation: no result

select prd_nm from 
silver.crm_prd_info
where LEN(prd_nm) != len(trim(prd_nm))


--check for nulls or negative numbers
-- expectation: no result

select prd_cost from 
silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- data standardization and consistency

select distinct prd_line from silver.crm_prd_info

-- check for invalid date orders that is end date must not be earlier than the start date
-- expectation: no result

select * from silver.crm_prd_info
where prd_start_dt > prd_end_dt 

--------------- End of Quality check queries for silver layer crm_prd_info table ---------------


--------------- Start of Quality check queries for silver layer crm_sales_details table ---------------

-- check for unwanted spaces
SELECT * FROM silver.crm_sales_details
where len(sls_ord_num) != len(sls_ord_num)

SELECT * FROM silver.crm_sales_details
where len(sls_prd_key) != len(sls_prd_key)

-- check for missing datas
SELECT * FROM silver.crm_sales_details
where sls_cust_id is null

-- order date must be earlier than the shipping date or due date
select * FROM silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- check for invalid data, missing data
select 
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
where sls_sales != sls_quantity * sls_price or 
sls_sales is null or sls_quantity is null or sls_price is null or
sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price


select * FROM silver.crm_sales_details

--------------- End of Quality check queries for silver layer crm_sales_details table ---------------

--------------- Start of Quality check queries for silver layer erp_cust_az12 table ---------------

-- check for invalid dates
select bdate from silver.erp_cust_az12
where bdate < '1925-01-01' or bdate > GETDATE()

-- data standardization and normalization
select distinct gen
from silver.erp_cust_az12

--------------- End of Quality check queries for silver layer erp_cust_az12 table ---------------

--------------- Start of Quality check queries for silver layer erp_loc_a101 table ---------------

-- data standardization and consistency
select distinct cntry
from silver.erp_loc_a101

select * from silver.erp_loc_a101

--------------- End of Quality check queries for silver layer erp_loc_a101 table ---------------

--------------- Start of Quality check queries for silver layer erp_px_cat_g1v2 table ---------------

-- check for unwanted spaces, data consistency and normalization

select * from silver.erp_px_cat_g1v2
where id != trim(id)

select * from silver.erp_px_cat_g1v2
where cat != trim(cat)

select distinct cat from silver.erp_px_cat_g1v2

select * from silver.erp_px_cat_g1v2
where subcat != trim(subcat)

select distinct subcat from silver.erp_px_cat_g1v2

select * from silver.erp_px_cat_g1v2
where maintenance != trim(maintenance)

--------------- End of Quality check queries for silver layer erp_px_cat_g1v2 table ---------------
