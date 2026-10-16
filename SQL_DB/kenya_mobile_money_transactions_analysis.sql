-- Analysis done by Juliet Kiplimo - Data Scientist & Engineer.
------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- # KENYA MOBILE MONEY TRANSACTIONS ANALYSIS: 


		---- 10 Advanced Business Insights:

-- Dataset: (kenya_mobile_money_transactions.csv)

		--6,000 transactions across 800 customers, spanning 1 Jan 2024 → 31 Dec 2024.

--Core skills : SQL, Python [window functions, time-series grouping, and segmentation.]

--Note: analysis is only on >>  status = 'Completed' transactions unless stated otherwise


create schema mobile_money_data;

set search_path to mobile_money_data;

select current_database();


CREATE TABLE transactions(
    transaction_id         VARCHAR(20) PRIMARY KEY,
    transaction_timestamp  TIMESTAMP,
    customer_id            VARCHAR(20),
    customer_name          VARCHAR(100),
    gender                 VARCHAR(10),
    age                    INT,
    county                 VARCHAR(50),
    phone_number           VARCHAR(20),
    channel                VARCHAR(30),
    transaction_type       VARCHAR(30),
    merchant_category      VARCHAR(50),
    device_type            VARCHAR(20),
    amount_kes             NUMERIC(12,2),
    transaction_fee_kes    NUMERIC(12,2),
    balance_after_kes      NUMERIC(12,2),
    status                 VARCHAR(20)
);

copy transactions 
from 'J:\Porfolio_Projects\Kenya_Mobile_Money_Project\Data\kenya_mobile_money_transactions.csv'
delimiter ','
csv header;

select *
from transactions as t
limit 30;

SELECT COUNT(*) AS total_rows
FROM transactions;

-- ## 1. Monthly revenue trend and month-over-month growth:

-- Compute total fee revenue (transaction_fee_kes) per calendar month


select date_trunc('month',t.transaction_timestamp ) :: date as revenue_month,
sum( t.transaction_fee_kes ) as total_revenue,
count (*) as num_transactions,
status
from mobile_money_data.transactions t 
where t.status = 'Completed'
group by revenue_month, t.status 
order by revenue_month ;

-- then add a column showing the month-over-month % change. Which month grew fastest? 

--- a CTE to calculate revenue per month
with monthly_revenue as (
    select
        date_trunc('month', t.transaction_timestamp)::date as revenue_month,
        sum(t.transaction_fee_kes) as total_revenue
    from mobile_money_data.transactions t
    where t.status = 'Completed'
    group by 1
),
--- a CTE to compare revenue of current month vs previous month
growth as (
    select
        revenue_month,
        total_revenue,
        round(
            (total_revenue - lag(total_revenue) over (order by revenue_month))
            / nullif(lag(total_revenue) over (order by revenue_month), 0) * 100
        , 2) as pct_change
    from monthly_revenue
)
select *
from growth
order by pct_change desc nulls last
limit 1;


-- ## 2. Peak transaction hours (heatmap-ready)


--  Build a day-of-week × hour-of-day matrix of transaction counts. Identify the single busiest hour block. 

---  (Skills: extracting hour & weekday from a timestamp, pivoting.)


select 
	to_char(t.transaction_timestamp, 'Day') as weekday,
	extract(isodow from t.transaction_timestamp) as day_num,
	extract(hour from t.transaction_timestamp) as hour_of_day,
	count (*) as num_transactions
	from mobile_money_data.transactions t
	group by day_num, hour_of_day,weekday
	order by num_transactions desc
	limit 1;

--- ## 3. Top customers by value, ranked within their county
-- For each county, rank customers by total amount transacted and return the top 3 per county. 

-- (Skills: RANK() / ROW_NUMBER() partitioned by county, or groupby().rank()

select * 
from mobile_money_data.transactions t 
limit 5;

with customer_spend as (
	select 
	t.customer_id,
	t.customer_name,
	t.county,
	sum(t.amount_kes) as total_spend
	from mobile_money_data.transactions t 
	group by 
	t.customer_id,
	t.customer_name,
	t.county
),
ranked_customers as (
	select cs.*,
	row_number() over(partition by cs.county order by cs.total_spend desc, cs.customer_id ) as customer_rank
	from customer_spend as cs 
	)
select *
from ranked_customers as rc
where rc.customer_rank <=3
order by rc.customer_rank, rc.county;

-- 4. 7-day rolling transaction volume
-- Create a daily transaction-count series, then compute the 7-day rolling average of daily volume. 
--On how many days did volume exceed 1.5× its rolling average? 
-- (Skills: resampling to daily, rolling windows.)

select * 
from transactions t
limit  5;

-- CTE + WINDOW FUNCTION

with t_bands as (
	select 
		MIN(t.transaction_timestamp):: date as start_date,
		MAX(t.transaction_timestamp):: date as end_date
		from transactions t
		),
 t_series as (
 	select d::date as transaction_day
 	from t_bands tb,
 		generate_series(tb.start_date, tb.end_date, interval '1 day') as d
 	),
  daily_volumes as (
		select 
		ts.transaction_day,
		count(t.transaction_id) as daily_volume
		from t_series ts
		left join transactions t on 
		t.transaction_timestamp >= ts.transaction_day 
		and t.transaction_timestamp < ts.transaction_day  +1
		group by ts.transaction_day 
		),
	rolling_avg as (
		select
		transaction_day,
		daily_volume,
		avg(daily_volume) over (order by transaction_day ROWS BETWEEN 7 PRECEDING and 1 PRECEDING ) as rolling_avg_volume
		from daily_volumes 
		)
		select 
		transaction_day ,
		daily_volume,
		round(rolling_avg_volume ,2) as rolling_avg_volume
		from rolling_avg 
		where daily_volume > 1.5 * rolling_avg_volume
		order by transaction_day;
-- 5. Customer RFM segmentation
--For every customer compute Recency (days since last transaction, relative to the dataset's max date), Frequency (number of transactions), and Monetary (total amount). Score each into quintiles (1–5) and label the top segment as "Champions". (Skills: multi-metric aggregation, quantile bucketing, NTILE().)

	

















	
