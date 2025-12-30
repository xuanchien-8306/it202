-- =====================================================
-- PHẦN I: TẠO CSDL & BẢNG (DDL)
-- =====================================================
CREATE DATABASE IF NOT EXISTS OnlineLearning;
USE OnlineLearning;

-- -------------------------
-- BẢNG STUDENT
-- -------------------------
CREATE TABLE Student (
    student_id CHAR(10) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE
);

-- -------------------------
-- BẢNG INSTRUCTOR (GIẢNG VIÊN)
-- -------------------------
CREATE TABLE Instructor (
    instructor_id CHAR(10) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE
);

-- -------------------------
-- BẢNG COURSE (KHÓA HỌC)
-- -------------------------
CREATE TABLE Course (
    course_id CHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    sessions INT NOT NULL CHECK (sessions > 0),
    instructor_id CHAR(10) NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

-- -------------------------
-- BẢNG ENROLLMENT (ĐĂNG KÝ)
-- -------------------------
CREATE TABLE Enrollment (
    student_id CHAR(10) NOT NULL,
    course_id CHAR(10) NOT NULL,
    enroll_date DATE NOT NULL,
    PRIMARY KEY (student_id, course_id),   -- không đăng ký trùng khóa
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- -------------------------
-- BẢNG RESULT (KẾT QUẢ)
-- -------------------------
CREATE TABLE Result (
    student_id CHAR(10) NOT NULL,
    course_id CHAR(10) NOT NULL,
    mid_score DECIMAL(4,2) CHECK (mid_score BETWEEN 0 AND 10),
    final_score DECIMAL(4,2) CHECK (final_score BETWEEN 0 AND 10),
    PRIMARY KEY (student_id, course_id),   -- mỗi SV 1 kết quả/môn
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- =====================================================
-- PHẦN II: NHẬP DỮ LIỆU BAN ĐẦU (INSERT)
-- =====================================================

-- 1) Thêm 5 sinh viên
INSERT INTO Student (student_id, full_name, date_of_birth, email) VALUES
('SV01','Nguyen Van An','2003-01-10','an@gmail.com'),
('SV02','Tran Thi Binh','2003-02-15','binh@gmail.com'),
('SV03','Le Minh Chau','2003-03-20','chau@gmail.com'),
('SV04','Pham Quoc Dung','2003-04-25','dung@gmail.com'),
('SV05','Hoang Thi Em','2003-05-30','em@gmail.com');

-- 2) Thêm 5 giảng viên
INSERT INTO Instructor (instructor_id, full_name, email) VALUES
('GV01','Nguyen Van Thay','thay@gmail.com'),
('GV02','Tran Thi Co','co@gmail.com'),
('GV03','Le Van Giang','giang@gmail.com'),
('GV04','Pham Thi Huong','huong@gmail.com'),
('GV05','Do Van Minh','minh@gmail.com');

-- 3) Thêm 5 khóa học
INSERT INTO Course (course_id, course_name, description, sessions, instructor_id) VALUES
('KH01','Co so du lieu','Nhap mon CSDL',30,'GV01'),
('KH02','Lap trinh Java','Java can ban',45,'GV02'),
('KH03','Mang may tinh','Kien thuc mang',30,'GV03'),
('KH04','He dieu hanh','Nguyen ly HDH',30,'GV04'),
('KH05','Thiet ke Web','HTML CSS JS',40,'GV05');

-- 4) Đăng ký học
INSERT INTO Enrollment (student_id, course_id, enroll_date) VALUES
('SV01','KH01','2024-09-01'),
('SV01','KH02','2024-09-01'),
('SV02','KH01','2024-09-02'),
('SV03','KH03','2024-09-03'),
('SV04','KH04','2024-09-04');

-- 5) Thêm kết quả học tập
INSERT INTO Result (student_id, course_id, mid_score, final_score) VALUES
('SV01','KH01',7.5,8.0),
('SV01','KH02',6.5,7.5),
('SV02','KH01',8.0,8.5),
('SV03','KH03',7.0,9.0),
('SV04','KH04',6.0,7.0);

-- =====================================================
-- PHẦN III: CẬP NHẬT DỮ LIỆU (UPDATE)
-- =====================================================

-- 1) Cập nhật email cho một sinh viên
UPDATE Student
SET email = 'an_new@gmail.com'
WHERE student_id = 'SV01';

-- 2) Cập nhật mô tả khóa học
UPDATE Course
SET description = 'Java nang cao'
WHERE course_id = 'KH02';

-- 3) Cập nhật điểm cuối kỳ cho một sinh viên
UPDATE Result
SET final_score = 9.0
WHERE student_id = 'SV01' AND course_id = 'KH01';

-- =====================================================
-- PHẦN IV: XÓA DỮ LIỆU (DELETE)
-- =====================================================

-- 1) Xóa một lượt đăng ký không hợp lệ
DELETE FROM Enrollment
WHERE student_id = 'SV04' AND course_id = 'KH04';

-- 2) Xóa kết quả học tập tương ứng (nếu cần)
DELETE FROM Result
WHERE student_id = 'SV04' AND course_id = 'KH04';

-- =====================================================
-- PHẦN V: TRUY VẤN DỮ LIỆU (SELECT)
-- =====================================================

-- 1) Danh sách sinh viên
SELECT * FROM Student;

-- 2) Danh sách giảng viên
SELECT * FROM Instructor;

-- 3) Danh sách khóa học
SELECT * FROM Course;

-- 4) Thông tin đăng ký học
SELECT * FROM Enrollment;

-- 5) Thông tin kết quả học tập
SELECT * FROM Result;
	