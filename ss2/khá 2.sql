create table student_02(
	student_id_02 int primary key,
    full_name varchar(20) not null unique
);

create table subjects(
	subjects_id int primary key,
    subjects_name varchar(30) not null unique,
    credits int not null check(credits > 0)
);

