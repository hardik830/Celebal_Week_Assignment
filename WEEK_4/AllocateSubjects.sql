
-- Use the database
CREATE DATABASE IF NOT EXISTS mysqltutorial;
USE mysqltutorial;

-- Drop old tables and procedure if they exist
DROP PROCEDURE IF EXISTS AllocateSubjects;
DROP TABLE IF EXISTS Allotments;
DROP TABLE IF EXISTS UnallotedStudents;
DROP TABLE IF EXISTS StudentPreference;
DROP TABLE IF EXISTS SubjectDetails;
DROP TABLE IF EXISTS StudentDetails;

-- Create StudentDetails table
CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA DECIMAL(3, 2),
    Branch VARCHAR(20),
    Section VARCHAR(5)
);

-- Create SubjectDetails table
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(20) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);

-- Create StudentPreference table
CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(20),
    Preference INT,
    PRIMARY KEY (StudentId, Preference),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);

-- Create Allotments table
CREATE TABLE Allotments (
    SubjectId VARCHAR(20),
    StudentId VARCHAR(20),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Create UnallotedStudents table
CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

-- Insert data into StudentDetails
INSERT INTO StudentDetails VALUES
('159103036', 'Mohit Agarwal', 8.9, 'CCE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CCE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CCE', 'B'),
('159103039', 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
('159103040', 'Mehreet Singh', 5.6, 'CCE', 'A'),
('159103041', 'Arjun Tehlan', 9.2, 'CCE', 'B');

-- Insert data into SubjectDetails
INSERT INTO SubjectDetails VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

-- Insert data into StudentPreference
INSERT INTO StudentPreference VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 2),
('159103036', 'PO1493', 3),
('159103036', 'PO1494', 4),
('159103036', 'PO1495', 5),
('159103037', 'PO1493', 1),
('159103037', 'PO1494', 2),
('159103037', 'PO1495', 3),
('159103038', 'PO1491', 1),
('159103038', 'PO1493', 2),
('159103038', 'PO1495', 3),
('159103039', 'PO1494', 1),
('159103039', 'PO1492', 2),
('159103040', 'PO1492', 1),
('159103041', 'PO1491', 1),
('159103041', 'PO1493', 2);

-- Create Procedure
DELIMITER $$

CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_studentId VARCHAR(20);
    DECLARE v_prefSubjectId VARCHAR(20);
    DECLARE v_remainingSeats INT;

    -- Cursor for students ordered by GPA DESC
    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    -- Cursor for preferences (opened dynamically)
    DECLARE pref_cursor CURSOR FOR
        SELECT SubjectId 
        FROM StudentPreference 
        WHERE StudentId = v_studentId 
        ORDER BY Preference ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Temporary table to store current student
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_students (StudentId VARCHAR(20));

    OPEN student_cursor;

    read_students: LOOP
        FETCH student_cursor INTO v_studentId;
        IF done THEN
            LEAVE read_students;
        END IF;

        SET @allocated = FALSE;
        DELETE FROM temp_students;
        INSERT INTO temp_students VALUES (v_studentId);

        SET done = FALSE;
        OPEN pref_cursor;

        read_prefs: LOOP
            FETCH pref_cursor INTO v_prefSubjectId;
            IF done THEN
                LEAVE read_prefs;
            END IF;

            SELECT RemainingSeats INTO v_remainingSeats 
            FROM SubjectDetails 
            WHERE SubjectId = v_prefSubjectId;

            IF v_remainingSeats > 0 THEN
                INSERT INTO Allotments (SubjectId, StudentId) 
                VALUES (v_prefSubjectId, v_studentId);

                UPDATE SubjectDetails 
                SET RemainingSeats = RemainingSeats - 1 
                WHERE SubjectId = v_prefSubjectId;

                SET @allocated = TRUE;
                LEAVE read_prefs;
            END IF;
        END LOOP read_prefs;

        CLOSE pref_cursor;
        SET done = FALSE;

        IF @allocated = FALSE THEN
            INSERT INTO UnallotedStudents (StudentId) VALUES (v_studentId);
        END IF;
    END LOOP read_students;

    CLOSE student_cursor;
END $$

DELIMITER ;

-- Run the procedure
CALL AllocateSubjects();
