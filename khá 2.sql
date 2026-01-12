use social_network_pro;
DROP PROCEDURE IF EXISTS CalculatePostLikes;
delimiter $$
create procedure CalculatePostLikes (in p_post_id int, out total_likes int)
begin
	select count(*) 
    into total_likes
    from likes
    where post_id = p_post_id;
end $$	
delimiter ;

set @total_likes = 0;

call CalculatePostLikes(8, @total_likes);	
select @total_likes;

drop procedure if exists CalculatePostLikes;