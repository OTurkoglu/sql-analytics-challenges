-- Challenge: Calculate month over month revenue growth
-- Concepts: LAG(), date truncation, percentage change calculation

-- Dataset: stg_orders (order_id, customer_id, order_date, order_status, order_amount)

-- Question: For each month, show total revenue, previous month revenue
-- and the month over month growth percentage

with monthly_revenue as (
    select
        date_trunc('month', order_date)     as order_month,
        sum(order_amount)                   as total_revenue
    from stg_orders
    where order_status = 'completed'
    group by date_trunc('month', order_date)
),

with_previous_month as (
    select
        order_month,
        total_revenue,
        lag(total_revenue) over (
            order by order_month
        )                                   as previous_month_revenue
    from monthly_revenue
),

with_growth as (
    select
        order_month,
        total_revenue,
        previous_month_revenue,
        round(
            (total_revenue - previous_month_revenue)
            / nullif(previous_month_revenue, 0) * 100
        , 2)                                as mom_growth_pct
    from with_previous_month
)

select
    order_month,
    total_revenue,
    previous_month_revenue,
    mom_growth_pct
from with_growth
order by order_month