create database pizzahuts;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

-- Retrieve the total number of order placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue genrated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
    -- Identify the highest priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
quantity,
COUNT(order_details_id) AS total_orders
FROM orders_details
GROUP BY quantity;

select pizzas.size, count(orders_details.order_details_id) as order_count
from pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size order by order_count desc;

-- list the top 5 most ordered pizza types
-- along with their quantities
select pizza_types.name,
sum(orders_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
pizza_types.category,
SUM(orders_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count
from orders group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types
group by category


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity))
FROM (
    SELECT 
        orders.order_date,
        SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details
        ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
pt.name,
SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p 
ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details od
ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
pizza_types.name,
ROUND(
SUM(orders_details.quantity * pizzas.price) * 100 /
(
    SELECT SUM(orders_details.quantity * pizzas.price)
    FROM orders_details
    JOIN pizzas
    ON orders_details.pizza_id = pizzas.pizza_id
),2) AS revenue_percentage
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue_percentage DESC;

-- Analyze the cumulative revenue generated over time.

SELECT orders.order_date,
SUM(orders_details.quantity * pizzas.price) AS daily_revenue,
SUM(SUM(orders_details.quantity * pizzas.price)) 
OVER (ORDER BY orders.order_date) AS cumulative_revenue
FROM orders
JOIN orders_details ON orders.order_id = orders_details.order_id
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date
ORDER BY orders.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,name,revenue
FROM
(
SELECT pizza_types.category,
pizza_types.name,
SUM(orders_details.quantity * pizzas.price) AS revenue,
RANK() OVER(PARTITION BY pizza_types.category 
ORDER BY SUM(orders_details.quantity * pizzas.price) DESC) AS ranking
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category,pizza_types.name
) AS ranked_pizzas
WHERE ranking <= 3;



