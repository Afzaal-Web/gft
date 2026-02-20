DROP PROCEDURE IF EXISTS getCreditCard;

DELIMITER $$

CREATE PROCEDURE getCreditCard(
								IN  pReqObj JSON,
								OUT pResObj JSON
							)
BEGIN

	DECLARE v_mm_rec_id INT;
    DECLARE v_cc_json   JSON;
    
	-- =========================
    -- Extract Money Manager ID
    -- =========================
    SET v_mm_rec_id = getJval(pReqObj, 'P_MM_REC_ID');
    
    main_block: BEGIN
    
		 -- Validation
		IF v_mm_rec_id IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Missing money_manager_rec_id'
			);
			LEAVE main_block;
		END IF;
        
		-- =========================
		-- Response Handling
		-- =========================
		IF v_cc_json IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Record does not exist',
				'money_manager_rec_id', v_mm_rec_id
			);
		ELSE
			SET pResObj = JSON_OBJECT(
				'status', 'success',
				'data', v_cc_json
			);
		END IF;
        
	END main_block;
    
    -- logging
    
END $$

DELIMITER ;
