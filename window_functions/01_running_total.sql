-- Challenge: Calculate running total of revenue by order date
-- Concepts: SUM() OVER, ORDER BY in window function, partitioning

-- Dataset: stg_orders (order_id, customer_id, order_date, order_status, order_amount)

-- Question: For each order, show the cumulative revenue up to and including that order date,
-- partitioned by order status

with orders as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
        order_amount
    from stg_orders
    where order_status = 'completed'
),

running_total as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
        order_amount,
        sum(order_amount) over (
            partition by order_status
            order by order_date
            rows between unbounded preceding and current row
        )                       as cumulative_revenue
    from orders
)

select
    order_id,
    customer_id,
    order_date,
    order_status,
    order_amount,
    cumulative_revenue
from running_total