
-- Stored Procedures for Slowly Changing Dimensions (SCD)

-- SCD Type 0: No change allowed (static data)
DELIMITER //
CREATE PROCEDURE scd_type_0(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    IF EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key AND name != new_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attempt to change a Type 0 field';
    END IF;
END;
//
DELIMITER ;

-- SCD Type 1: Overwrite the old data
DELIMITER //
CREATE PROCEDURE scd_type_1(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    IF EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key) THEN
        UPDATE dimension_table SET name = new_name WHERE id = new_key;
    ELSE
        INSERT INTO dimension_table(id, name) VALUES (new_key, new_name);
    END IF;
END;
//
DELIMITER ;

-- SCD Type 2: Keep full history with new rows
DELIMITER //
CREATE PROCEDURE scd_type_2(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    DECLARE current_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    UPDATE dimension_table SET end_date = current_time WHERE id = new_key AND end_date IS NULL;

    INSERT INTO dimension_table(id, name, start_date, end_date) VALUES (new_key, new_name, current_time, NULL);
END;
//
DELIMITER ;

-- SCD Type 3: Store previous value in additional column
DELIMITER //
CREATE PROCEDURE scd_type_3(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    IF EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key) THEN
        UPDATE dimension_table SET previous_name = name, name = new_name WHERE id = new_key;
    ELSE
        INSERT INTO dimension_table(id, name, previous_name) VALUES (new_key, new_name, NULL);
    END IF;
END;
//
DELIMITER ;

-- SCD Type 4: Historical table for old records
DELIMITER //
CREATE PROCEDURE scd_type_4(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    IF EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key AND name != new_name) THEN
        INSERT INTO dimension_history(id, name, change_date) 
        SELECT id, name, CURRENT_TIMESTAMP FROM dimension_table WHERE id = new_key;

        UPDATE dimension_table SET name = new_name WHERE id = new_key;
    ELSEIF NOT EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key) THEN
        INSERT INTO dimension_table(id, name) VALUES (new_key, new_name);
    END IF;
END;
//
DELIMITER ;

-- SCD Type 6: Combine Type 1 + 2 + 3
DELIMITER //
CREATE PROCEDURE scd_type_6(IN new_key INT, IN new_name VARCHAR(100))
BEGIN
    DECLARE current_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

    IF EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key AND name != new_name AND end_date IS NULL) THEN
        UPDATE dimension_table SET end_date = current_time WHERE id = new_key AND end_date IS NULL;

        INSERT INTO dimension_table(id, name, previous_name, start_date, end_date) 
        VALUES (new_key, new_name, (SELECT name FROM dimension_table WHERE id = new_key AND end_date = current_time), current_time, NULL);
    ELSEIF NOT EXISTS (SELECT 1 FROM dimension_table WHERE id = new_key) THEN
        INSERT INTO dimension_table(id, name, previous_name, start_date, end_date) 
        VALUES (new_key, new_name, NULL, current_time, NULL);
    END IF;
END;
//
DELIMITER ;
