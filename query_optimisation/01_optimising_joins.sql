-- Challenge: Demonstrate query optimisation patterns
-- Concepts: Filter early, avoid functions on indexed columns,
--           use CTEs to pre-aggregate before joining

-- Dataset: stg_orders, stg_customers

-- Question: Get total revenue per customer for completed orders in 2021.
-- Show the unoptimised approach first, then the optimised version.

-- =============================================
-- UNOPTIMISED: filters and functions applied late
-- =============================================

-- with all_data as (
--     select
--         c.customer_id,
--         c.full_name,
--         o.order_amount,
--         o.order_status,
--         o.order_date
--     from stg_customers c
--     left join stg_orders o
--         on c.customer_id = o.customer_id
-- )
-- select
--     customer_id,
--     full_name,
--     sum(order_amount) as total_revenue
-- from all_data
-- where order_status = 'completed'
--   and date_part('year', order_date) = 2021
-- group by customer_id, full_name

-- =============================================
-- OPTIMISED: filter and pre-aggregate before joining
-- reduces rows joined from full table to summary
-- =============================================

with completed_orders_2021 as (
    -- Filter and pre-aggregate BEFORE the join
    -- Only pass the rows we need into the join
    select
        customer_id,
        sum(order_amount)       as total_revenue,
        count(order_id)         as total_orders
    from stg_orders
    where order_status = 'completed'
      and order_date >= '2021-01-01'
      and order_date <  '2022-01-01'  -- avoids function on column, allows index use
    group by customer_id
),

customer_summary as (
    select
        c.customer_id,
        c.full_name,
        coalesce(o.total_revenue, 0)    as total_revenue,
        coalesce(o.total_orders, 0)     as total_orders
    from stg_customers c
    left join completed_orders_2021 o
        on c.customer_id = o.customer_id
)

select
    customer_id,
    full_name,
    total_revenue,
    total_orders
from customer_summary
where total_orders > 0
order by total_revenue desc