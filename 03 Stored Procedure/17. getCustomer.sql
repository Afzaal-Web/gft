-- ==================================================================================================
-- Procedure:   getCustomer
-- Purpose:     get the json of customer with queried rec id
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getCustomer;

DELIMITER $$

CREATE PROCEDURE getCustomer(
							 IN  pjReqObj JSON,
							 INOUT pjRespObj JSON
							)
BEGIN

	DECLARE v_account_num 	    VARCHAR(50);
    DECLARE v_customer_json 	JSON;
    
    SET v_account_num = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');
    
    -- Get customer JSON
    SELECT 	customer_json
    INTO 	v_customer_json
    FROM 	customer
    WHERE   account_num = v_account_num
    LIMIT 1;

    -- If not found
    IF v_customer_json IS NULL THEN
          
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('Customer does not exist', ' for account number: ', v_account_num));
   
    ELSE
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('Customer found', ' for account number: ', v_account_num));
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', v_customer_json);
        
    END IF;

END $$

DELIMITER ;

