create database ss_07;	
use ss_07;

create table customers (
    id int primary key auto_increment ,
    name varchar(100),
    email varchar(100)
);

create table orders (
    id int primary key auto_increment,	
    customer_id int,
    order_date date,
    total_amount decimal(10, 2),
    foreign key (customer_id) references customers(id)
);
insert into customers (id, name, email) values 
(1, 'Le Minh Hoang', 'minhhoang@example.com'),
(2, 'Tran Quang Huy', 'quanghuy@example.com'),
(3, 'Pham Thu Trang', 'thutrang@example.com'),
(4, 'Nguyen Tien Dat', 'tiendat@example.com'),
(5, 'Vo Duc Thinh', 'ducthinh@example.com'),
(6, 'Bui Thi Lan Anh', 'lananh@example.com'),
(7, 'Hoang Van Khoa', 'vankhoa@example.com');

insert into orders (id, customer_id, order_date, total_amount) values 
(101, 1, '2023-12-01', 500000),
(102, 4, '2023-12-20', 450000),
(103, 5, '2023-12-22', 900000),
(104, 1, '2023-12-25', 150000);

select id, name, email
from customers
where id in (
    select distinct customer_id 
    from orders
);