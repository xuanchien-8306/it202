use social_network_pro;

delimiter $$
create procedure CalculateBonusPoints (in p_user_id int, inout p_bonus_points int)
begin 
	declare v_post_count int default 0;
	select count(*) 
    into v_post_count
    from posts
    where user_id = p_user_id;
    
    if v_post_count >= 20 then
		set p_bonus_points = p_bonus_points + 100;
	elseif v_post_count >= 10 then
		set p_bonus_points = p_bonus_points + 50;
	end if;
    
end $$
delimiter ;

set @bonus_points = 100;
call CalculateBonusPoints(1, @bonus_points);
select @bonus_points as bonus_points_after_calculation;
drop procedure if exists CalculateBonusPoints;