-- Basic Stored Procedure Structure

DELIMITER $$

CREATE PROCEDURE sp_sample()
BEGIN
SELECT 'helo gft app';
END $$
DELIMITER ;

-- call
CALL sp_sample();

-- Stored Procedure with PARAMETERS
-- The IN parameter is the default parameter and is used to receive the input value from the calling program.
DELIMITER $$
CREATE PROCEDURE sp_get_user(IN p_user_id INT)
BEGIN
SELECT * FROM auth WHERE auth_rec_id = p_user_id;
END $$
DELIMITER ;

-- call
CALL sp_get_user(0);

-- OUT Parameter
-- The OUT parameter is used to send the output values to the calling program.
DELIMITER $$
CREATE PROCEDURE sp__user_count(OUT p_count INT)
BEGIN
SELECT COUNT(*) INTO p_count FROM auth;
END $$
DELIMITER ;

-- call
CALL sp__user_count(@total);
SELECT @total;

-- INOUT Parameter
-- The INOUT parameter is the combination of IN and OUT parameter and is used to pass and receive data from the stored procedure in a single parameter.
DELIMITER $$
CREATE PROCEDURE sp_increment(INOUT p_value INT)
BEGIN
SET p_value = p_value + 1;
END $$
DELIMITER ;

-- call
SET @num = 5;
CALL sp_increment(@num);
SELECT @num;

-- VARIABLES inside Stored Procedure
DELIMITER $$
CREATE PROCEDURE sp_variables()
BEGIN
		DECLARE v_total INT DEFAULT 0;
        DECLARE v_name VARCHAR(50);
        
        SET v_total = 100;
        SET v_name = 'GFT';
        
        SELECT v_total, v_name;
END $$
DELIMITER ;

-- call
CALL sp_variables();

-- IF – ELSE
DELIMITER $$
CREATE PROCEDURE sp_check_balnce(IN p_balance INT)
BEGIN
		IF p_balance < 0
        THEN 
        SELECT 'negative balance';
        ELSEIF p_balance = 0
        THEN
        SELECT 'ZERO balance';
        ELSE
        SELECT 'positive balance';
        END IF;
END $$
DELIMITER ;

-- call
CALL sp_check_balnce(21);

-- CASE Statement
DELIMITER $$
CREATE PROCEDURE sp_user_status(IN p_status CHAR(1))
BEGIN
		CASE p_status
        WHEN 'A' THEN SELECT 'Active';
        WHEN 'I' THEN SELECT 'InActive';
        ELSE SELECT 'Unknown';
        END CASE;
END $$
DELIMITER ;

-- call
CALL sp_user_status('I');

-- LOOPS (ALL TYPES)
DELIMITER $$
CREATE PROCEDURE sp_while_loop()
BEGIN
		DECLARE i INT DEFAULT 1;
        CREATE TABLE while_loop_table (
        id INT
        );
        WHILE i <= 5
        DO 
        INSERT INTO while_loop_table (id) VALUES(i);
        SET i = i + 1;
        END WHILE;
        
        SELECT * FROM while_loop_table;
END $$
DELIMITER ;

DROP PROCEDURE sp_while_loop;
-- call
CALL sp_while_loop();


-- REPEAT LOOP (Runs at least once)
DELIMITER $$
CREATE PROCEDURE sp_repeat_loop()
BEGIN
		DECLARE i INT DEFAULT 1;
        CREATE TABLE repeat_loop_table (
        id INT
        );
        REPEAT
        INSERT INTO repeat_loop_table (id) VALUES(i);
        SET i = i + 1;
        UNTIL i > 5
        END REPEAT;
        
        SELECT * FROM repeat_loop_table;
END $$
DELIMITER ;

DROP PROCEDURE sp_repeat_loop;
-- call
CALL sp_repeat_loop();

-- LOOP with LEAVE

