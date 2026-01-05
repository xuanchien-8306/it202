INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(108, 2, '2025-01-10', 'completed', 4000000),
(109, 2, '2025-01-11', 'completed', 3500000);

SELECT
    c.customer_id,                              
    c.full_name,                                
    COUNT(o.order_id) AS total_orders,          -- Tổng số đơn hàng
    SUM(o.total_amount) AS total_spent,         -- Tổng số tiền đã chi
    AVG(o.total_amount) AS avg_order_value      -- Giá trị đơn hàng trung bình
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id                -- Kết nối khách hàng với đơn hàng
WHERE o.status = 'completed'                    -- Chỉ tính đơn hàng đã hoàn thành
GROUP BY c.customer_id, c.full_name             -- Nhóm theo từng khách hàng
HAVING 
    COUNT(o.order_id) >= 3                      -- Có từ 3 đơn hàng trở lên
    AND SUM(o.total_amount) > 10000000          -- Tổng tiền > 10.000.000
ORDER BY total_spent DESC;                      -- Sắp xếp theo tổng tiền giảm dần
