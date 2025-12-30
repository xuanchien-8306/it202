-- TẠO DATABASE
USE ss_03;

-- =========================
-- BẢNG STUDENT
-- =========================
CREATE TABLE student (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(30) UNIQUE
);

INSERT INTO student (student_id, full_name, date_of_birth, email) VALUES
(1, 'Nguyen Van A', '2002-01-15', 'a@gmail.com'),
(2, 'Tran Thi B', '2001-08-20', 'b@gmail.com'),
(3, 'Le Van C', '2003-03-10', 'c@gmail.com'),
(4, 'Ta Xuan Chien', '2006-03-08', 'chien@gmail.com');

-- =========================
-- BẢNG SUBJECTS
-- =========================
CREATE TABLE subjects (
    subjects_id INT PRIMARY KEY,
    subjects_name VARCHAR(30) NOT NULL,
    credit INT NOT NULL CHECK (credit > 0)
);

INSERT INTO subjects (subjects_id, subjects_name, credit) VALUES
(1, 'Co so du lieu', 10),
(2, 'Lap trinh C', 13),
(3, 'Thuc tap', 8);

UPDATE subjects
SET credit = 15, subjects_name = 'JavaScript'
WHERE subjects_id = 1;

-- =========================
-- BẢNG ENROLLMENT
-- =========================
CREATE TABLE enrollment (
    student_id INT NOT NULL,
    subjects_id INT NOT NULL,
    enroll_date DATE NOT NULL,

    PRIMARY KEY (student_id, subjects_id),

    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id),

    CONSTRAINT fk_enroll_subjects
        FOREIGN KEY (subjects_id)
        REFERENCES subjects(subjects_id)
);

INSERT INTO enrollment (student_id, subjects_id, enroll_date) VALUES
(2, 2, '2024-09-01'),
(3, 3, '2024-09-01'),
(4, 1, '2024-09-02');

-- =========================
-- BẢNG SCORE
-- =========================
CREATE TABLE score (
    student_id INT,
    subjects_id INT,
    mid_score DECIMAL(4,2) CHECK (mid_score BETWEEN 0 AND 10),
    final_score DECIMAL(4,2) CHECK (final_score BETWEEN 0 AND 10),

    PRIMARY KEY (student_id, subjects_id),

    CONSTRAINT fk_score_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_score_subjects
        FOREIGN KEY (subjects_id)
        REFERENCES subjects(subjects_id)
        ON DELETE CASCADE
);

-- =========================
-- THÊM SINH VIÊN MỚI
-- =========================
INSERT INTO student (student_id, full_name, date_of_birth, email)
VALUES (5, 'Pham Thi D', '2002-11-25', 'd@gmail.com');

-- ĐĂNG KÝ 2 MÔN CHO SINH VIÊN MỚI
INSERT INTO enrollment (student_id, subjects_id, enroll_date) VALUES
(5, 1, '2024-09-05'),
(5, 2, '2024-09-05');

-- THÊM ĐIỂM
INSERT INTO score (student_id, subjects_id, mid_score, final_score) VALUES
(5, 1, 7.0, 8.0),
(5, 2, 6.5, 7.5);

-- CẬP NHẬT ĐIỂM CUỐI KỲ
UPDATE score
SET final_score = 8.5
WHERE student_id = 5
  AND subjects_id = 2;

-- XÓA MỘT LƯỢT ĐĂNG KÝ KHÔNG HỢP LỆ
DELETE FROM enrollment
WHERE student_id = 4
  AND subjects_id = 1;

-- =========================
-- TRUY VẤN TỔNG HỢP
-- =========================
SELECT 
    s.student_id,
    s.full_name,
    sub.subjects_name,
    sc.mid_score,
    sc.final_score
FROM score sc
JOIN student s ON sc.student_id = s.student_id
JOIN subjects sub ON sc.subjects_id = sub.subjects_id
ORDER BY s.student_id;
