-- 2
create or replace view view_users_firstname as
select user_id, username, full_name, email, created_at
from users u
where full_name like '%Nguyễn%'; 

-- 3
select * from view_users_firstname;

-- 4 thêm nhân viên mới
insert into users (username, full_name, gender, email, password, birthdate, hometown) value
	('nguyenvana',
    'Nguyễn Văn A',
    'Nam',
    'nguyenvana@gmail.com',
    '123456',
    '1998-05-20',
    'Hà Nội');

-- 5
delete from users where username = 'nguyenvana';