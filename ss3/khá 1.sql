create database ss_03;
USE ss_03;
create table student(
	student_id int primary key,
    full_name varchar(30) not null,
    date_of_birth date not null,
    email varchar(30) unique
); 

-- chèn
insert into student(student_id, full_name, date_of_birth, email)
value 	(1, 'Nguyen Van A', '2002-01-15', 'a@gmail.com'),
		(2, 'Tran Thi B', '2001-08-20', 'b@gmail.com'),
		(3, 'Le Van C', '2003-03-10', 'c@gmail.com');
        
-- lấy ra toàn bộ
select * from student;
select student_id, full_name from student