use btth_ss14;

create table accounts (
	account_id int primary key auto_increment,
    account_name varchar(50),
    balance decimal(10,2)
);

INSERT INTO accounts (account_name, balance) VALUES 
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);		

delimiter $$
create procedure account_transaction(from_account int, to_account int, amount decimal(10,2)) 
begin
    DECLARE from_balance DECIMAL(10,2);

	start transaction;
		select balance into from_balance
        from accounts
        where account_id = from_account
        for update;
        
        if from_balance >= amount then
			update accounts 
            set balance = balance - amount
            where account_id = from_account;
            
            update accounts
            set balance = balance + amount
            where account_id = to_account;
	commit;
		else
			rollback;
            signal sqlstate '45000'
            set message_text = 'Số dư không đủ để thực hiện giao dịch';
		end if;
end $$
delimiter ;

call account_transaction(1, 2, 200.00);
