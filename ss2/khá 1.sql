-- create database session_2;
-- DROP TABLE student;
-- DROP TABLE class;
create table class(
	class_id int primary key,
    class_name varchar(20) not null,
    years char(4) not null	 
);	

create table student(
	student_id char(10) primary key,
    student_name varchar(30) not null,
    date_of_birth date not null,
    class_id int not null,
    constraint fk_student_class
		foreign key (class_id)
        references class(class_id)
);