DELIMITER $$
CREATE PROCEDURE sp_loop_leave()
BEGIN
		DECLARE i INT DEFAULT 1;
        CREATE TABLE loop_leave_table (
        id INT
        );
        myLoop: LOOP
        IF i < 5
        THEN
        INSERT INTO loop_leave_table (id) VALUES(i);
        SET i = i + 1;
        ELSE
        LEAVE myLoop;
        END IF;
        END LOOP;
        
        SELECT * FROM loop_leave_table;
END $$
DELIMITER ;

DROP PROCEDURE sp_loop_leave;
-- call
CALL sp_loop_leave();

-- CURSOR (Row by Row Processing)

-- A MySQL cursor is a pointer that is used to iterate through a table's records.
-- four operations in cursor

	-- Declare Cursor
    -- Open Cursor
    -- Fetch Cursor
    -- Close Cursor
-- The DECLARE statement is used to declare a cursor in a MySQL. Once declared, it is then associated with a SELECT statement to retrieve the records from a table.
-- == DECLARE cursor_name CURSOR FOR select * from auth;  ==
-- The OPEN statement is used to initialize the cursor to retrieve the data after it has been declared.
-- = open cursor_name; =
-- The FETCH statement is then used to retrieve the record pointed by the cursor. Once retrieved, the cursor moves to the next record.
-- = FETCH cursor_name INTO variable_list;=
-- The CLOSE statement is used to release the memory associated with the cursor after all the records have been retrieved.
-- =CLOSE cursor_name; =

CREATE TABLE CUSTOMERS (
   ID INT NOT NULL,
   NAME VARCHAR (20) NOT NULL,
   AGE INT NOT NULL,
   ADDRESS CHAR (25),
   SALARY DECIMAL (18, 2),
   PRIMARY KEY (ID)
);

CREATE TABLE BACKUP (
   ID INT NOT NULL,
   NAME VARCHAR (20) NOT NULL,
   AGE INT NOT NULL,
   ADDRESS CHAR (25),
   SALARY DECIMAL (18, 2)
);

INSERT INTO CUSTOMERS VALUES 
(1, 'Ramesh', 32, 'Ahmedabad', 2000.00 ),
(2, 'Khilan', 25, 'Delhi', 1500.00 ),
(3, 'Kaushik', 23, 'Kota', 2000.00 ),
(4, 'Chaitali', 25, 'Mumbai', 6500.00 ),
(5, 'Hardik', 27, 'Bhopal', 8500.00 ),
(6, 'Komal', 22, 'Hyderabad', 4500.00 ),
(7, 'Muffy', 24, 'Indore', 10000.00 );

DELIMITER $$
CREATE PROCEDURE example_cur()
BEGIN
		DECLARE done INT DEFAULT 0;
        DECLARE cusT_id, cust_age INT;
        DECLARE cust_name VARCHAR(20);
		DECLARE cust_address CHAR(25);
		DECLARE cust_salary DECIMAL(18,2);
        
        DECLARE curr CURSOR FOR SELECT * FROM customers;
        
        -- Handler for no more records
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
        OPEN curr;
        
        myLoop: LOOP
        FETCH curr INTO cust_id, cust_name, cust_age, cust_address, cust_salary;
        INSERT INTO backup VALUES(cust_id, cust_name, cust_age, cust_address, cust_salary);
        IF done = 1
        THEN 
        LEAVE myLoop;
        END IF;
        END LOOP;
        
        CLOSE curr;
END $$
DELIMITER ;

CALL example_cur();

-- CURSOR (Row by Row Processing)
DELIMITER $$
CREATE PROCEDURE example_cur2()
BEGIN
		DECLARE done INT DEFAULT 0;
		DECLARE v_name VARCHAR(100);
        
        DECLARE curr_table_name CURSOR FOR SELECT parent_table_name FROM auth;
        
        -- Handler for no more records
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
        OPEN curr_table_name;
        
        myLoop: LOOP
        FETCH curr_table_name INTO v_name;
        IF done = 1
        THEN 
        LEAVE myLoop;
        END IF;
        UPDATE logs
        SET logged_by = v_name
        WHERE log_rec_id = 0;
        END LOOP;
        
        CLOSE curr_table_name;
END $$
DELIMITER ;

