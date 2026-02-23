-- 08_procedures.sql
-- Run as USER1

CREATE OR REPLACE PROCEDURE PR_ISSUE_WARNINGS
IS
BEGIN
  FOR rec IN (
      SELECT r.student_id
      FROM register r
      JOIN examresults er
        ON er.registration_id = r.id
      WHERE er.status = 'Fail'
      GROUP BY r.student_id
      HAVING COUNT(*) >= 2
  ) LOOP
      INSERT INTO warnings (id, student_id, warning_reason, warning_date)
      VALUES (
          WARNINGS_SEQ.NEXTVAL,
          rec.student_id,
          'Failing in two or more courses',
          SYSDATE
      );
  END LOOP;

  COMMIT;
END;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE PR_COURSE_PERFORMANCE_REPORT (p_course_id IN NUMBER)
IS
    CURSOR c_report IS
        SELECT s.id   AS student_id,
               s.name AS student_name,
               r.id   AS registration_id,
               er.score,
               er.grade,
               er.status
        FROM register r
        JOIN students s
          ON s.id = r.student_id
        LEFT JOIN examresults er
          ON er.registration_id = r.id
        WHERE r.course_id = p_course_id
        ORDER BY s.id;

    v_course_name courses.name%TYPE;
    v_pass NUMBER := 0;
    v_fail NUMBER := 0;
    v_total NUMBER := 0;
BEGIN
    SELECT name INTO v_course_name
    FROM courses
    WHERE id = p_course_id;

    DBMS_OUTPUT.PUT_LINE('Course Report: ' || v_course_name || ' (Course ID=' || p_course_id || ')');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    FOR rec IN c_report LOOP
        v_total := v_total + 1;

        IF rec.status = 'Pass' THEN
            v_pass := v_pass + 1;
        ELSIF rec.status = 'Fail' THEN
            v_fail := v_fail + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'StudentID=' || rec.student_id ||
            ', Name=' || rec.student_name ||
            ', RegID=' || rec.registration_id ||
            ', Score=' || NVL(TO_CHAR(rec.score), 'N/A') ||
            ', Grade=' || NVL(rec.grade, 'N/A') ||
            ', Status=' || NVL(rec.status, 'NoResult')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Students: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Passed: ' || v_pass);
    DBMS_OUTPUT.PUT_LINE('Failed: ' || v_fail);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No such course found for Course ID=' || p_course_id);
END;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE PR_SUSPEND_STUDENTS
IS
BEGIN
  FOR rec IN (
      SELECT student_id
      FROM warnings
      GROUP BY student_id
      HAVING COUNT(*) >= 3
  ) LOOP

      INSERT INTO audittrail (id, table_name, operation, old_data, new_data, log_date)
      VALUES (
          AUDITTRAIL_SEQ.NEXTVAL,
          'STUDENTS',
          'UPDATE',
          'student_id=' || rec.student_id || ', academic_status=Active',
          'student_id=' || rec.student_id || ', academic_status=Suspended',
          SYSTIMESTAMP
      );

      UPDATE students
      SET academic_status = 'Suspended'
      WHERE id = rec.student_id;

  END LOOP;

  COMMIT;
END;
/
SHOW ERRORS;
