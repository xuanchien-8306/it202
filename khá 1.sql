delimiter $$
create procedure baiviet( in p_user_id int)
begin 
	select 	
		post_id as Post_id,
        content as content,
        created_at
	from posts
    where post_id = p_user_id
    order by created_at desc;
end $$
delimiter ;	
	
CALL baiviet(81);
DROP PROCEDURE IF EXISTS baiviet;
