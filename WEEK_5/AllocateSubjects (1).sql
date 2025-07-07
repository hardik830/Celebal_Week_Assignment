
-- Stored Procedure: AllocateSubjects
DELIMITER $$
CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_studentId VARCHAR(50);
    DECLARE v_subjectId VARCHAR(50);

    -- Cursor to iterate over SubjectRequest table
    DECLARE cur CURSOR FOR 
        SELECT StudentId, SubjectId FROM SubjectRequest;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_studentId, v_subjectId;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Case 1: Student exists in SubjectAllotments
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = v_studentId) THEN
            -- Get current subject for the student
            IF EXISTS (
                SELECT 1 FROM SubjectAllotments 
                WHERE StudentId = v_studentId AND SubjectId = v_subjectId AND Is_Valid = 1
            ) THEN
                -- Requested subject is already current, do nothing
                ITERATE read_loop;
            ELSE
                -- Invalidate the currently active subject
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentId = v_studentId AND Is_Valid = 1;

                -- Insert new subject as valid
                INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
                VALUES (v_studentId, v_subjectId, 1);
            END IF;
        ELSE
            -- Case 2: Student does not exist in SubjectAllotments
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (v_studentId, v_subjectId, 1);
        END IF;

    END LOOP;

    CLOSE cur;
END $$
DELIMITER ;
