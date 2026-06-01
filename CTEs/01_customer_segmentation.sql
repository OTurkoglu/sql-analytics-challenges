-- Challenge: Segment customers based on purchase behaviour using CTEs
-- Concepts: Multiple CTEs, CASE WHEN segmentation, aggregation

-- Dataset: stg_orders, stg_customers

-- Question: Classify each customer into a segment based on their total revenue:
-- High Value: total_revenue >= 100
-- Mid Value:  total_revenue >= 50 and < 100
-- Low Value:  total_revenue < 50
-- No Orders:  customer has never ordered

with customers as (
    select
        customer_id,
        full_name
    from stg_customers
),

orders as (
    select
        customer_id,
        order_amount
    from stg_orders
    where order_status = 'completed'
),

customer_revenue as (
    select
        customer_id,
        sum(order_amount)   as total_revenue,
        count(customer_id)  as total_orders
    from orders
    group by customer_id
),

segmented as (
    select
        c.customer_id,
        c.full_name,
        coalesce(r.total_revenue, 0)    as total_revenue,
        coalesce(r.total_orders, 0)     as total_orders,
        case
            when r.customer_id is null          then 'No Orders'
            when r.total_revenue >= 100         then 'High Value'
            when r.total_revenue >= 50          then 'Mid Value'
            else                                     'Low Value'
        end                             as customer_segment
    from customers c
    left join customer_revenue r
        on c.customer_id = r.customer_id
)

select
    customer_id,
    full_name,
    total_revenue,
    total_orders,
    customer_segment
from segmented
order by total_revenue desc