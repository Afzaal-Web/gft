-- =========================================================
-- Procedure:   verifyAccountNum
-- Purpose:     verify Account Num and return full Name
-- =========================================================

DROP PROCEDURE IF EXISTS verifyAccountNum;

DELIMITER $$

CREATE PROCEDURE verifyAccountNum (
										IN  pReqObj JSON,
										OUT pResObj JSON
									)
BEGIN

	-- Declare variables for input extraction
	DECLARE v_contact_type		VARCHAR(100);
    DECLARE v_account_num		VARCHAR(255);
    
    -- Declare variables to hold database query results
    DECLARE v_account_num_db 	VARCHAR(255);
    DECLARE v_full_name			VARCHAR(255);
    
	-- Handler for NO ROW FOUND
    -- If SELECT INTO returns no row, set error JSON instead of raising an exception
	DECLARE EXIT HANDLER FOR NOT FOUND
		BEGIN
			SET pResObj = JSON_OBJECT(
										'code', 1,
										'status','error',
										'message','Invalid account number or login ID'
									);
		END;

 
    main_block: BEGIN
    
		-- Extract login ID and account number from input JSON
		SET v_contact_type 		= getJval(pReqObj, 'P_LOGIN_ID');
		SET v_account_num 		= getJval(pReqObj, 'P_ACCOUNT_NUM');
		
		-- Validate input: both login ID and account number must be provided
		IF isFalsy(v_contact_type) OR isFalsy(v_account_num) THEN
			SET pResObj = JSON_OBJECT(
										'code', 	1,
										'status',	'error',
										'message',	'Invalid input'
									 );
			LEAVE main_block;
		END IF;
		
		-- Fetch account info from customers table
		SELECT  account_num,		CONCAT(first_name,' ',last_name)
		INTO    v_account_num_db, 	v_full_name
		FROM 	customers
		WHERE 	(LOWER(email) = LOWER(v_contact_type) OR LOWER(phone) = LOWER(v_contact_type) OR LOWER(user_name) = LOWER(v_contact_type))
		AND main_account_num = v_account_num
		LIMIT 	1;
		
		-- If a row is found, return success JSON with full name and account number
		SET pResObj = JSON_OBJECT(
									'code', 0,
									'message', 'success',
									'customer_name', v_full_name,
									'account_num', v_account_num_db
								);
			

    END main_block;

END $$

DELIMITER ;


