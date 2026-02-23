-- 07_functions.sql
-- Run as USER1

CREATE OR REPLACE FUNCTION FN_CALC_GRADE (p_examresult_id IN NUMBER)
RETURN VARCHAR2
IS
    v_score NUMBER;
    v_grade VARCHAR2(2);
    v_status VARCHAR2(10);
BEGIN
    SELECT score
    INTO v_score
    FROM examresults
    WHERE id = p_examresult_id
    FOR UPDATE;

    IF v_score BETWEEN 90 AND 100 THEN
        v_grade := 'A';
    ELSIF v_score BETWEEN 80 AND 89 THEN
        v_grade := 'B';
    ELSIF v_score BETWEEN 70 AND 79 THEN
        v_grade := 'C';
    ELSIF v_score BETWEEN 60 AND 69 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'F';
    END IF;

    IF v_grade = 'F' THEN
        v_status := 'Fail';
    ELSE
        v_status := 'Pass';
    END IF;

    UPDATE examresults
    SET grade = v_grade,
        status = v_status
    WHERE id = p_examresult_id;

    RETURN v_grade;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'ExamResults ID not found.');
END;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION FN_CALC_GPA (p_student_id IN NUMBER)
RETURN NUMBER
IS
  v_total_points NUMBER := 0;
  v_total_credits NUMBER := 0;
  v_gpa NUMBER := 0;
BEGIN
  FOR rec IN (
    SELECT c.credit_hours,
           er.grade
    FROM students s
    JOIN register r     ON r.student_id = s.id
    JOIN courses  c     ON c.id = r.course_id
    JOIN examresults er ON er.registration_id = r.id
    WHERE s.id = p_student_id
      AND er.grade IS NOT NULL
  ) LOOP
    v_total_credits := v_total_credits + rec.credit_hours;

    v_total_points := v_total_points +
      (CASE rec.grade
         WHEN 'A' THEN 4
         WHEN 'B' THEN 3
         WHEN 'C' THEN 2
         WHEN 'D' THEN 1
         WHEN 'F' THEN 0
         ELSE 0
       END) * rec.credit_hours;
  END LOOP;

  IF v_total_credits = 0 THEN
    RETURN NULL;
  END IF;

  v_gpa := v_total_points / v_total_credits;
  RETURN ROUND(v_gpa, 2);
END;
/
SHOW ERRORS;
