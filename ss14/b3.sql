CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(15,2) NOT NULL -- Số dư quỹ công ty
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,   -- Tên nhân viên
    salary DECIMAL(10,2) NOT NULL    -- Lương nhân viên
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,                      -- ID nhân viên (FK)
    salary DECIMAL(10,2) NOT NULL,   -- Lương được nhận
    pay_date DATE NOT NULL,          -- Ngày nhận lương
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);

delimiter $$
create procedure pay_salary_transaction(p_emp_id int)
begin
    declare v_fund_balance decimal(15,2);
    declare v_salary decimal(10,2);
    declare v_bank_error boolean default false;

    start transaction;

    select balance
    into v_fund_balance
    from company_funds
    where fund_id = 1
    for update;

    select salary
    into v_salary
    from employees
    where emp_id = p_emp_id;

    if v_fund_balance < v_salary then
        rollback;
        signal sqlstate '45000'
        set message_text = 'quỹ công ty không đủ tiền để trả lương';
    else
        update company_funds
        set balance = balance - v_salary
        where fund_id = 1;

        insert into payroll (emp_id, salary, pay_date)
        values (p_emp_id, v_salary, curdate());

        -- mô phỏng lỗi hệ thống ngân hàng
        -- set v_bank_error = true;

        if v_bank_error = true then
            rollback;
            signal sqlstate '45000'
            set message_text = 'lỗi hệ thống ngân hàng, giao dịch bị hoàn tác';
        else
            commit;
        end if;
    end if;

end$$

delimiter ;
call pay_salary_transaction(1);

