-- ==================================================================================================
-- Procedure:   getCreditCard
-- Purpose:     get the json of credit card with queried rec id
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getCreditCard;

DELIMITER $$

CREATE PROCEDURE getCreditCard(
								IN  	pReqObj JSON,
								INOUT 	pjRespObj JSON
							)
BEGIN

	DECLARE v_cc_rec_id 	INT;
    
	DECLARE v_account_num 	    	VARCHAR(50);
	DECLARE v_cc_json   			JSON;
    
	-- =========================
    -- Extract Account Number
    -- =========================

    SET v_account_num 		= getJval(pReqObj, 'P_ACCOUNT_NUM');
    
    main_block: BEGIN
    
		 -- Validation
		IF v_account_num IS NULL THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Missing Account Number');

			LEAVE main_block;
		END IF;

		-- =========================
        -- Fetch ALL credit cards
        -- =========================

        SELECT  JSON_ARRAYAGG(credit_card_json)
        INTO 	v_cc_json
        FROM 	credit_card
        WHERE 	account_num = v_account_num;
        
		-- =========================
		-- Response Handling
		-- =========================
		IF v_cc_json IS NULL THEN
			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Record does not exist for given account number');
		ELSE
			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('Credit Card record found for account number: ', v_account_num));
        	SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', v_cc_json);
		END IF;
        
	END main_block;
    
    -- logging
    
END $$

DELIMITER ;
