-- (Query 1) Revenue, leads, conversion, and average ticket month by month
-- Columns: month, leads (#), sales (#), revenue (k, R$), conversion (%), average ticket (k, R$)
with 
	leads as (
	SELECT
		date_trunc('month', visit_page_date)::date as visit_page_month,
		count(*) as visit_page_count
		from sales.funnel
	group by visit_page_month
	order by visit_page_month
	),
	payments as (
	select 
		date_trunc('month', fun.paid_date)::date as paid_month,
		count(fun.paid_date) as paid_count,
		sum(pro.price * (1+ fun.discount)) as revenue

	from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id
	where fun.paid_date is not null
	group by paid_month
	order by paid_month
)

SELECT
	leads.visit_page_month as "month",
	leads.visit_page_count as "leads (#)",
	payments.paid_count as "sales (#)",
	(payments.revenue/1000) as "sales (k, R$)",
	(payments.paid_count::float/leads.visit_page_count::float) as "convertion (%)",
	(payments.revenue/payments.paid_count/1000) as "average ticket(k, R$)"
from leads
	left join payments
		on leads.visit_page_month = paid_month



-- (Query 2) States that sold the most
-- Columns: country, state, sales (#)
select 
	'Brazil' as country, 
	cus.state as state,
	count(fun.paid_date) as sales
from sales.funnel as fun
	left join sales.customers as cus
		on cus.customer_id = fun.customer_id
where paid_date between '2021-08-01' and '2021-08-31'
group by state, country
order by sales desc
limit 5


-- (Query 3) Brands that sold the most in the month
-- Columns: brand, sales (#)
select 
	pro.brand,
	count(fun.paid_date) as sales

from sales.funnel as fun
	left join sales.products as pro
		on pro.product_id = fun.product_id
where paid_date between '2021-08-01' and '2021-08-31'		
group by pro.brand
order by sales desc
limit 5



-- (Query 4) Stores that sold the most
-- Columns: store, sales (#)
select 
	sto.store_name as store,
	count(fun.paid_date) as sales
from sales.funnel as fun
	left join sales.stores as sto
		on sto.store_id = fun.store_id
where paid_date between '2021-08-01' and '2021-08-31'	
group by sto.store_name
order by sales desc 
limit 5



-- (Query 5) Days of the week with the highest number of website visits
-- Columns: day_week, day of the week, visits (#)
select
	extract('dow' from visit_page_date) as day_week,
	case 
		when extract('dow' from visit_page_date)=0 then 'sunday'
		when extract('dow' from visit_page_date)=1 then 'monday'
		when extract('dow' from visit_page_date)=2 then 'tuesday'
		when extract('dow' from visit_page_date)=3 then 'wednesday'
		when extract('dow' from visit_page_date)=4 then 'thursday'
		when extract('dow' from visit_page_date)=5 then 'friday'
		when extract('dow' from visit_page_date)=6 then 'saturday'
		else null end as "day of the week",
	count(*) as "visits (#)"

from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by day_week
order by day_week


