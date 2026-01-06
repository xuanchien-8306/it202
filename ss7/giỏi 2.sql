
insert into customers (id, name, email) values
(8, 'Nguyễn Thị Mai', 'mai.nguyen@example.com'),
(9, 'Trần Văn Hùng', 'hung.tran@gmail.com'),
(10, 'Lê Quang Dũng', 'dung.le@yahoo.com'),
(11, 'Phạm Thu Hà', 'ha.pham@outlook.com'),
(12, 'Hoàng Minh Tuấn', 'tuan.hoang@company.vn');

insert into orders (id, customer_id, order_date, total_amount) values
(108, 1, '2023-10-01', 150000), 
(109, 2, '2023-10-02', 200000),
(110, 3, '2023-10-03', 500000), 
(111, 3, '2023-10-05', 120000), 
(112, 5, '2023-10-06', 300000),
(113, 1, '2023-10-07', 450000); 

select c.name as ten_khach_hang,
    (select count(*) 
	 from orders o 
	 where o.customer_id = c.id
    ) as so_luong_don
from customers c;