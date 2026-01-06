select (select name from customers where id = o.customer_id) as ten_khach_hang,
    sum(total_amount) as tong_tien_mua
from orders o
group by customer_id
having 
    sum(total_amount) > (select avg(tong_tien) from (
            select sum(total_amount) as tong_tien
            from orders
            group by customer_id
        ) as bang_tam);