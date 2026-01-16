use social_network;

drop table if exists delete_log;

create table delete_log (
    log_id int auto_increment primary key,
    post_id int not null,
    deleted_at datetime default current_timestamp,
    deleted_by int not null
);

drop procedure if exists sp_delete_post;
delimiter $$

create procedure sp_delete_post(
    in p_post_id int,
    in p_user_id int
)
begin
    declare v_count int;
    declare v_owner_id int;

    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    select user_id into v_owner_id
    from posts
    where post_id = p_post_id
    for update;

    if v_owner_id is null or v_owner_id <> p_user_id then
        rollback;
        signal sqlstate '45000'
        set message_text = 'bai viet khong ton tai hoac khong thuoc quyen so huu';
    end if;

    delete from likes
    where post_id = p_post_id;

    delete from comments
    where post_id = p_post_id;

    delete from posts
    where post_id = p_post_id;

    if row_count() = 0 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'xoa bai viet that bai';
    end if;

    update users
    set post_count = post_count - 1
    where user_id = p_user_id;

    insert into delete_log(post_id, deleted_by)
    values (p_post_id, p_user_id);

    commit;
end $$

delimiter ;

call sp_delete_post(1, 2);

-- kiểm tra dữ liệu sau khi xóa
select * from posts where post_id = 1;
select * from likes where post_id = 1;
select * from comments where post_id = 1;

select user_id, post_count
from users
where user_id = 2;

select * from delete_log;

call sp_delete_post(2, 1);

select * from posts where post_id = 2;
select * from likes where post_id = 2;
select * from comments where post_id = 2;

select 
    u.user_id,
    u.post_count,
    count(p.post_id) as real_posts
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id;
