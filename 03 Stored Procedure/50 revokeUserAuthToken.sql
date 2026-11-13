
-- ==================================================================================================
-- Procedure:  revokeUserAuthToken
-- Purpose:    Revoke the user authentication token and deactivate the current session.
-- Functions used:
--             getJval()
--             buildJSONSmart()
-- ==================================================================================================

DROP PROCEDURE IF EXISTS revokeUserAuthToken;

DELIMITER $$

CREATE PROCEDURE `revokeUserAuthToken`(
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

    DECLARE v_auth_json                JSON;
    DECLARE v_err_msg                  TEXT;

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
        SET v_user_auth_token = getJval(pjReqObj, 'jData.P_USER_AUTH_TOKEN');

        -- =========================
        -- Validate Token
        -- =========================
        IF v_user_auth_token IS NULL OR v_user_auth_token = '' THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'User authentication token is required.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Validate Token Format
        -- =========================
        IF CHAR_LENGTH(v_user_auth_token) <> 64
           OR NOT REGEXP_LIKE(v_user_auth_token, '^[0-9a-f]{64}$', 'c') THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid user authentication token.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Generate Token Hash
        -- =========================
        SET v_user_auth_token_hash = SHA2(v_user_auth_token, 256);

        -- =========================
        -- Find Active Session
        -- =========================
        SELECT  a.auth_rec_id,           a.parent_table_rec_id,     a.auth_json
        INTO    v_auth_rec_id,           v_customer_rec_id,         v_auth_json
        FROM    auth a
        JOIN    customer c ON c.customer_rec_id = a.parent_table_rec_id
        WHERE   a.parent_table_name = 'customer'
        AND     getJval(a.auth_json, 'current_session.user_auth_token') = v_user_auth_token_hash
        AND     BINARY getJval(a.auth_json, 'current_session.session_status') = BINARY 'ACTIVE'
        AND     STR_TO_DATE(
                    getJval(a.auth_json, 'current_session.session_expires_at'),
                    '%Y-%m-%d %H:%i:%s'
                ) > UTC_TIMESTAMP()
        LIMIT   1
        FOR UPDATE;

        -- =========================
        -- Validate Session
        -- =========================
        IF v_auth_rec_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid or expired user authentication token.');

            LEAVE main_block;
        END IF;

        -- =========================
        -- Revoke User Auth Token
        -- =========================
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.user_auth_token', NULL);
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.session_status', 'INACTIVE');
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.user_session_id', NULL);
        SET v_auth_json = buildJSONSmart(v_auth_json, 'current_session.session_expires_at', DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s'));

        -- =========================
        -- Update Auth Table
        -- =========================
        UPDATE  auth
        SET     auth_json = v_auth_json
        WHERE   auth_rec_id = v_auth_rec_id
        AND     parent_table_name = 'customer'
        AND     parent_table_rec_id = v_customer_rec_id
        AND     getJval(auth_json, 'current_session.user_auth_token') = v_user_auth_token_hash;

        -- =========================
        -- Build Success Response
        -- =========================
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'User logged out successfully.');

    END main_block;

END$$

DELIMITER ;
