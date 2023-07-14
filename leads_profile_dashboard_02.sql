-- Query 01 - Leads Gender
-- Columns: gender, leads (#)
select
	gender, 
	count(*) as "leads (#)"
from sales.customers as cus
left join temp_tables.ibge_genders as ibge
	on lower(cus.first_name) = lower(ibge.first_name)
group by ibge.gender


--Query 02 - Leads professional status
-- Columns: professional status, leads(%)
select
	professional_status,
	(count(*)::float)/(select count(*) from sales.customers) as "leads(%)"
from sales.customers
group by professional_status
order by "leads(%)" desc


-- Query 03 - Leads age range
-- Columns: age range, leads(%)
select 
	case
		when datediff('years', birth_date, current_date) < 20 then '0-20'
		when datediff('years', birth_date, current_date) < 40 then '20-40'
		when datediff('years', birth_date, current_date) < 60 then '40-60'
		when datediff('years', birth_date, current_date) < 80 then '60-80'
		else '80+' end "age_range",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "age_range"
order by "age_range" desc


-- Query 04 - Leads wage range
-- Columns: wage range, leads (%), order
select 
	case
		when income < 5000 then '0-5k'
		when income < 10000 then '5k-10k'
		when income < 15000 then '10k-15k'
		when income < 20000 then '15k-20k'
		else '20k+' end "wage_range",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)",
	case
		when income < 5000 then 1
		when income < 10000 then 2
		when income < 15000 then 3
		when income < 20000 then 4
		else 5 end "order"
from sales.customers
group by "wage_range", "order"
order by "order" 


-- Query 05 - Classification of Visited Vehicles
-- Columns: Vehicle classification, Visited vehicles (#)
-- Business rule: New vehicles have up to 2 years, and used vehicles are over 2 years.

with
	vehicles_classification as (
		select
			fun.visit_page_date, 
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as vehicles_age,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 2 then 'new'
				else 'pre-owned'
				end as "vehicles classification"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id
		)
select
	"vehicles classification",
	count(*) as "visited vehicles (#)"
from vehicles_classification
group by "vehicles classification"


-- (Query 6) Age of Visited Vehicles
-- Columns: Vehicle Age, Visited Vehicles (%), Order

with
	vehicles_age_range as (
		select
			fun.visit_page_date, 
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as vehicles_age,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 2 then 'up to 2 years'
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 4 then 'from 2 to 4 years'
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 6 then 'from 4 to 6 years'
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 8 then 'from 6 to 8 years'
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 10 then 'from 8 to 10 years'
				else 'over 10 years'
				end as "vehicles age", 
			case
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 2 then 1
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 4 then 2
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 6 then 3
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 8 then 4
				when (extract('year' from visit_page_date) - pro.model_year::int) <= 10 then 5
				else 6
				end as "order"
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id
		)
select
	"vehicles age",
	count(*)::float/(select count(*) from sales.funnel) as "visited vehicles (%)",
	"order"
from vehicles_age_range
group by "vehicles age", "order"
order by "order"


-- (Query 7) Most Visited Vehicles by Brand
-- Columns: Brand, Model, Visits (#)

select
	pro.brand,
	pro.model, 
	count(*) as "visits (#)"
	
from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visits (#)"
