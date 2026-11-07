-- Q1: Show product name, model year, and list price for all products
-- from model year 2017 or 2018 whose name contains the word 'Electra'.
-- Sort by product name.
                
SELECT product_name, model_year, list_price
FROM production.products
WHERE model_year IN (2017, 2018)
  AND product_name LIKE '%Electra%'
ORDER BY product_name;



-- Q2: Find customers who have a phone number on file AND an email
-- ending in '@yahoo.com'. Show full name, email, and city.
-- Sort by city, then by last name.


SELECT
    first_name + ' ' + last_name AS full_name,
    email,
    city
FROM sales.customers
WHERE phone IS NOT NULL
  AND email LIKE '%@yahoo.com'
ORDER BY city, last_name;


-- Q3: For orders placed in 2017 that have already shipped, show order ID,
-- order date, shipped date, and a computed column "Days To Ship"
-- (days between order date and shipped date).
-- Show only the 10 slowest shipments.

SELECT TOP 10
    order_id,
    order_date,
    shipped_date,
    DATEDIFF(DAY, order_date, shipped_date) AS [Days To Ship]
FROM sales.orders
WHERE YEAR(order_date) = 2017
  AND order_status = 4
  AND shipped_date IS NOT NULL
ORDER BY [Days To Ship] DESC;


-- Q4: List all products that are OUT OF STOCK (quantity = 0) at the
-- store "Baldwin Bikes". Show product name, brand name, and quantity.
-- Sort by product name.


SELECT
    p.product_name,
    b.brand_name,
    s.quantity
FROM production.products p
JOIN production.brands b
    ON p.brand_id = b.brand_id
JOIN production.stocks s
    ON p.product_id = s.product_id
JOIN sales.stores st
    ON s.store_id = st.store_id
WHERE s.quantity = 0
  AND st.store_name = 'Baldwin Bikes'
ORDER BY p.product_name;


-- Q5: For orders placed in 2018, show order ID, customer full name,
-- product name, and the discounted line total
-- (quantity × list_price × (1 – discount)) for every order item with
-- a discount of 20% or more. Sort by line total descending.

SELECT
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    p.product_name,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_total
FROM sales.orders o
JOIN sales.customers c
    ON o.customer_id = c.customer_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN production.products p
    ON oi.product_id = p.product_id
WHERE YEAR(o.order_date) = 2018
  AND oi.discount >= 0.20
ORDER BY line_total DESC;


-- Q6: Find all staff members who have NEVER handled an order.
-- Show staff full name and the name of their store.


SELECT
    s.first_name + ' ' + s.last_name AS staff_name,
    st.store_name
FROM sales.staffs s
JOIN sales.stores st
    ON s.store_id = st.store_id
LEFT JOIN sales.orders o
    ON s.staff_id = o.staff_id
WHERE o.order_id IS NULL;

-- Q7: Find all customers who have bought at least one product from
-- the brand "Trek". Show each customer's full name and city once only.
-- Sort by full name.

SELECT DISTINCT
    c.first_name + ' ' + c.last_name AS full_name,
    c.city
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN production.products p
    ON oi.product_id = p.product_id
JOIN production.brands b
    ON p.brand_id = b.brand_id
WHERE b.brand_name = 'Trek'
ORDER BY full_name;



-- Q8: Using CROSS JOIN, generate every possible combination of
-- store name and category name. Sort by store name, then category name.


SELECT
    s.store_name,
    c.category_name
FROM sales.stores s
CROSS JOIN production.categories c
ORDER BY s.store_name, c.category_name;

-- Q9: Show the total number of units sold for each product category.
-- Display category name and total units. Sort by total units descending.

SELECT
    c.category_name,
    SUM(oi.quantity) AS total_units
FROM production.categories c
JOIN production.products p
    ON c.category_id = p.category_id
JOIN sales.order_items oi
    ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY total_units DESC;

-- Q10: Show the number of orders placed per store per year.
-- Display store name, order year, and order count.
-- Sort by store name, then year.

SELECT
    s.store_name,
    YEAR(o.order_date) AS order_year,
    COUNT(o.order_id) AS order_count
FROM sales.stores s
JOIN sales.orders o
    ON s.store_id = o.store_id
GROUP BY
    s.store_name,
    YEAR(o.order_date)
ORDER BY s.store_name, order_year;

-- Q11: For each staff member, count the orders they handled.
-- Show staff full name and order count, but only for staff who handled
-- MORE THAN 100 orders. Sort by order count descending.


SELECT
    s.first_name + ' ' + s.last_name AS staff_name,
    COUNT(o.order_id) AS order_count
FROM sales.staffs s
JOIN sales.orders o
    ON s.staff_id = o.staff_id
GROUP BY
    s.staff_id,
    s.first_name,
    s.last_name
HAVING COUNT(o.order_id) > 100
ORDER BY order_count DESC;


-- Q12: Find customers whose total spending
-- (SUM of quantity × list_price × (1 – discount)) is above $10,000.
-- Show customer full name and total spent (rounded to 2 decimals).
-- Sort by total spent descending.

SELECT
    c.first_name + ' ' + c.last_name AS customer_name,
    CAST(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount))
        AS DECIMAL(12, 2)
    ) AS total_spent
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(
    oi.quantity * oi.list_price * (1 - oi.discount)
) > 10000
ORDER BY total_spent DESC;


-- Q13: For each brand, show the average and maximum list price.
-- Keep only brands whose average price is above $1,000.
-- Show brand name, average price (2 decimals), and max price.
-- Sort by average price descending.

SELECT
    b.brand_name,
    CAST(AVG(p.list_price) AS DECIMAL(10, 2)) AS average_price,
    MAX(p.list_price) AS max_price
FROM production.brands b
JOIN production.products p
    ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING AVG(p.list_price) > 1000
ORDER BY average_price DESC;

-- Q14: Show the total quantity in stock for each store and category
-- combination. Display store name, category name, and total quantity.
-- Sort by store name, then by total quantity descending.

SELECT
    s.store_name,
    c.category_name,
    SUM(st.quantity) AS total_quantity
FROM sales.stores s
JOIN production.stocks st
    ON s.store_id = st.store_id
JOIN production.products p
    ON st.product_id = p.product_id
JOIN production.categories c
    ON p.category_id = c.category_id
GROUP BY
    s.store_name,
    c.category_name
ORDER BY s.store_name, total_quantity DESC;


-- Q15 (BONUS): For the year 2017, show for each month:
-- month number, number of orders, and total revenue
-- (quantity × list_price × (1 – discount), rounded to 2 decimals).
-- Sort by month number.

SELECT
    MONTH(o.order_date) AS month_number,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    CAST(
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS DECIMAL(12, 2)
    ) AS total_revenue
FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2017
GROUP BY MONTH(o.order_date)
ORDER BY month_number;
