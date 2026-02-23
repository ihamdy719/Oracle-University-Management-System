-- 09_tests_and_demo.sql
-- Run as USER2 (has insert/select permissions)

-- Insert a sample examresult then calculate grade using USER1 function
-- (Function is in USER1 schema; call it with schema prefix)
INSERT INTO USER1.EXAMRESULTS (id, registration_id, score, grade, status)
VALUES (1, 1, 85, NULL, NULL);
COMMIT;

SET SERVEROUTPUT ON;

DECLARE
  v_g VARCHAR2(2);
BEGIN
  v_g := USER1.FN_CALC_GRADE(1);
  DBMS_OUTPUT.PUT_LINE('Calculated Grade = ' || v_g);
END;
/

-- Create exams schedule
INSERT INTO USER1.EXAMS (id, course_id, exam_date, exam_type)
VALUES (1, 101, TO_DATE('2025-12-20','YYYY-MM-DD'), 'Midterm');

INSERT INTO USER1.EXAMS (id, course_id, exam_date, exam_type)
VALUES (2, 101, TO_DATE('2026-01-10','YYYY-MM-DD'), 'Final');

COMMIT;

-- Course performance report
SET SERVEROUTPUT ON;
BEGIN
  USER1.PR_COURSE_PERFORMANCE_REPORT(101);
END;
/

-- Fail-case demo (ensure registration ids exist and are consistent)
-- Add two more registrations for student 1
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (1001, 1, 101);
INSERT INTO USER1.REGISTER (id, student_id, course_id) VALUES (1002, 1, 102);
COMMIT;

-- Insert failing exam results for the above
INSERT INTO USER1.EXAMRESULTS (id, registration_id, score, grade, status)
VALUES (201, 1001, 40, 'F', 'Fail');

INSERT INTO USER1.EXAMRESULTS (id, registration_id, score, grade, status)
VALUES (202, 1002, 50, 'F', 'Fail');

COMMIT;

BEGIN
  USER1.PR_ISSUE_WARNINGS;
END;
/

SELECT * FROM USER1.WARNINGS ORDER BY id;

-- GPA example
SELECT USER1.FN_CALC_GPA(1) AS GPA FROM dual;

-- Uniqueness check (optional hardening): enforce 1 examresult per registration
-- Run only after cleanup if needed:
-- ALTER TABLE USER1.EXAMRESULTS ADD CONSTRAINT uq_examresults_reg UNIQUE (registration_id);
