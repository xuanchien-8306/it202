use social_network;

alter table posts
add column comments_count int default 0;

drop table if exists comments;

create table comments (
    comment_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    constraint fk_comments_posts
        foreign key (post_id)
        references posts(post_id)
        on delete cascade,
    constraint fk_comments_users
        foreign key (user_id)
        references users(user_id)
        on delete cascade
);

drop procedure if exists sp_post_comment;
delimiter $$

create procedure sp_post_comment(
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    insert into comments(post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);

    savepoint after_insert;

    update posts
    set comments_count = comments_count + 1
    where post_id = p_post_id;

    if row_count() = 0 then
        rollback to after_insert;
        commit;
    else
        commit;
    end if;
end $$

delimiter ;

call sp_post_comment(1, 2, 'day la binh luan hop le');

select * from comments where post_id = 1;
select post_id, comments_count from posts where post_id = 1;

call sp_post_comment(999, 2, 'binh luan vao post khong ton tai');

select * from comments where content = 'binh luan vao post khong ton tai';

select post_id, comments_count from posts;

select 
    p.post_id,
    p.comments_count,
    count(c.comment_id) as real_comments
from posts p
left join comments c on p.post_id = c.post_id
group by p.post_id;
