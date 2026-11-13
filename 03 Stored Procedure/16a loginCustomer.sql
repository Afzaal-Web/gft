
-- ==================================================================================================
-- Procedure:   loginCustomer
-- Purpose:     Validate login credentials and return success/failure
-- ==================================================================================================

DROP PROCEDURE IF EXISTS loginCustomer;

DELIMITER $$

CREATE PROCEDURE loginCustomer(
                                IN    pjReqObj  JSON,
                                INOUT pjRespObj JSON
                              )
BEGIN
    DECLARE v_input             VARCHAR(255);
    DECLARE v_password          VARCHAR(255);

    DECLARE v_login_id          VARCHAR(255);
    DECLARE v_db_password       VARCHAR(255);

    DECLARE v_input_type        ENUM('user_name','email','phone');

    DECLARE v_err_msg           TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1
            v_err_msg = MESSAGE_TEXT;

        SET pjRespObj = buildJSONSmart(
            pjRespObj, 'jHeader.responseCode', 1
        );

        SET pjRespObj = buildJSONSmart(
            pjRespObj, 'jHeader.message',
            CONCAT('Unexpected Error - ', v_err_msg)
        );
    END;

    main_block: BEGIN

        -- =========================
        -- Extract login credentials
        -- =========================

        SET v_input         = getJval(pjReqObj, 'jData.P_LOGIN_ID');
        SET v_password      = getJval(pjReqObj, 'jData.P_PASSWORD');

        -- =========================
        -- Validate input
        -- =========================

        IF NULLIF(TRIM(v_input), '') IS NULL OR NULLIF(v_password, '') IS NULL
        THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message','Login ID and Password are required.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Detect input type
        -- =========================

        IF v_input LIKE '%@%' THEN

            SET v_input_type = 'email';

        ELSEIF v_input REGEXP '^[0-9][0-9 ()+-]+$' THEN

            SET v_input_type = 'phone';

        ELSE

            SET v_input_type = 'user_name';

        END IF;

        -- =========================
        -- Find customer account
        -- =========================

        SELECT  c.user_name,  getJval( a.auth_json, 'login_credentials.password')
        INTO    v_login_id,   v_db_password
        FROM auth a
        JOIN customer c ON a.parent_table_rec_id = c.customer_rec_id
        WHERE
            (v_input_type = 'user_name' AND c.user_name = v_input)
            OR
            (v_input_type = 'email' AND c.email = v_input)
            OR
            (v_input_type = 'phone' AND c.phone = v_input)
        LIMIT 1;

        -- =========================
        -- Customer not found
        -- =========================

        IF v_login_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message','USER_NOT_FOUND - No account matches the provided login ID.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Validate password
        -- =========================

        IF v_db_password IS NULL
           OR NOT (SHA2(v_password, 256) <=> v_db_password) THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message','INVALID_PASSWORD - The password is incorrect.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Credentials validated
        -- =========================

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message','LOGIN_CREDENTIALS_VALID - Credentials verified successfully.');

    END main_block;

    -- Logging here

END $$

DELIMITER ;
