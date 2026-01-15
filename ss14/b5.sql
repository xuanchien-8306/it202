create database ss14;
use ss14;

create table users (
    user_id int primary key auto_increment,
    username varchar(50) not null,
    posts_count int default 0
);

create table posts (
    post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

insert into users (username) values
('nguyen van an'),
('tran thi ba');

-- ------trường hợp thành công--------
start transaction;

insert into posts (user_id, content)
values (1, 'bài viết đầu tiên của người dùng 1');

update users
set posts_count = posts_count + 1
where user_id = 1;

commit;
select * from posts;
select * from users;

-- ---- trường hợp lỗi -----------
start transaction;

insert into posts (user_id, content)
values (99, 'bài viết lỗi để test rollback');

update users
set posts_count = posts_count + 1
where user_id = 99;
rollback;
select * from posts;
select * from users;
