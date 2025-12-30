CREATE TABLE enrollment (
    student_id_02 INT NOT NULL,
    subjects_id INT NOT NULL,
    enroll_date DATE NOT NULL,

    PRIMARY KEY (student_id_02, subjects_id),

    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id_02)
        REFERENCES student_02(student_id_02),

    CONSTRAINT fk_enroll_subject
        FOREIGN KEY (subjects_id)
        REFERENCES subjects(subjects_id)
);
