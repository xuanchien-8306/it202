create database ss_05;
use ss_05;
create table products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active'
);

INSERT INTO ss_05.products (product_name, price, stock, status) VALUES
('Laptop Dell Inspiron', 15000000, 10, 'active'),
('iPhone 14', 22000000, 5, 'active'),
('Chuột không dây Logitech', 450000, 50, 'active'),
('Bàn phím cơ Gaming', 1200000, 30, 'active'),
('Tai nghe Bluetooth', 900000, 0, 'inactive'),
('Màn hình LG 24 inch', 3500000, 15, 'active');

SELECT *
FROM products;

SELECT *
FROM products
WHERE status = 'active';

SELECT *
FROM products
WHERE price > 1000000;

SELECT *
FROM products
WHERE status = 'active'
ORDER BY price desc;
