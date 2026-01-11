CREATE DATABASE online_shop;
USE online_shop;

CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(255) NOT NULL UNIQUE,
  price DECIMAL(10,2) NOT NULL,
  category_id INT NOT NULL,
  CONSTRAINT chk_products_price CHECK (price > 0),
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending','Completed','Cancel') DEFAULT 'Pending',
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT chk_order_items_qty CHECK (quantity > 0),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_name, email, phone) VALUES
('Nguyễn Văn An', 'an.nguyen@gmail.com', '0901234567'),
('Trần Thị Bình', 'binh.tran@gmail.com', '0912345678'),
('Lê Văn Cường', 'cuong.le@gmail.com', '0923456789'),
('Phạm Thị Dung', 'dung.pham@gmail.com', '0934567890'),
('Hoàng Minh Đức', 'duc.hoang@gmail.com', '0945678901');

INSERT INTO categories (category_name) VALUES
('Điện thoại'),
('Laptop'),
('Phụ kiện'),
('Tablet'),
('Thiết bị mạng');

INSERT INTO products (product_name, price, category_id) VALUES
('iPhone 15', 25990000.00, 1),
('Samsung S24', 21990000.00, 1),
('MacBook Air M2', 28990000.00, 2),
('Dell Inspiron 14', 17990000.00, 2),
('Tai nghe Bluetooth', 990000.00, 3),
('Sạc nhanh 65W', 650000.00, 3),
('iPad Gen 10', 12990000.00, 4),
('Router WiFi 6', 1499000.00, 5);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2026-01-01 10:10:00', 'Completed'),
(1, '2026-01-03 09:15:00', 'Pending'),
(2, '2026-01-02 14:30:00', 'Completed'),
(3, '2026-01-04 20:00:00', 'Cancel'),
(4, '2026-01-05 08:05:00', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 5, 2),
(2, 6, 1),
(2, 8, 1),
(3, 3, 1),
(3, 6, 2),
(4, 2, 1),
(5, 7, 1),
(5, 5, 1);

-- =========================================================
-- PHẦN A – TRUY VẤN DỮ LIỆU CƠ BẢN
-- =========================================================

-- A1) Lấy danh sách tất cả danh mục sản phẩm trong hệ thống
SELECT category_id, category_name
FROM categories;

-- A2) Lấy danh sách đơn hàng có trạng thái là COMPLETED
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'Completed';

-- A3) Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
SELECT product_id, product_name, price, category_id
FROM products
ORDER BY price DESC;

-- A4) Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
SELECT product_id, product_name, price
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 2;

-- =========================================================
-- PHẦN B – TRUY VẤN NÂNG CAO
-- =========================================================

-- B1) Lấy danh sách sản phẩm kèm tên danh mục
SELECT
  p.product_id,
  p.product_name,
  p.price,
  c.category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id;

-- B2) Lấy danh sách đơn hàng gồm: order_id, order_date, customer_name, status
SELECT
  o.order_id,
  o.order_date,
  c.customer_name,
  o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

-- B3) Tính tổng số lượng sản phẩm trong từng đơn hàng
SELECT
  oi.order_id,
  SUM(oi.quantity) AS total_quantity
FROM order_items oi
GROUP BY oi.order_id;

-- B4) Thống kê số đơn hàng của mỗi khách hàng
SELECT
  o.customer_id,
  COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY o.customer_id;

-- B5) Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
SELECT
  c.customer_id,
  c.customer_name,
  COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2;

-- B6) Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
SELECT
  c.category_id,
  c.category_name,
  AVG(p.price) AS avg_price,
  MIN(p.price) AS min_price,
  MAX(p.price) AS max_price
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name;

-- =========================================================
-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)
-- =========================================================

-- C1) Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- C2) Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
SELECT customer_id, customer_name, email, phone
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- C3) Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất
SELECT oi.order_id, SUM(oi.quantity) AS total_quantity
FROM order_items oi
GROUP BY oi.order_id
HAVING SUM(oi.quantity) = (
  SELECT MAX(t.total_quantity)
  FROM (
    SELECT SUM(quantity) AS total_quantity
    FROM order_items
    GROUP BY order_id
  ) t
);

-- C4) Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE p.category_id = (
  SELECT category_id
  FROM products
  GROUP BY category_id
  ORDER BY AVG(price) DESC
  LIMIT 1
);

-- C5) Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT
  t.customer_id,
  t.customer_name,
  SUM(t.quantity) AS total_bought_quantity
FROM (
  SELECT
    c.customer_id,
    c.customer_name,
    oi.quantity
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
) t
GROUP BY t.customer_id, t.customer_name;

-- C6) Lấy sản phẩm có giá cao nhất, subquery chỉ trả về 1 giá trị (không lỗi more than 1 row)
SELECT product_id, product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);
