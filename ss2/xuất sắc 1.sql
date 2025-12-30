CREATE TABLE score (
    student_id_02 INT,
    subjects_id INT,
    diem_qua_trinh FLOAT CHECK (diem_qua_trinh BETWEEN 0 AND 10),
    diem_cuoi_ky FLOAT CHECK (diem_cuoi_ky BETWEEN 0 AND 10),

    PRIMARY KEY (student_id_02, subjects_id),

    FOREIGN KEY (student_id_02)
        REFERENCES student_02(student_id_02),

    FOREIGN KEY (subjects_id)
        REFERENCES subjects(subjects_id)
);
