use ss_03;

create table enrollment(
	student_id int not null,
    subjects_id int not null,
    enroll_date date not null,
    
    -- khoá chính
    primary key (student_id, subjects_id),
    
    -- khoá ngoại
    constraint fk_student
		foreign key (student_id)
        references student(student_id),
        
	constraint fk_subjects
		foreign key (subjects_id)
		references subjects(subjects_id)
);

INSERT INTO enrollment (student_id, subjects_id, enroll_date)
VALUES
    (2, 2, '2024-09-01'),
    (3, 3, '2024-09-01'),
    (4, 1, '2024-09-02');
    
SELECT * 
FROM enrollment;


