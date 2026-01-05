-- Trang 1: hiển thị 5 đơn hàng mới nhất (chưa bị hủy)
SELECT *
FROM ss_05.orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 0;

-- Trang 2: hiển thị 5 đơn hàng tiếp theo
SELECT *
FROM ss_05.orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 5;

-- Trang 3: hiển thị 5 đơn hàng tiếp theo
SELECT *
FROM ss_05.orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 10;
