use ss_03;
create table subjects(
	subjects_id int primary key,
    subjects_name varchar(30) not null,
    credit int not null check(credit > 0) 
);

-- thêm
insert into subjects(subjects_id, subjects_name, credit)
value 	(1, 'Co so du lieu', 10),
		(2, 'Lap trinh c', 13),
        (3, 'Thuc tap', 8);
        
-- cập nhật
update subjects
set credit = 15 where subjects_id = 1;
update subjects
set subjects_name = 'javaScript' where subjects_id = 1;

select * from subjects