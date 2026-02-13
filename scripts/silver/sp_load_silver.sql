create or alter procedure silver.load_silver as
begin
	begin try
		declare @start_time_silver datetime, @end_time_silver datetime, @start_time datetime, @end_time datetime

		set @start_time_silver = GETDATE()
		print '=============================================================';
		print '               Loading Silver Layer Started';
		print '=============================================================';

		print '--------------------------------';
		print 'Loading CRM Table: crm_cust_info';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_cust_info';
		truncate table silver.crm_cust_info;

		print '>>> Inserting data into Table: crm_cust_info';
		insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select cst_id,
		cst_key, 
		trim(cst_firstname) as cst_firstname, 
		trim(cst_lastname) as cst_lastname,
		case when upper(trim(cst_marital_status)) = 'M' then 'Married'
			 when upper(trim(cst_marital_status)) = 'S' then 'Single'
			 else 'NA'
		end as cst_marital_status,
		case when upper(trim(cst_gndr)) = 'M' then 'Male'
			 when upper(trim(cst_gndr)) = 'F' then 'Female'
			 else 'NA'
		end as cst_gndr,
		cst_create_date
		from
		(select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null)t
		where t.flag_last = 1;

		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading CRM Table: crm_prd_info';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_prd_info';
		truncate table silver.crm_prd_info

		print '>>> Inserting data into Table: crm_prd_info';
		insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select 
		prd_id,
		replace(SUBSTRING(trim(prd_key), 1, 5), '-', '_') as cat_id,
		SUBSTRING(trim(prd_key), 7, LEN(trim(prd_key))) as prd_key, 
		trim(prd_nm) as prd_nm,
		isnull(prd_cost, 0) as prd_cost,
		case upper(trim(prd_line)) 
			 when 'M' then 'Mountain'
			 when 'R' then 'Road'
			 when 'S' then 'Sea'
			 when 'T' then 'Travel'
			 else 'NA'
		end as prd_line, 
		prd_start_dt,
		dateadd(day, -1, lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) as prd_end_dt
		from bronze.crm_prd_info;

		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading CRM Table: crm_sales_details';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_sales_details';
		truncate table silver.crm_sales_details

		print '>>> Inserting data into Table: crm_sales_details';
		insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,	
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt, 
			sls_due_dt, 
			sls_sales,
			sls_quantity,
			sls_price
		)
		select 
		trim(sls_ord_num) as sls_ord_num,
		trim(sls_prd_key) as sls_prd_key,
		sls_cust_id,
		case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
			else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
			else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales,
		sls_quantity,
		case when sls_price <= 0 or sls_price is null then sls_sales / nullif(sls_quantity, 0)
			else sls_price
		end as sls_price
		from bronze.crm_sales_details;

		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_cust_az12';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_cust_az12';
		truncate table silver.erp_cust_az12

		print '>>> Inserting data into Table: erp_cust_az12';
		insert into silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		select
		case when cid like 'NAS%' then substring(trim(cid), 4, len(trim(cid)))
			else cid
		end as cid,
		case when bdate > GETDATE() then null
			else bdate
		end as bdate,
		case when upper(trim(gen)) in  ('F', 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M', 'MALE') then 'Male'
			else 'NA'
		end as gen
		from bronze.erp_cust_az12 

		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_loc_a101';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_loc_a101';
		truncate table silver.erp_loc_a101

		print '>>> Inserting data into Table: erp_loc_a101';
		insert into silver.erp_loc_a101(
			cid,
			cntry
		)
		select 
		replace(trim(cid),'-','') as cid,
		case when upper(trim(cntry)) = 'DE' then 'Germany'
			 when upper(trim(cntry)) in ('US', 'USA') then 'United States'
			 when trim(cntry) = '' or cntry is null then 'NA'
			 else trim(cntry)
		end as cntry
		from bronze.erp_loc_a101 

		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_px_cat_g1v2';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_px_cat_g1v2';
		truncate table silver.erp_px_cat_g1v2

		print '>>> Inserting data into Table: erp_px_cat_g1v2';
		insert into silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		select 
		trim(id),
		trim(cat), 
		trim(subcat), 
		trim(maintenance) 
		from bronze.erp_px_cat_g1v2
		
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		set @end_time_silver = GETDATE()
		print '=============================================================';
		print '               Loading Silver Layer Completed';
		print '=============================================================';
		print '>>> Load Duration for Silver Layer: ' + cast(datediff(second, @start_time_silver, @end_time_silver) as nvarchar) + ' seconds'

	end try
	
	begin catch
		print '======================================================';
		print 'Error occured while loading the Silver layer';
		print 'Error message: ' + error_message();
		print 'Error number: ' + cast(error_number() as nvarchar);
		print 'Error state: ' + cast(error_state() as nvarchar);
		print '======================================================';
	end catch

end
