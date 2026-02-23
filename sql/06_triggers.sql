-- 06_triggers.sql
-- Run as USER1

CREATE OR REPLACE TRIGGER TRG_CHECK_PREREQ
BEFORE INSERT ON REGISTER
FOR EACH ROW
DECLARE
    v_prereq_id  COURSES.PREREQUISITE_COURSE_ID%TYPE;
    v_count      NUMBER;
BEGIN
    SELECT prerequisite_course_id
    INTO v_prereq_id
    FROM courses
    WHERE id = :NEW.course_id;

    IF v_prereq_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM register r
        JOIN examresults er
          ON er.registration_id = r.id
        WHERE r.student_id = :NEW.student_id
          AND r.course_id  = v_prereq_id
          AND er.status    = 'Pass';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Registration blocked: prerequisite course not completed.'
            );
        END IF;
    END IF;
END;
/
SHOW ERRORS;

CREATE OR REPLACE TRIGGER TRG_REGISTER_AUDIT_INS
BEFORE INSERT ON REGISTER
FOR EACH ROW
BEGIN
    INSERT INTO audittrail (id, table_name, operation, old_data, new_data, log_date)
    VALUES (
        AUDITTRAIL_SEQ.NEXTVAL,
        'REGISTER',
        'INSERT',
        NULL,
        TO_CLOB('id=' || :NEW.id || '; student_id=' || :NEW.student_id || '; course_id=' || :NEW.course_id),
        SYSTIMESTAMP
    );
END;
/
SHOW ERRORS;

CREATE OR REPLACE TRIGGER TRG_REGISTER_AUDIT_DEL
BEFORE DELETE ON REGISTER
FOR EACH ROW
BEGIN
    INSERT INTO audittrail (id, table_name, operation, old_data, new_data, log_date)
    VALUES (
        AUDITTRAIL_SEQ.NEXTVAL,
        'REGISTER',
        'DELETE',
        TO_CLOB('id=' || :OLD.id || '; student_id=' || :OLD.student_id || '; course_id=' || :OLD.course_id),
        NULL,
        SYSTIMESTAMP
    );
END;
/
SHOW ERRORS;

-- Quick check
SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name IN ('TRG_CHECK_PREREQ','TRG_REGISTER_AUDIT_INS','TRG_REGISTER_AUDIT_DEL');
