create database ss13;
use ss13;

create table users (
    user_id int auto_increment primary key,
    username varchar(50) not null unique,
    email varchar(100) not null unique,
    created_at date,
    follower_count int default 0,
    post_count int default 0
);

-- ---------- 1 ---------------
delimiter $$
create procedure  add_user(p_username varchar(100), p_email varchar(255), p_created_at datetime)
begin 
	insert into users(username, email, created_at) value
		(p_username, p_email, p_created_at);
end $$
delimiter ;	
call add_user('test_user', 'test@gmail.com', curdate());

select * from users;
	
-- ---------- 2 -----------------    
drop trigger if exists tg_check_user;
delimiter $$
create trigger tg_check_user
before insert on users
for each row
begin
    if new.email not like '%@%' or new.email not like '%.%' then
        signal sqlstate '45000'
        set message_text = 'email khong hop le';
    end if;

    if new.username not regexp '^[a-zA-Z0-9_]+$' then
        signal sqlstate '45000'
        set message_text = 'username chua ky tu khong hop le';
    end if;
end $$
delimiter ;
call add_user('user_01', 'user001@gmail.com', curdate());
call add_user('user_02', 'user02gmail.com', curdate());
call add_user('user@03', 'user03@gmail.com', curdate());

select * from users;


