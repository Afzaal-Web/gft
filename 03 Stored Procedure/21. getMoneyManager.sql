DROP PROCEDURE IF EXISTS getMoneyManager;

DELIMITER $$

CREATE PROCEDURE getMoneyManager(
								IN  pReqObj JSON,
								OUT pResObj JSON
							)
BEGIN

	DECLARE v_mm_rec_id 		INT;
    DECLARE v_mm_json   		JSON;
    
	-- =========================
    -- Extract Money Manager ID
    -- =========================
    SET v_mm_rec_id = getJval(pReqObj, 'P_MM_REC_ID');
    
    main_block: BEGIN
    
		-- Validation
		IF v_mm_rec_id IS NULL THEN
			SET pResObj = JSON_OBJECT(
										'status', 	'error',
										'message', 	'Missing money_manager_rec_id'
									);
			LEAVE main_block;
		END IF;
        
		-- Fetch money manager JSON
		SELECT  money_manager_json
		INTO 	v_mm_json
		FROM 	money_manager
		WHERE 	money_manager_rec_id = v_mm_rec_id
		LIMIT 1;

		-- =========================
		-- Response Handling
		-- =========================
		IF v_mm_json IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Record does not exist',
				'money_manager_rec_id', v_mm_rec_id
			);
		ELSE
			SET pResObj = JSON_OBJECT(
				'status', 'success',
				'data', v_mm_json
			);
		END IF;

	END main_block;
    
    -- logging
    

END $$

DELIMITER ;