DROP PROCEDURE example_cur2;
CALL example_cur2();

-- TRANSACTIONS (CRITICAL FOR APP LOGIC)

DELIMITER $$
CREATE PROCEDURE sp_transfer_money(
    IN p_from INT,
    IN p_to INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction failed';
    END;

    START TRANSACTION;

    UPDATE accounts SET balance = balance - p_amount WHERE acc_id = p_from;
    UPDATE accounts SET balance = balance + p_amount WHERE acc_id = p_to;

    COMMIT;
END $$
DELIMITER ;

-- ERROR HANDLING (TRY / CATCH)
CREATE PROCEDURE sp_error_handling()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred';
    END;

    INSERT INTO users(user_id) VALUES (1); -- may fail
END;

-- SIGNAL (Custom Error Messages)
CREATE PROCEDURE sp_validate_age(IN p_age INT)
BEGIN
    IF p_age < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Age must be 18 or above';
    END IF;
END;

-- DYNAMIC SQL (Very Powerful)
DELIMITER $$
CREATE PROCEDURE sp_dynamic_table(IN p_table VARCHAR(50))
BEGIN
	SET @sqlstmt = CONCAT('SELECT * FROM ', p_table);
    PREPARE stmt FROM @sqlstmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

CALL sp_dynamic_table('logs');

-- JSON Handling (For Modern Apps)
DELIMITER $$
CREATE PROCEDURE sp_json_read(IN p_json JSON)
BEGIN
    SELECT
        JSON_VALUE(p_json, '$.user.name') AS name,
        JSON_VALUE(p_json, '$.user.age') AS age;
END $$
DELIMITER ;

-- Common GFT App Pattern (LOGGING SP)
DELIMITER $$
CREATE PROCEDURE sp_log_event(
    IN p_user VARCHAR(50),
    IN p_action VARCHAR(100),
    IN p_data JSON
)
BEGIN
    INSERT INTO app_logs
    (
        username,
        action,
        payload,
        created_at
    )
    VALUES
    (
        p_user,
        p_action,
        p_data,
        NOW()
    );
END $$
DELIMITER ;

-- customer json initialize

DELIMITER $$

CREATE PROCEDURE initialize_customer_json(
		OUT new_customer_id INT
)
BEGIN
    -- Insert a new row with full JSON skeleton and all null/default values
    INSERT INTO customer
    SET
        customer_json   = 	JSON_OBJECT(
            'customer_rec_id', 					NULL,
            'customer_status', 					NULL,
            'customer_type', 					NULL,
            'corporate_account_rec_id', 		NULL,

            'first_name', 						NULL,
            'last_name',  						NULL,
            'national_id', 						NULL,
            'email', 							NULL,
            'phone', 							NULL,
            'whatsapp_number', 					NULL,
            
			'main_account_num',          		NULL,
			'account_num',           			NULL,
			'account_title',              		NULL,
			'designation',                		NULL,
			'cus_profile_pic', 					NULL,

            'additional_contacts', JSON_ARRAY(
                JSON_OBJECT(
                    'Additional_email_1', 		NULL,
                    'Additional_phone_1', 		NULL
                ),
                JSON_OBJECT(
                    'Additional_email_2', 		NULL,
                    'Additional_phone_2', 		NULL
                )
            ),

            'residential_address', JSON_OBJECT(
                'google_reference_number', 		NULL,
                'full_address', 				Null,
                'country', 						Null,
                'building_number', 				Null,
                'street_name', 					Null,
                'street_address_2', 			Null,
                'city', 						Null,
                'state', 						Null,
                'zip_code', 					Null,
                'directions', 					Null,
                'cross_street_1_name', 			Null,
                'cross_street_2_name', 			Null,
                'latitude', 					Null,
                'longitude', 					Null
            ),
            'permissions', JSON_OBJECT(
                'is_buy_allowed', 				false,
                'is_sell_allowed', 				false,
                'is_redeem_allowed', 			false,
                'is_add_funds_allowed', 		false,
                'is_withdrawl_allowed', 		false
            ),

            'app_preferences', JSON_OBJECT(
                'time_zone', 					NULL,
                'preferred_currency',			NULL,
                'preferred_language', 			NULL,
                'auto_logout_minutes', 			NULL,
                'remember_me_enabled', 			false,
                'default_home_location', 		NULL,
                'biometric_login_enabled', 		false,
                'push_notifications_enabled', 	false,
                'transaction_alerts_enabled', 	false,
                'email_notifications_enabled', 	false
            )
        ),

        row_metadata 	= 	JSON_OBJECT(
            'created_at', 		NOW(3),
            'created_by', 		'registration_api',
            'updated_at', 		NOW(3),
            'updated_by', 		'registration_api',
            'status', 			'registration_request'
        );
        
        SET new_customer_id = LAST_INSERT_ID();
END$$

DELIMITER ;



-- CREATE customer
DELIMITER $$

CREATE PROCEDURE create_customer(
    IN pjReqObj JSON,
    OUT psResult VARCHAR(255)
)
proc_block: BEGIN
        DECLARE v_customer_rec_id INT;
        DECLARE national_id_val VARCHAR(50);
		SET national_id_val = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id'));

    IF EXISTS (
        SELECT 1
        FROM customer
        WHERE national_id = CONVERT(national_id_val USING utf8mb4)
                             COLLATE utf8mb4_0900_ai_ci
    ) THEN
        SET psResult = 'National ID already exists.';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'National ID already exists.',
                MYSQL_ERRNO = 9999;
    END IF;

    CALL initialize_customer_json(v_customer_rec_id);

    UPDATE customer
    SET
        first_name  = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')),
        last_name   = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name')),
        national_id = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id')),
        customer_json = JSON_SET(
            customer_json,
            '$.customer_rec_id', 								v_customer_rec_id,
            '$.first_name', 									JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')),
            '$.last_name', 										JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name')),
            '$.national_id', 									JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id')),
            '$.email', 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.email')),
            '$.phone', 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.phone')),
            '$.whatsapp_number', 								JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.whatsapp_number')),
            '$.residential_address.google_reference_number', 	JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.google_reference_number')),
            '$.residential_address.full_address', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.full_address')),
            '$.residential_address.country', 					JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.country')),
            '$.residential_address.building_number', 			JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.building_number')),
            '$.residential_address.street_name', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.street_name')),
            '$.residential_address.street_address_2', 			JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.street_address_2')),
            '$.residential_address.city', 						JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.city')),
            '$.residential_address.state', 						JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.state')),
            '$.residential_address.zip_code', 					JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.zip_code')),
            '$.residential_address.directions', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.directions')),
            '$.residential_address.cross_street_1_name', 		JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.cross_street_1_name')),
            '$.residential_address.cross_street_2_name', 		JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.cross_street_2_name')),
            '$.residential_address.latitude', 					JSON_EXTRACT(pjReqObj, 				'$.residential_address.latitude'),
            '$.residential_address.longitude', 					JSON_EXTRACT(pjReqObj, 				'$.residential_address.longitude')
        )
    WHERE customer_rec_id = v_customer_rec_id;
    
    SET psResult 				= 'Your account has been successfully created.
								   To continue, please complete the verification steps below.';

END$$

DELIMITER ;


-- Test Script

SET @pjReqObj = '{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "whatsapp_number": "+1234567890",
  "national_id": "38124544545545",
  "residential_address": {
    "google_reference_number": "ChIJ1234567890",
    "full_address": "123 Main St, Apt 4B, New York, USA",
    "country": "USA",
    "building_number": "123",
    "street_name": "Main St",
    "street_address_2": "Apt 4B",
    "city": "New York",
    "state": "New York",
    "zip_code": "10001",
    "directions": "Near Central Park",
    "cross_street_1_name": "2nd Ave",
    "cross_street_2_name": "3rd Ave",
    "latitude": 40.7128,
    "longitude": -74.006
  }
}';

SET @psResult = '';

CALL create_customer(@pjReqObj, @psResult);

SELECT @psResult AS registration_status;










