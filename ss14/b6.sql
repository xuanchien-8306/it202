use ss14;
alter table posts
add column likes_count int default 0;
desc posts;

drop table if exists likes;

create table likes (
    like_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    constraint fk_likes_posts
        foreign key (post_id)
        references posts(post_id)
        on delete cascade,
    constraint fk_likes_users
        foreign key (user_id)
        references users(user_id)
        on delete cascade,
    constraint unique_like unique (post_id, user_id)
);
desc likes;
start transaction;

insert into likes(post_id, user_id)
values (1, 2);

update posts
set likes_count = likes_count + 1
where post_id = 1;

commit;
select * from likes where post_id = 1 and user_id = 2;

select post_id, likes_count
from posts
where post_id = 1;
