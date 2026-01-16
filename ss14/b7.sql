use social_network;

alter table users
add column following_count int default 0,
add column followers_count int default 0;

drop table if exists followers;

create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id),
    constraint fk_followers_follower
        foreign key (follower_id)
        references users(user_id)
        on delete cascade,
    constraint fk_followers_followed
        foreign key (followed_id)
        references users(user_id)
        on delete cascade
);

drop procedure if exists sp_follow_user;
delimiter $$

create procedure sp_follow_user(
    in p_follower_id int,
    in p_followed_id int
)
begin
    declare v_count int;
    declare v_follower_exists int;
    declare v_followed_exists int;

    start transaction;

    select count(*) into v_follower_exists
    from users
    where user_id = p_follower_id;

    select count(*) into v_followed_exists
    from users
    where user_id = p_followed_id;

    if v_follower_exists = 0 or v_followed_exists = 0 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'nguoi dung khong ton tai';
    end if;

    if p_follower_id = p_followed_id then
        rollback;
        signal sqlstate '45000'
        set message_text = 'khong duoc tu follow chinh minh';
    end if;

    select count(*) into v_count
    from followers
    where follower_id = p_follower_id
      and followed_id = p_followed_id;

    if v_count > 0 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'da ton tai quan he follow';
    end if;

    insert into followers(follower_id, followed_id)
    values (p_follower_id, p_followed_id);

    update users
    set following_count = following_count + 1
    where user_id = p_follower_id;

    update users
    set followers_count = followers_count + 1
    where user_id = p_followed_id;

    commit;
end $$

delimiter ;

call sp_follow_user(1, 2);

select user_id, following_count, followers_count
from users
where user_id in (1, 2);

select * from followers;

call sp_follow_user(1, 1);

call sp_follow_user(1, 2);

call sp_follow_user(999, 2);

select 
    u.user_id,
    u.following_count,
    count(f.followed_id) as real_following
from users u
left join followers f on u.user_id = f.follower_id
group by u.user_id;

select 
    u.user_id,
    u.followers_count,
    count(f.follower_id) as real_followers
from users u
left join followers f on u.user_id = f.followed_id
group by u.user_id;
