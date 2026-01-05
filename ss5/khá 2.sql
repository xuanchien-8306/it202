-- Tạo bảng customers (có thêm cột phone)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(255),
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active'
);

-- Thêm dữ liệu mẫu vào bảng customers
INSERT INTO customers (full_name, email, phone, city, status) VALUES
('Nguyễn Văn An', 'an@gmail.com', '0901234567', 'TP.HCM', 'active'),
('Trần Thị Bình', 'binh@gmail.com', '0912345678', 'Hà Nội', 'active'),
('Lê Hoàng Cường', 'cuong@gmail.com', '0923456789', 'Đà Nẵng', 'inactive'),
('Phạm Minh Đức', 'duc@gmail.com', '0934567890', 'Hà Nội', 'active'),
('Võ Thị Hoa', 'hoa@gmail.com', '0945678901', 'TP.HCM', 'inactive');

-- 1. Lấy danh sách tất cả khách hàng
SELECT *
FROM customers;

-- 2. Lấy khách hàng ở TP.HCM
SELECT *
FROM customers
WHERE city = 'TP.HCM';

-- 3. Lấy khách hàng đang hoạt động và ở Hà Nội
SELECT *
FROM customers
WHERE status = 'active'
  AND city = 'Hà Nội';

-- 4. Sắp xếp danh sách khách hàng theo tên (A → Z)
SELECT *
FROM customers
ORDER BY full_name ASC;
