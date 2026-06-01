-- Challenge: Cohort retention analysis
-- Concepts: Cohort assignment, self-join, conditional aggregation,
--           date truncation, percentage calculation
-- This pattern is one of the most common analytical questions at FAANG companies

-- Dataset: stg_orders, stg_customers

-- Question: For each monthly customer cohort (based on first order date),
-- show how many customers returned to purchase in subsequent months
-- and what the retention rate is month over month

with customer_first_order as (
    -- Assign each customer to their acquisition cohort
    -- based on the month of their first completed order
    select
        customer_id,
        date_trunc('month', min(order_date))    as cohort_month
    from stg_orders
    where order_status = 'completed'
    group by customer_id
),

customer_orders as (
    -- Get all completed orders with their cohort month
    select
        o.customer_id,
        date_trunc('month', o.order_date)       as order_month,
        c.cohort_month
    from stg_orders o
    inner join customer_first_order c
        on o.customer_id = c.customer_id
    where o.order_status = 'completed'
),

cohort_size as (
    -- Count how many customers are in each cohort
    select
        cohort_month,
        count(distinct customer_id)             as cohort_customers
    from customer_first_order
    group by cohort_month
),

retention_data as (
    -- Calculate how many months after acquisition each order occurred
    select
        cohort_month,
        customer_id,
        datediff('month', cohort_month, order_month)    as months_since_acquisition
    from customer_orders
),

retention_counts as (
    -- Count distinct returning customers per cohort per month offset
    select
        cohort_month,
        months_since_acquisition,
        count(distinct customer_id)             as retained_customers
    from retention_data
    group by
        cohort_month,
        months_since_acquisition
)

select
    r.cohort_month,
    s.cohort_customers,
    r.months_since_acquisition,
    r.retained_customers,
    round(
        r.retained_customers::decimal
        / nullif(s.cohort_customers, 0) * 100
    , 2)                                        as retention_rate_pct
from retention_counts r
inner join cohort_size s
    on r.cohort_month = s.cohort_month
order by
    r.cohort_month,
    r.months_since_acquisition