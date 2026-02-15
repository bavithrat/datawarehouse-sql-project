select customer_key, count(*) as duplicate_count
from gold.dim_customers
group by customer_key
having count(*)>1


select product_key, count(*) as duplicate_count
from gold.dim_products
group by product_key
having count(*)>1


select * from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key = c.customer_key
left join gold.dim_products p
on s.product_key = p.product_key
where c.customer_key is null or p.product_key is null
