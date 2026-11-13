
-- ==================================================================================================
-- Procedure:  validateUserAuthToken
-- Purpose:    Validate the user authentication token before executing protected DB actions.
-- Functions used:
--             getJval()
--             buildJSONSmart()
-- ==================================================================================================

DROP PROCEDURE IF EXISTS validateUserAuthToken;

DELIMITER $$

CREATE PROCEDURE `validateUserAuthToken`(
                                         IN      pjReqObj      JSON,
                                        INOUT   pjRespObj     JSON
                                        )
BEGIN

    -- =========================
    -- Variable Declarations
    -- =========================
    DECLARE v_user_auth_token          VARCHAR(255);
    DECLARE v_user_auth_token_hash     CHAR(64);

    DECLARE v_customer_rec_id          INT DEFAULT NULL;
    DECLARE v_auth_rec_id              INT DEFAULT NULL;

    DECLARE v_err_msg                  TEXT;

    -- =========================
    -- Error Handler
    -- =========================
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.is_valid', 0);

    END;

    main_block: BEGIN

        -- =========================
        -- Extract Request Values
        -- =========================
        SET v_user_auth_token = getJval(pjReqObj, 'jData.P_USER_AUTH_TOKEN');

        -- =========================
        -- Validate Token
        -- =========================
        IF v_user_auth_token IS NULL OR v_user_auth_token = '' THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'User authentication token is required.');
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.is_valid', 0);

            LEAVE main_block;
        END IF;

        -- =========================
        -- Validate Token Format
        -- =========================
        IF CHAR_LENGTH(v_user_auth_token) <> 64
           OR NOT REGEXP_LIKE(v_user_auth_token, '^[0-9a-f]{64}$', 'c') THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid user authentication token.');
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.is_valid', 0);

            LEAVE main_block;
        END IF;

        -- =========================
        -- Generate Token Hash
        -- =========================
        SET v_user_auth_token_hash = SHA2(v_user_auth_token, 256);

        -- =========================
        -- Validate Token Against Auth Table
        -- =========================
        SELECT  a.auth_rec_id,             a.parent_table_rec_id
        INTO    v_auth_rec_id,             v_customer_rec_id
        FROM    auth a
        JOIN    customer c ON c.customer_rec_id = a.parent_table_rec_id
        WHERE   a.parent_table_name     = 'customer'
        AND     getJval(a.auth_json, 'current_session.user_auth_token') = v_user_auth_token_hash
        AND     BINARY getJval(a.auth_json, 'current_session.session_status') = BINARY 'ACTIVE'
        AND     STR_TO_DATE(
                    getJval(a.auth_json, 'current_session.session_expires_at'),
                    '%Y-%m-%d %H:%i:%s'
                ) > UTC_TIMESTAMP()
        LIMIT   1;

        -- =========================
        -- Check Validation Result
        -- =========================
        IF v_auth_rec_id IS NULL OR v_customer_rec_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid or expired user authentication token.');
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.is_valid', 0);

            LEAVE main_block;
        END IF;

        -- =========================
        -- Build Success Response
        -- =========================
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'User authentication token validated successfully.');

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.is_valid', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.customer_rec_id', v_customer_rec_id);

    END main_block;

END$$

DELIMITER ;
