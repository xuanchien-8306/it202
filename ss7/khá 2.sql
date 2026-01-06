
create table products(
	id int primary key auto_increment,
    name varchar(100),
    price decimal(10,2)
);

create table order_items(
	order_id int,
    product_id int,
    quantity int,
    primary key(order_id, product_id),
    foreign key (order_id) references orders(id),
    foreign key (product_id) references products(id)
);

insert into products (id, name, price) values 
(1, 'Laptop Dell XPS', 25000000),
(2, 'iPhone 15', 30000000),
(3, 'Chuột Logitech', 500000),
(4, 'Bàn phím cơ', 1500000),
(5, 'Tai nghe Sony', 2000000); 

insert into order_items (order_id, product_id, quantity) values 
(101, 1, 1), 
(101, 3, 2), 
(102, 2, 1), 
(103, 1, 1), 
(104, 4, 1);

select id, name, price
from products
where id in (
    select distinct product_id
    from order_items
);