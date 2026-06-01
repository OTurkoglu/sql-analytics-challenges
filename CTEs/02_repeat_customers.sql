-- Challenge: Identify repeat customers and their behaviour
-- Concepts: Multiple CTEs, filtering on aggregates, CASE WHEN

-- Dataset: stg_orders, stg_customers

-- Question: Identify customers who have placed more than one completed order.
-- Show their order count, total revenue, and classify them as
-- New (1 order), Repeat (2-4 orders) or Loyal (5+ orders)

with completed_orders as (
    select
        customer_id,
        order_id,
        order_amount
    from stg_orders
    where order_status = 'completed'
),

customer_metrics as (
    select
        customer_id,
        count(order_id)         as total_orders,
        sum(order_amount)       as total_revenue
    from completed_orders
    group by customer_id
),

classified as (
    select
        cm.customer_id,
        c.full_name,
        cm.total_orders,
        cm.total_revenue,
        case
            when cm.total_orders = 1        then 'New'
            when cm.total_orders between 2
                 and 4                      then 'Repeat'
            else                                 'Loyal'
        end                     as customer_type
    from customer_metrics cm
    inner join stg_customers c
        on cm.customer_id = c.customer_id
)

select
    customer_id,
    full_name,
    total_orders,
    total_revenue,
    customer_type
from classified
order by total_orders desc