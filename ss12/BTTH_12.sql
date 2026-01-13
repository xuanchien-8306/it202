-- Tạo View View_StudentBasic hiển thị: StudentID, FullName , DeptName. Sau đó truy vấn toàn bộ View_StudentBasic;
create or replace view View_StudentBasic as
select  StudentID, FullName, DeptName
from student s
join department d
on 	s.DeptID = d.DeptID;

-- Tạo Regular Index cho cột FullName của bảng Student.
create index idx_student on student(FullName);

-- Viết Stored Procedure GetStudentsIT
drop  procedure GetStudentsIT;
delimiter $$
create procedure GetStudentsIT()
begin
	select StudentID, FullName, DeptName
    from student s
    join department d
    on s.DeptID = d.DeptID
    where DeptName = 'Information Technology';
end $$
delimiter ;

call GetStudentsIT();

-- Tạo View View_StudentCountByDept hiển thị: DeptName, TotalStudents (số sinh viên mỗi khoa).
create or replace view View_StudentCountByDept as
select d.DeptName, count(s.StudentID) as TotalStudents
from department d
join student s 
on d.DeptID = s.DeptID
group by d.DeptName;

select * from View_StudentCountByDept 
where TotalStudents = (
	select max(TotalStudents)
    from View_StudentCountByDept
);
-- Viết Stored Procedure GetTopScoreStudent
delimiter $$
create procedure GetTopScoreStudent(in p_CourseID char(6))
begin
	select s.StudentID, s.FullName, c.CourseName, e.Score
    from enrollment e
    join student s on e.StudentID = s.StudentID
    join Course c on e.CourseID = c.CourseID
    where e.CourseID = p_CourseID
		and e.Score = (
			select max(Score)
            from enrollment
            where CourseID = p_CourseID
		);
end $$
delimiter ;
call GetTopScoreStudent('C00001');
    