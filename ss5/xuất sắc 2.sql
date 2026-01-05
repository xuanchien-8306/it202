-- Trang 1: 10 sản phẩm đầu tiên
SELECT *
FROM products
WHERE status = 'active'
  AND price BETWEEN 1000000 AND 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 0;

-- Trang 2: 10 sản phẩm tiếp theo
SELECT *
FROM products
WHERE status = 'active'
  AND price BETWEEN 1000000 AND 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 10;
