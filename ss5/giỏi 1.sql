-- Tạo bảng orders
	CREATE TABLE orders (
		order_id INT PRIMARY KEY AUTO_INCREMENT,
		customer_id INT NOT NULL,
		total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
		order_date DATE NOT NULL,
		status ENUM('pending', 'completed', 'cancelled') NOT NULL
	);

-- Thêm dữ liệu mẫu
INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES
(1, 3200000, '2024-01-05', 'completed'),
(2, 7800000, '2024-01-10', 'completed'),
(3, 1500000, '2024-01-15', 'pending'),
(1, 9200000, '2024-02-01', 'completed'),
(4, 4300000, '2024-02-05', 'cancelled'),
(2, 6100000, '2024-02-10', 'completed'),
(5, 2800000, '2024-02-12', 'pending');

-- 1. Lấy danh sách đơn hàng đã hoàn thành
SELECT *
FROM orders
WHERE status = 'completed';

-- 2. Lấy các đơn hàng có tổng tiền > 5.000.000
SELECT *
FROM orders
WHERE total_amount > 5000000;

-- 3. Hiển thị 5 đơn hàng mới nhất
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 5;

-- 4. Hiển thị các đơn hàng đã hoàn thành, sắp xếp theo tổng tiền giảm dần
SELECT *
FROM orders
WHERE status = 'completed'
ORDER BY total_amount DESC;
