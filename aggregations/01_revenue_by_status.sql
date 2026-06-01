-- Challenge: Summarise order revenue by status with percentages
-- Concepts: GROUP BY, HAVING, percentage of total using subquery

-- Dataset: stg_orders

-- Question: For each order status, show total revenue, order count
-- and what percentage of total revenue each status represents

with order_totals as (
    select
        order_status,
        count(order_id)             as total_orders,
        sum(order_amount)           as total_revenue
    from stg_orders
    group by order_status
),

overall_total as (
    select
        sum(order_amount)           as grand_total_revenue
    from stg_orders
),

with_percentages as (
    select
        ot.order_status,
        ot.total_orders,
        ot.total_revenue,
        round(
            ot.total_revenue
            / nullif(tt.grand_total_revenue, 0) * 100
        , 2)                        as pct_of_total_revenue
    from order_totals ot
    cross join overall_total tt
)

select
    order_status,
    total_orders,
    total_revenue,
    pct_of_total_revenue
from with_percentages
order by total_revenue desc