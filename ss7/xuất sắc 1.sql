select name
from customers c
where 
    (select sum(total_amount) from orders o where o.customer_id = c.id) 
    = (
        select max(tong_tien)
        from (
            select sum(total_amount) as tong_tien
            from orders
            group by customer_id
        ) as bang_tam
);