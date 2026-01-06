
insert into orders (id, customer_id, order_date, total_amount) values 
(105, 4, '2023-12-20', 450000),
(106, 5, '2023-12-22', 2500000),
(107, 1, '2023-12-25', 100000);

select id, customer_id, order_date, total_amount
from orders
where total_amount > (
    select avg(total_amount) 
    from orders
);