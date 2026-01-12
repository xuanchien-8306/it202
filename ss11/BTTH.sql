create database SocialLab ;
use SocialLab ;

create table posts(
	post_id INT Primary Key auto_increment,
	content TEXT,
	author VARCHAR(50),
	likes_count INT default 0
);

-- phần 1: thêm
drop procedure if exists sp_CreatePost;
delimiter $$
create procedure sp_CreatePost (in in_content text, in in_author varchar(50), out post_id int)
begin 
	insert into posts (content, author) value
    (in_content, in_author);
    set post_id = last_insert_id();
end $$
delimiter ;

-- phần 2: read search
drop procedure if exists sp_SearchPost;
delimiter $$
create procedure sp_SearchPost (in in_search varchar(255))
begin
	select * 
    from posts
    where content like concat('%', in_search, '%');
end $$
delimiter ;

-- Phần 3: update
drop procedure if exists sp_IncreaseLike;
delimiter $$
create procedure sp_IncreaseLike (in in_post_id int, inout in_likes int)
begin
	update posts 
    set likes_count = likes_count + 1
    where post_id = in_post_id;
    
    select likes_count
    into in_likes
    from posts
    where post_id = in_post_id;
end $$
delimiter ;

-- phần 4: xoá
drop procedure if exists sp_DeletePost;
DELIMITER $$

CREATE PROCEDURE sp_DeletePost (
    IN in_post_id INT
)
BEGIN
    DELETE FROM posts
    WHERE post_id = in_post_id;
END $$

DELIMITER ;



set @post_id_1 = 0;
call sp_CreatePost('hello world from mysql', 'Alice', @post_id_1);
select @post_id_1 as first_post_id;

set @post_id_2 = 0;
call sp_CreatePost('this is a hello post', 'Bob', @post_id_2);
select @post_id_2 as second_post_id;

call sp_SearchPost('hello');

set @likes = 0;
call sp_IncreaseLike(@post_id_1, @likes);
select @likes as likes_after_increase;

call sp_DeletePost(@post_id_2);
	
drop procedure if exists sp_CreatePost;
drop procedure if exists sp_SearchPost;
drop procedure if exists sp_IncreaseLike;
drop procedure if exists sp_DeletePost;
