use socialtriggerdb;

delimiter $$
create trigger tg_like_before_insert
before insert on likes
for each row
begin
    declare v_post_owner int;

    select user_id
    into v_post_owner
    from posts
    where post_id = new.post_id;

    if new.user_id = v_post_owner then
        signal sqlstate '45000'
        set message_text = 'khong duoc like bai viet cua chinh minh';
    end if;
end$$
delimiter ;

delimiter $$
create trigger tg_like_after_insert
after insert on likes
for each row
begin
    update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end$$
delimiter ;

delimiter $$
create trigger tg_like_after_update
after update on likes
for each row
begin
    if old.post_id <> new.post_id then
        update posts
        set like_count = like_count - 1
        where post_id = old.post_id;

        update posts
        set like_count = like_count + 1
        where post_id = new.post_id;
    end if;
end$$
delimiter ;

insert into likes (user_id, post_id)
values (1, 1);

insert into likes (user_id, post_id)
values (1, 2);
select post_id, like_count from posts;

update likes
set post_id = 3
where user_id = 1 and post_id = 2;
select post_id, like_count from posts;

delete from likes
where user_id = 1 and post_id = 3;
select post_id, like_count from posts;

select * from posts;
select * from user_statistics;

