-- 04_seed_data.sql
-- Run as USER2

-- Clean demo rows (best effort)
DELETE FROM USER1.REGISTER;
DELETE FROM USER1.EXAMRESULTS;
DELETE FROM USER1.EXAMS;
DELETE FROM USER1.STUDENTS;
DELETE FROM USER1.COURSES;
DELETE FROM USER1.PROFESSORS;
COMMIT;

INSERT INTO USER1.PROFESSORS (id, name, department) VALUES (1, 'Dr. Ahmed',   'DS');
INSERT INTO USER1.PROFESSORS (id, name, department) VALUES (2, 'Dr. Elsayed', 'RSE');

INSERT INTO USER1.COURSES (id, name, professor_id, credit_hours, prerequisite_course_id)
VALUES (101, 'Databases', 1, 3, NULL);

INSERT INTO USER1.COURSES (id, name, professor_id, credit_hours, prerequisite_course_id)
VALUES (102, 'Adv Databases', 1, 3, 101);

INSERT INTO USER1.COURSES (id, name, professor_id, credit_hours, prerequisite_course_id)
VALUES (103, 'AI For Beginners', 2, 3, NULL);

INSERT INTO USER1.STUDENTS (id, name, academic_status, total_credits) VALUES (1, 'Omnya',   'Active', 0);
INSERT INTO USER1.STUDENTS (id, name, academic_status, total_credits) VALUES (2, 'Yasmin',  'Active', 0);
INSERT INTO USER1.STUDENTS (id, name, academic_status, total_credits) VALUES (3, 'Mohamed', 'Active', 0);
INSERT INTO USER1.STUDENTS (id, name, academic_status, total_credits) VALUES (4, 'Ibrahim', 'Active', 0);
INSERT INTO USER1.STUDENTS (id, name, academic_status, total_credits) VALUES (5, 'Bebars',  'Active', 0);

INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (1, 1, 101);
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (2, 2, 101);
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (3, 3, 103);
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (4, 4, 101);
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (5, 5, 103);

COMMIT;

SELECT COUNT(*) AS students_count FROM USER1.STUDENTS;
SELECT COUNT(*) AS register_count  FROM USER1.REGISTER;
