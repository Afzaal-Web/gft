-- ==================================================================================================
-- Procedure:   getAuth
-- Purpose:     get the json of auth with queried rec id
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getAuth;

DELIMITER $$

CREATE PROCEDURE getAuth(
    IN pjReqObj JSON,
    INOUT pjRespObj JSON
)
BEGIN

    DECLARE v_account_num VARCHAR(50);
    DECLARE v_customer_rec_id INT DEFAULT NULL;
    DECLARE v_auth_json JSON;

    main_block: BEGIN

        -- Extract Account Number
        SET v_account_num = getJval(pjReqObj, 'jData.P_ACCOUNT_NUM');

        -- Validate Account Number
        IF v_account_num IS NULL OR TRIM(v_account_num) = '' THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Missing Account Number');

            LEAVE main_block;

        END IF;

        -- Find Customer
        SELECT customer_rec_id
        INTO v_customer_rec_id
        FROM customer
        WHERE account_num = v_account_num
        LIMIT 1;

        -- Check Customer Exists
        IF v_customer_rec_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 2);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',
                CONCAT('Customer does not exist for account number: ', v_account_num));

            LEAVE main_block;

        END IF;

        -- Fetch Auth JSON
        SET v_auth_json = NULL;

        SELECT auth_json
        INTO v_auth_json
        FROM auth
        WHERE parent_table_rec_id = v_customer_rec_id
        LIMIT 1;

        -- Check Auth Record
        IF v_auth_json IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 2);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',
                CONCAT('Auth record does not exist for account number: ', v_account_num));

        ELSE

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',
                CONCAT('Auth Record found for account number: ', v_account_num));

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents', v_auth_json);

        END IF;

    END main_block;

END $$

DELIMITER ;
