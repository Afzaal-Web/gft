-- ==================================================================================================
-- Procedure:   getMoneyManager
-- Purpose:     get the json of money manager with queried rec id
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getMoneyManager;

DELIMITER $$

CREATE PROCEDURE getMoneyManager(
								IN  	pjReqObj JSON,
								INOUT 	pjRespObj JSON
							)
BEGIN

	DECLARE v_account_num 	    VARCHAR(50);
	DECLARE v_request_type	 	VARCHAR(50);
    DECLARE v_mm_json   		JSON;
    
	-- =========================
    -- Extract Account Number and Request Type
    -- =========================
    SET v_account_num 	= getJval(pjReqObj, 'jData.P_ACCOUNT_NUM');
	SET v_request_type 	= getJval(pjReqObj, 'jData.P_REQUEST_TYPE');
    
    main_block: BEGIN
    
		-- Validation
		IF v_account_num IS NULL THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Missing Account Number');

			LEAVE main_block;
		END IF;

		IF v_request_type IS NULL THEN

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Missing Request Type');
			
		LEAVE main_block;
		END IF;
        
		-- Fetch money manager JSON
		SELECT  JSON_ARRAYAGG(money_manager_json)
		INTO 	v_mm_json
		FROM 	money_manager
		WHERE 	account_num = v_account_num AND request_type = v_request_type;

		-- =========================
		-- Response Handling
		-- =========================
		IF v_mm_json IS NULL THEN
			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Record does not exist for given account number and request type');
		ELSE
			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('Money Manager record found for account number: ', v_account_num));
        	SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', v_mm_json);
		END IF;

	END main_block;
    
    -- logging
    

END $$

DELIMITER ;

