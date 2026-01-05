select * from customers;
select * from orders;

-- Inner join
select o.* , c.status
from orders c
inner join customers o on c.customer_id = o.customer_id;

-- LEFT JOIN ,RIGHT JOIN
select *
from orders c left join customers o on c.customer_id = o.customer_id;

-- full outer join
select *
from orders c left join customers o on c.customer_id = o.customer_id
UNION -- phép hợp
select *
from orders c right join customers o on c.customer_id = o.customer_id;

-- bài tập tự luyện:
#1.1 lấy tất cả thông tin gồm : tên khách hàng, mã đơn hàng, số lượng ,đơn giá 
# ten khách hàng ,mã đơn hàng ,tên sản phảm , số lượng ,đơn gía
# thành tiền (số lượng * đơn giá)
#1.1 Lấy: tên khách hàng, mã đơn hàng, số lượng, đơn giá
-- INNER JOIN (chỉ lấy đơn có khách hàng)
#1.1 Lấy: tên khách hàng, mã đơn hàng, số lượng, đơn giá
SELECT
    c.customer_name,
    o.order_id,
    oi.quantity,
    oi.unit_price
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id;

#1.2 Lấy: tên khách hàng, mã đơn hàng, tên sản phẩm, số lượng, đơn giá
SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id;

#1.3 Thêm cột thành tiền = số lượng * đơn giá
SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS thanh_tien
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id;
