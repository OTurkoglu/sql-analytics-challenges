-- Challenge: Detect common data quality issues in transactional data
-- Concepts: Duplicate detection, orphan records, null analysis,
--           late arriving data, anomaly detection
--
-- Note: In a production environment these checks would be automated
-- using a data observability platform such as Monte Carlo or re_data.
-- This query demonstrates the underlying logic that such tools implement —
-- useful for understanding what is being monitored and for environments
-- where a dedicated observability tool is not yet in place.
--
-- Dataset: stg_orders, stg_customers

-- =============================================
-- CHECK 1: Duplicate order detection
-- Orders appearing more than once on the same date
-- for the same customer — signals upstream pipeline issue
-- =============================================

with duplicate_orders as (
    select
        customer_id,
        order_date,
        order_amount,
        count(order_id)                 as order_count
    from stg_orders
    group by
        customer_id,
        order_date,
        order_amount
    having count(order_id) > 1
),

-- =============================================
-- CHECK 2: Orphan orders
-- Orders with a customer_id that does not exist
-- in the customers table — referential integrity failure
-- =============================================

orphan_orders as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_amount
    from stg_orders o
    left join stg_customers c
        on o.customer_id = c.customer_id
    where c.customer_id is null
),

-- =============================================
-- CHECK 3: Null analysis
-- Critical fields that should never be null
-- =============================================

null_checks as (
    select
        count(order_id)                                     as total_orders,
        count(case when customer_id is null
              then order_id end)                            as null_customer_id,
        count(case when order_date is null
              then order_id end)                            as null_order_date,
        count(case when order_amount is null
              then order_id end)                            as null_order_amount,
        count(case when order_status is null
              then order_id end)                            as null_order_status
    from stg_orders
),

-- =============================================
-- CHECK 4: Late arriving data
-- Orders with an order_date more than 7 days
-- before the customer's first known order —
-- signals backfilled or incorrectly dated records
-- =============================================

customer_first_order as (
    select
        customer_id,
        min(order_date)                 as first_order_date
    from stg_orders
    group by customer_id
),

late_arriving as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        f.first_order_date,
        datediff('day', o.order_date, f.first_order_date)  as days_before_first_order
    from stg_orders o
    inner join customer_first_order f
        on o.customer_id = f.customer_id
    where o.order_date < f.first_order_date - 7
),

-- =============================================
-- CHECK 5: Revenue anomalies
-- Orders with amount more than 3x the average
-- order value — potential data entry errors
-- =============================================

revenue_anomalies as (
    select
        order_id,
        customer_id,
        order_date,
        order_amount,
        avg(order_amount) over ()                           as avg_order_amount,
        round(
            order_amount
            / nullif(avg(order_amount) over (), 0)
        , 2)                                                as multiple_of_average
    from stg_orders
    qualify multiple_of_average > 3
)

-- =============================================
-- SUMMARY: Return all quality issues in one view
-- In production this would feed a data quality dashboard
-- =============================================

select
    'duplicate_orders'          as issue_type,
    count(*)                    as issue_count
from duplicate_orders

union all

select
    'orphan_orders'             as issue_type,
    count(*)                    as issue_count
from orphan_orders

union all

select
    'null_customer_id'          as issue_type,
    null_customer_id            as issue_count
from null_checks

union all

select
    'null_order_date'           as issue_type,
    null_order_date             as issue_count
from null_checks

union all

select
    'null_order_amount'         as issue_type,
    null_order_amount           as issue_count
from null_checks

union all

select
    'late_arriving_records'     as issue_type,
    count(*)                    as issue_count
from late_arriving

union all

select
    'revenue_anomalies'         as issue_type,
    count(*)                    as issue_count
from revenue_anomalies