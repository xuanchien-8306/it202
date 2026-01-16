/*
 * DATABASE SETUP - SESSION 15 EXAM
 * Database: StudentManagement
 */

DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

-- =============================================
-- 1. TABLE STRUCTURE
-- =============================================

-- Table: Students
CREATE TABLE Students (
    StudentID CHAR(5) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    TotalDebt DECIMAL(10,2) DEFAULT 0
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID CHAR(5) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credits INT CHECK (Credits > 0)
);

-- Table: Grades
CREATE TABLE Grades (
    StudentID CHAR(5),
    SubjectID CHAR(5),
    Score DECIMAL(4,2) CHECK (Score BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT FK_Grades_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);

-- Table: GradeLog
CREATE TABLE GradeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID CHAR(5),
    OldScore DECIMAL(4,2),
    NewScore DECIMAL(4,2),
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. SEED DATA
-- =============================================

-- Insert Students
INSERT INTO Students (StudentID, FullName, TotalDebt) VALUES 
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

-- Insert Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Credits) VALUES 
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

-- Insert Grades
INSERT INTO Grades (StudentID, SubjectID, Score) VALUES 
('SV01', 'SB01', 8.5), -- Passed
('SV03', 'SB02', 3.0); -- Failed

-- End of File

-- ------ Câu 1 ------------
drop trigger if exists tg_CheckScore;
delimiter $$
create trigger tg_CheckScore 
before insert on grades
for each row
begin 
	if new.Score < 0 then
        set new.Score = 0;
	elseif new.Score > 10 then
		set new.Score = 10;
	end if;
end $$
delimiter ;

insert into grades(studentid, subjectid, score)
values ('sv01', 'sb02', 11);

insert into grades(studentid, subjectid, score)
values ('sv03', 'sb01', -5);

-- -------- Câu 2 -------------
start transaction;
insert into students(studentid, fullname)
value ('sv02', 'Ha Bich Ngoc');

update students
set totaldebt = 5000000
where studentid = 'sv02';

commit;

select * from students where studentid = 'sv02';

-- ------- Câu 3 --------------
drop trigger if exists tg_loggradeupdate;
delimiter $$
create trigger tg_loggradeupdate
after update on grades
for each row
begin
	if old.score <> new.score then
		insert into gradelog(studentid, oldscore, newscore, changedate)
        value (old.studentid, old.score, new.score, now());
	end if;
end $$
delimiter ;

update grades
set score = 9
where studentid = 'sv01'
  and subjectid = 'sb01';

select * from gradelog;

-- ------------ Câu 4 ------------
drop procedure if exists sp_paytuition;
delimiter $$
create procedure sp_paytuition()
begin
    declare v_totaldebt decimal(10,2);

    start transaction;

    update students
    set totaldebt = totaldebt - 2000000
    where studentid = 'sv01';

    select totaldebt into v_totaldebt
    from students
    where studentid = 'sv01';

    if v_totaldebt < 0 then
        rollback;
    else
        commit;
    end if;
end $$
delimiter ;

call sp_paytuition();

select totaldebt
from students
where studentid = 'sv01';

-- ---------- Câu 5 ---------------
drop trigger if exists tg_preventpassupdate;
delimiter $$
create trigger tg_preventpassupdate
before update on grades
for each row
begin
    if old.score >= 4.0 then
        signal sqlstate '45000'
        set message_text = 'khong duoc sua diem cua mon da qua';
    end if;
end $$
delimiter ;

update grades
set score = 7
where studentid = 'sv01'
  and subjectid = 'sb01';
