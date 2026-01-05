USE ss_06;

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- THÊM DỮ LIỆU MẪU VÀO BẢNG PRODUCTS
INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Laptop', 15000000),
(2, 'Chuột', 500000),
(3, 'Bàn phím', 800000),
(4, 'Tai nghe', 1200000),
(5, 'Màn hình', 4500000);

-- THÊM DỮ LIỆU MẪU VÀO BẢNG ORDER_ITEMS
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(101, 1, 1),
(101, 2, 2),
(103, 3, 3),
(105, 1, 1),
(105, 5, 2);

-- TRUY VẤN 1: HIỂN THỊ MỖI SẢN PHẨM ĐÃ BÁN BAO NHIÊU SẢN PHẨM
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- TRUY VẤN 2: TÍNH DOANH THU CỦA TỪNG SẢN PHẨM
-- Doanh thu = price * quantity
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- TRUY VẤN 3: CHỈ HIỂN THỊ SẢN PHẨM CÓ DOANH THU > 5.000.000
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity * p.price) > 5000000
ORDER BY total_revenue DESC;
