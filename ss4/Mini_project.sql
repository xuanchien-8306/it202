create database miniProject;
use miniProject;

create table Reader(
	reader_id int auto_increment,
    reader_name varchar(100) not null,
    phone varchar(15) unique,
    register_date date default(current_date()),
    
    -- khoá chính
    constraint pk_reader primary key(reader_id)
);

create table Book(
	book_id int,
    book_title varchar(150) not null,
    author varchar(100),
    publish_year int check(publish_year >= 1900),
    
    -- khoá chính
    constraint pk_book primary key(book_id)
);

create table Borrow(
	reader_id int,
    book_id int,
    borrow_date date default(current_date()),
    return_date date
);

alter table Reader
add email varchar(100) unique;

alter table Book
modify author varchar(150);

alter table Borrow
add constraint chk_return_date
check(return_date >= borrow_date);

insert into Reader(reader_id, reader_name, phone, email, register_date)
value 
	(1, 'Nguyễn Văn An', '0901234567', 'an.nguyen@gmail.com', '2024-09-01'),
    (2,'Trần Thị Bình','0912345678','binh.tran@gmail.com', '2024-09-05'),
    (3, 'Lê Minh Châu', '0923456789', 'chau.le@gmail.com', '2024-09-10');
    
insert into Book(book_id, book_title, author, publish_year)
value 
	(101, 'Lập trình C căn bản', 'Nguyễn Văn A','2018'),
    (102, 'Cơ sở dữ liệu', 'Trần Thị B', '2020'),
    (103, 'Lập trình Java', 'Lê Minh C', '2019'),
    (104, 'Hệ quản trị MySQL', 'Phạm Văn D', '2021');
    
insert into Borrow(reader_id, book_id, borrow_date, return_date)
value
	(1, 101, '2024-09-15', NULL),
    (1, 102, '2024-09-15', '2024-09-25'),
    (2, 103, '2024-09-18', NULL);
    
update Borrow 
set return_date = '2024-10-01' where reader_id = 1;

update Book 
set publish_year = 2023 where publish_year >= 2021;

delete from Borrow where borrow_date < '2024-09-18';

select * from Reader;
select * from Book;
select * from Borrow








