DROP PROCEDURE IF EXISTS getAuth;

DELIMITER $$

CREATE PROCEDURE getAuth(
						  IN  pReqObj JSON,
						  OUT pResObj JSON
						)
BEGIN

	DECLARE v_customer_rec_id 	INT;
    DECLARE v_auth_json       	JSON;
    
	-- =========================
    -- Extract Customer ID
    -- =========================
    SET v_customer_rec_id = getJval(pReqObj, 'P_CUSTOMER_REC_ID');
    
    main_block: BEGIN
    
			-- Validation
		IF v_customer_rec_id IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Missing customer_rec_id'
			);
			LEAVE main_block;
		END IF;
		
		
		-- Fetch auth JSON
		SELECT  auth_json
		INTO 	v_auth_json
		FROM auth
		WHERE parent_table_rec_id = v_customer_rec_id
		LIMIT 1;

		-- If not found
		IF p_auth_json IS NULL THEN
			SET pResObj  = JSON_OBJECT(
										'status',			'error',
										'message', 			'Customer does not exist',
										'customer_rec_id',	 v_customer_rec_id
									);
		ELSE
			SET pResObj = JSON_OBJECT(
										'status', 'success',
										'data', v_auth_json
									);
		END IF;
	
    END main_block;
    
    -- logging

END $$

DELIMITER ;
