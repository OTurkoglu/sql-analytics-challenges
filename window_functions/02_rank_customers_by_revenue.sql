-- Challenge: Rank customers by total revenue using different ranking functions
-- Concepts: RANK(), DENSE_RANK(), ROW_NUMBER(), difference between them

-- Dataset: stg_orders (order_id, customer_id, order_date, order_status, order_amount)

-- Question: For completed orders, rank customers by total revenue.
-- Show RANK, DENSE_RANK and ROW_NUMBER side by side to illustrate the difference

with completed_orders as (
    select
        customer_id,
        order_amount
    from stg_orders
    where order_status = 'completed'
),

customer_revenue as (
    select
        customer_id,
        sum(order_amount)   as total_revenue
    from completed_orders
    group by customer_id
),

ranked as (
    select
        customer_id,
        total_revenue,
        rank() over (
            order by total_revenue desc
        )                   as revenue_rank,
        dense_rank() over (
            order by total_revenue desc
        )                   as revenue_dense_rank,
        row_number() over (
            order by total_revenue desc
        )                   as revenue_row_number
    from customer_revenue
)

select
    customer_id,
    total_revenue,
    revenue_rank,
    revenue_dense_rank,
    revenue_row_number
from ranked
order by revenue_rank