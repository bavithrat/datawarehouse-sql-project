/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

create or alter procedure bronze.load_bronze as
begin
	begin try
		declare @start_time_bronze datetime, @end_time_bronze datetime, @start_time datetime, @end_time datetime

		set @start_time_bronze = GETDATE()
		print '=============================================================';
		print '               Loading Bronze Layer Started';
		print '=============================================================';

		print '--------------------------------';
		print 'Loading CRM Table: crm_cust_info';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_cust_info';
		truncate table bronze.crm_cust_info

		print '>>> Inserting data into Table: crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock  -- inorder to improve the performance we can use this, we are locking the entire table while sql is loading the data into the table.
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading CRM Table: crm_prd_info';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_prd_info';
		truncate table bronze.crm_prd_info

		print '>>> Inserting data into Table: crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock  
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading CRM Table: crm_sales_details';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: crm_sales_details';
		truncate table bronze.crm_sales_details

		print '>>> Inserting data into Table: crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_cust_az12';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_cust_az12';
		truncate table bronze.erp_cust_az12

		print '>>> Inserting data into Table: erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_loc_a101';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_loc_a101';
		truncate table bronze.erp_loc_a101

		print '>>> Inserting data into Table: erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		print '--------------------------------';
		print 'Loading ERP Table: erp_px_cat_g1v2';
		print '--------------------------------';

		set @start_time = GETDATE()
		print '>>> Truncating Table: erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2

		print '>>> Inserting data into Table: erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\Bavithra Thiyagaraj\Desktop\SQL\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock  
		)
		set @end_time = GETDATE()
		print '>>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds'

		set @end_time_bronze = GETDATE()
		print '=============================================================';
		print '               Loading Bronze Layer Completed';
		print '=============================================================';
		print '>>> Load Duration for Bronze Layer: ' + cast(datediff(second, @start_time_bronze, @end_time_bronze) as nvarchar) + ' seconds'

	end try
	begin catch
		print '======================================================';
		print 'Error occured while loading the bronze layer';
		print 'Error message: ' + error_message();
		print 'Error number: ' + cast(error_number() as nvarchar);
		print 'Error state: ' + cast(error_state() as nvarchar);
		print '======================================================';
	end catch
end

    
exec bronze.load_bronze;

