-- 1. Tạo database và sử dụng
CREATE DATABASE ss_06;
USE ss_06;

-- 2. Tạo bảng customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    city VARCHAR(255)
);

-- 3. Tạo bảng orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status ENUM('pending', 'completed', 'cancelled'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Thêm dữ liệu vào bảng customers
INSERT INTO customers (customer_id, full_name, city) VALUES
(1, 'Nguyễn Văn A', 'Hà Nội'),
(2, 'Trần Thị B', 'Hồ Chí Minh'),
(3, 'Lê Văn C', 'Đà Nẵng'),
(4, 'Phạm Thị D', 'Hải Phòng'),
(5, 'Hoàng Văn E', 'Cần Thơ');

-- 5. Thêm dữ liệu vào bảng orders
INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2025-01-01', 'completed'),
(102, 1, '2025-01-05', 'pending'),
(103, 2, '2025-01-03', 'completed'),
(104, 3, '2025-01-06', 'cancelled'),
(105, 2, '2025-01-07', 'completed');

-- 6. Danh sách đơn hàng kèm tên khách hàng
SELECT 
    o.order_id,
    c.full_name,
    o.order_date,
    o.status
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

-- 7. Mỗi khách hàng đã đặt bao nhiêu đơn hàng
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- 8. Chỉ hiển thị khách hàng có ít nhất 1 đơn hàng
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) >= 1;
