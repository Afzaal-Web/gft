
-- ==================================================================================================
-- Procedure:  generateUserAuthToken
-- Purpose:    Generate a secure user authentication token and update
--             the customer's current session in the auth table.
-- Functions used:
--             getJval()
--             buildJSONSmart()
-- Session Duration: 24 Hours
-- ==================================================================================================

DROP PROCEDURE IF EXISTS generateUserAuthToken;

DELIMITER $$

CREATE PROCEDURE `generateUserAuthToken`(
                                      IN      pjReqObj      JSON,
                                      INOUT   pjRespObj     JSON
                                    )
BEGIN

    -- =========================
    -- Variable Declarations
    -- =========================
    DECLARE v_customer_rec_id           INT;
    DECLARE v_auth_rec_id               INT DEFAULT NULL;

    DECLARE v_user_auth_token           VARCHAR(64);
    DECLARE v_user_auth_token_hash      CHAR(64);
    DECLARE v_user_session_id           VARCHAR(36);

    DECLARE v_login_at                  DATETIME;
    DECLARE v_session_expires_at        DATETIME;

    DECLARE v_auth_json                 JSON;
    DECLARE v_err_msg                   TEXT;

    -- =========================
    -- Error Handler
    -- =========================
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));

    END;

    main_block: BEGIN

        -- =========================
        -- Extract Request Values
        -- =========================
        SET v_customer_rec_id = getJval(pjReqObj, 'jData.P_CUSTOMER_REC_ID');

        -- =========================
        -- Validate Customer ID
        -- =========================
        IF v_customer_rec_id IS NULL OR v_customer_rec_id <= 0 THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Valid customer_rec_id is required.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Verify Customer Exists
        -- =========================
        IF NOT EXISTS (
            SELECT 1
            FROM   customer
            WHERE  customer_rec_id = v_customer_rec_id
        ) THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer record not found.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Get Auth Record
        -- =========================
        SELECT  auth_rec_id,    auth_json
        INTO    v_auth_rec_id,  v_auth_json
        FROM    auth
        WHERE   parent_table_name     = 'customer'
        AND     parent_table_rec_id   = v_customer_rec_id
        ORDER BY auth_rec_id DESC
        LIMIT   1;

        -- =========================
        -- Validate Auth Record
        -- =========================
        IF v_auth_rec_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Auth record not found for customer.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Generate Secure Token
        -- =========================
        SET v_user_auth_token       = LOWER(HEX(RANDOM_BYTES(32)));
        SET v_user_auth_token_hash  = SHA2(v_user_auth_token, 256);

        -- =========================
        -- Generate Session Details
        -- =========================
        SET v_user_session_id       = UUID();
        SET v_login_at              = UTC_TIMESTAMP();
        SET v_session_expires_at    = DATE_ADD(v_login_at, INTERVAL 24 HOUR);

        -- =========================
        -- Update Auth JSON
        -- =========================
        SET v_auth_json = IFNULL(v_auth_json, JSON_OBJECT());

        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.user_auth_token',     v_user_auth_token_hash);
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.user_session_id',     v_user_session_id);
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.session_status',      'ACTIVE');
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.last_login_at',       DATE_FORMAT(v_login_at, '%Y-%m-%d %H:%i:%s'));
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.session_expires_at',  DATE_FORMAT(v_session_expires_at, '%Y-%m-%d %H:%i:%s'));

        -- =========================
        -- Save Updated Auth JSON
        -- =========================
        UPDATE  auth
        SET     auth_json             = v_auth_json
        WHERE   auth_rec_id           = v_auth_rec_id
        AND     parent_table_name     = 'customer'
        AND     parent_table_rec_id   = v_customer_rec_id;

        -- =========================
        -- Build Success Response
        -- =========================
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'User authentication token generated successfully.');

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_auth_token',    v_user_auth_token);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_session_id',    v_user_session_id);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.session_expires_at', DATE_FORMAT(v_session_expires_at, '%Y-%m-%d %H:%i:%s'));

    END main_block;

END$$

DELIMITER ;
