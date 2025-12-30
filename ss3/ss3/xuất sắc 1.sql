USE ss_03;

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

INSERT INTO score (student_id, subjects_id, mid_score, final_score)
VALUES
(1, 1, 7.5, 8.0),
(2, 1, 6.0, 7.5),
(3, 2, 8.0, 9.0);

UPDATE score
SET final_score = 8.5
WHERE student_id = 2
  AND subjects_id = 1;

SELECT *
FROM score
WHERE final_score >= 8;

SELECT 
    s.student_id,
    s.full_name,
    sub.subjects_name,
    sc.mid_score,
    sc.final_score
FROM score sc
JOIN student s ON sc.student_id = s.student_id
JOIN subjects sub ON sc.subjects_id = sub.subjects_id;
