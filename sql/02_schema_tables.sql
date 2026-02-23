-- 02_schema_tables.sql
-- Run as USER1

-- Best-effort drop tables for reruns
BEGIN EXECUTE IMMEDIATE 'DROP TABLE DBUserCreationLog CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Warnings CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE AuditTrail CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ExamResults CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Exams CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Register CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Students CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Courses CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Professors CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE Professors (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    department VARCHAR2(100) NOT NULL
);

CREATE TABLE Courses (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    professor_id NUMBER NOT NULL,
    credit_hours NUMBER CHECK (credit_hours > 0),
    prerequisite_course_id NUMBER,
    CONSTRAINT fk_course_professor
        FOREIGN KEY (professor_id) REFERENCES Professors(id),
    CONSTRAINT fk_course_prerequisite
        FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(id)
);

CREATE TABLE Students (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    academic_status VARCHAR2(20)
        CHECK (academic_status IN ('Active','Suspended')),
    total_credits NUMBER DEFAULT 0 CHECK (total_credits >= 0)
);

CREATE TABLE Register (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    course_id NUMBER NOT NULL,
    CONSTRAINT fk_register_student
        FOREIGN KEY (student_id) REFERENCES Students(id),
    CONSTRAINT fk_register_course
        FOREIGN KEY (course_id) REFERENCES Courses(id),
    CONSTRAINT uq_student_course
        UNIQUE (student_id, course_id)
);

CREATE TABLE Exams (
    id NUMBER PRIMARY KEY,
    course_id NUMBER NOT NULL,
    exam_date DATE NOT NULL,
    exam_type VARCHAR2(20)
        CHECK (exam_type IN ('Midterm','Final')),
    CONSTRAINT fk_exam_course
        FOREIGN KEY (course_id) REFERENCES Courses(id)
);

CREATE TABLE ExamResults (
    id NUMBER PRIMARY KEY,
    registration_id NUMBER NOT NULL,
    score NUMBER CHECK (score BETWEEN 0 AND 100),
    grade VARCHAR2(2),
    status VARCHAR2(10)
        CHECK (status IN ('Pass','Fail')),
    CONSTRAINT fk_examresults_registration
        FOREIGN KEY (registration_id) REFERENCES Register(id)
);

CREATE TABLE AuditTrail (
    id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50),
    operation VARCHAR2(20),
    old_data CLOB,
    new_data CLOB,
    log_date TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE Warnings (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    warning_reason VARCHAR2(200),
    warning_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_warning_student
        FOREIGN KEY (student_id) REFERENCES Students(id)
);

CREATE TABLE DBUserCreationLog (
    id NUMBER PRIMARY KEY,
    username VARCHAR2(50),
    created_by VARCHAR2(50),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);
