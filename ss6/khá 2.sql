ALTER TABLE ss_06.orders
ADD total_amount DECIMAL(10,2);

UPDATE orders SET total_amount = 1500000 WHERE order_id = 101;
UPDATE orders SET total_amount = 2300000 WHERE order_id = 102;
UPDATE orders SET total_amount = 1800000 WHERE order_id = 103;
UPDATE orders SET total_amount = 900000  WHERE order_id = 104;
UPDATE orders SET total_amount = 3200000 WHERE order_id = 105;

SELECT
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

SELECT
    c.customer_id,
    c.full_name,
    MAX(o.total_amount) AS max_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

SELECT
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;
