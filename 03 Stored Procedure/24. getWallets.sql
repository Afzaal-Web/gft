-- ==================================================================================================
-- Procedure:   getWallets
-- Purpose:     Retrieve all wallets from customer_json stored in the 'customer' table
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getWallets;
DELIMITER $$

CREATE PROCEDURE getWallets (
								IN     pjReqObj   JSON,
								INOUT  pjRespObj  JSON
							)
BEGIN

    DECLARE v_account_num 	     VARCHAR(50);
    DECLARE v_customer_json   	 JSON;
    DECLARE v_wallets_json    	 JSON;

    main_block: BEGIN

        -- Extract customer_Account_Number from request
        SET v_account_num    = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');

        -- Fetch customer JSON
        CALL getCustomer(pjReqObj, pjRespObj);
        
        SET v_customer_json = getJval(pjRespObj, 'jData.contents');

        -- If customer not found
        IF v_customer_json IS NULL THEN

            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('Customer does not exist ', v_account_num));

            LEAVE main_block;
        END IF;

        -- Extract wallets array from customer JSON
        SET v_wallets_json = getJval(v_customer_json, 'customer_wallets');

        -- If wallets key does not exist, return empty array
        IF v_wallets_json IS NULL THEN
			SET v_wallets_json = JSON_OBJECT(
											'Gold', 	 0,
											'Silver', 	 0,
											'Platinum',  0,
											'Cash', 	 0
										);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message',      CONCAT('Customer wallets not found for account number ', v_account_num));
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents',       v_wallets_json);

            LEAVE main_block;
		END IF;

        -- Build response

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode',   0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',        'Wallets retrieved successfully');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents',         v_wallets_json);

    END main_block;
    
    -- logging

END $$

DELIMITER ;

