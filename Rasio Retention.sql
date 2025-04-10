

SELECT * FROM TRANSACTION_DATA TD

-- 1
SELECT customerid,
		date(DATE_TRUNC('month', min(orderdate))) as month_first_transaction
from TRANSACTION_DATA TD 
group by 1

-- 2
SELECT customerid,
			date(DATE_TRUNC('month', orderdate)) as month_order
from TRANSACTION_DATA TD 
group by 1,2
ORDER BY 1 DESC 

-- 3
with first_trx as(
	SELECT customerid,
			date(DATE_TRUNC('month', min(orderdate))) as month_first_transaction
	from TRANSACTION_DATA TD 
	group by 1
),
order_data as(
	SELECT DISTINCT customerid,
					date(DATE_TRUNC('month', orderdate)) as month_order
	from TRANSACTION_DATA TD 
	group by 1,2
)
SELECT DISTINCT f.customerid,
				f.month_first_transaction,
				o.month_order
from first_trx f
left join order_data o on f.customerid = o.customerid
GROUP BY 1,2,3
ORDER BY 1,2,3 ASC 

-- 4
with first_trx as(
	SELECT customerid,
			date(DATE_TRUNC('month', min(orderdate))) as month_first_transaction
	from TRANSACTION_DATA TD 
	group by 1
),
order_data as(
	SELECT DISTINCT customerid,
					date(DATE_TRUNC('month', orderdate)) as month_order
	from TRANSACTION_DATA TD 
	group by 1,2
),
tbl_join as(
SELECT DISTINCT f.customerid,
				f.month_first_transaction,
				o.month_order
from first_trx f
left join order_data o on f.customerid = o.customerid
GROUP BY 1,2,3
ORDER BY 1,2,3 ASC 
)
SELECT month_first_transaction as cohort_month,
		COUNT(DISTINCT customerid) as initial_customer
from tbl_join
group by 1
ORDER BY 2 DESC 

-- 6
with first_trx as(
	SELECT customerid,
			date(DATE_TRUNC('month', min(orderdate))) as month_first_transaction
	from TRANSACTION_DATA TD 
	group by 1
),
order_data as(
	SELECT DISTINCT customerid,
					date(DATE_TRUNC('month', orderdate)) as month_order
	from TRANSACTION_DATA TD 
	group by 1,2
),
tbl_join as(
	SELECT DISTINCT f.customerid,
					f.month_first_transaction,
					o.month_order
	from first_trx f
	left join order_data o on f.customerid = o.customerid
	GROUP BY 1,2,3
	ORDER BY 1,2,3 ASC 
),
cohort_size as(
	SELECT month_first_transaction as cohort_month,
			COUNT(DISTINCT customerid) as initial_customer
	from tbl_join
	group by 1
	ORDER BY 2 DESC 
)
SELECT cs.cohort_month,
		t.month_order,
		cs.initial_customer,
		COUNT(distinct t.customerid) as total_customer_retain
from cohort_size cs
left join tbl_join t on t.month_first_transaction = cs.cohort_month
GROUP BY 1,2,3

-- 7
with first_trx as(
	SELECT customerid,
			date(DATE_TRUNC('month', min(orderdate))) as month_first_transaction
	from TRANSACTION_DATA TD 
	group by 1
),
order_data as(
	SELECT DISTINCT customerid,
					date(DATE_TRUNC('month', orderdate)) as month_order
	from TRANSACTION_DATA TD 
	group by 1,2
),
tbl_join as(
	SELECT DISTINCT f.customerid,
					f.month_first_transaction,
					o.month_order
	from first_trx f
	left join order_data o on f.customerid = o.customerid
	GROUP BY 1,2,3
	ORDER BY 1,2,3 ASC 
),
cohort_size as(
	SELECT month_first_transaction as cohort_month,
			COUNT(DISTINCT customerid) as initial_customer
	from tbl_join
	group by 1
	ORDER BY 2 DESC 
),
customer_retained as (
	SELECT cs.cohort_month,
			t.month_order,
			cs.initial_customer,
			COUNT(distinct t.customerid) as total_customer_retain
	from cohort_size cs
	left join tbl_join t on t.month_first_transaction = cs.cohort_month
	GROUP BY 1,2,3
)
SELECT *, (total_customer_retain::decimal / initial_customer::decimal) * 100 as perc_retained
from customer_retained
















