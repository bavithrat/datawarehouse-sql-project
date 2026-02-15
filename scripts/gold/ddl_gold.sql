/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

--------------- Create dimension: gold.dim_customers ---------------

if object_id('gold.dim_customers', 'V') is not null 
	drop view gold.dim_customers;
go

create view gold.dim_customers as 
select 
row_number() over(order by cst_id) as customer_key, 
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as firstname,
ci.cst_lastname as lastname,
la.cntry as country,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr != 'NA' then ci.cst_gndr
	 else coalesce(ca.gen, 'NA')
end as gender,
ca.bdate as birth_date,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ca.cid = ci.cst_key
left join silver.erp_loc_a101 la
on la.cid = ci.cst_key


--------------- Create dimension: gold.dim_products ---------------
  
if object_id('gold.dim_products', 'V') is not null 
	drop view gold.dim_products;
go

create view gold.dim_products as
select 
row_number() over(order by pi.prd_start_dt, pi.prd_key) as product_key,
pi.prd_id as product_id,
pi.prd_key as product_number,
pi.prd_nm as product_name,
pi.cat_id as category_id,
pc.cat as category,
pc.subcat as sub_category,
pc.maintenance as maintenance_required,
pi.prd_cost as product_cost,
pi.prd_line as product_line,
pi.prd_start_dt as start_date
from silver.crm_prd_info pi
left join silver.erp_px_cat_g1v2 pc
on pi.cat_id = pc.id
where pi.prd_end_dt is null -- fetches the current data and filters out the historical data


--------------- Create fact: gold.fact.sales ---------------
  
if object_id('gold.fact_sales', 'V') is not null 
	drop view gold.fact_sales;
go

create view gold.fact_sales as 
select 
sd.sls_ord_num as order_number,
p.product_key,
c.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_customers c
on c.customer_id = sd.sls_cust_id
left join gold.dim_products p
on p.product_number = sd.sls_prd_key

