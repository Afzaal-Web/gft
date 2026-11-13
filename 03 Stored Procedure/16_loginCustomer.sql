
-- ==================================================================================================
-- Procedure:   loginCustomer
-- Purpose:     Validate login credentials and generate OTP for login verification
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
    DECLARE v_email             VARCHAR(255);
    DECLARE v_phone             VARCHAR(20);
    DECLARE v_db_password       VARCHAR(255);

    DECLARE v_input_type        ENUM('user_name','email','phone');
    DECLARE v_shared_otp        VARCHAR(6);
    DECLARE v_otp_message       TEXT;

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
        SET v_shared_otp    = getJval(pjReqObj, 'jData.P_PRESET_OTP');

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

        SELECT  c.user_name,  c.email,   c.phone,   getJval( a.auth_json, 'login_credentials.password')
        INTO    v_login_id,   v_email,   v_phone,   v_db_password
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
        -- Generate OTP
        -- =========================

        CASE v_input_type

            WHEN 'user_name' THEN

                -- Username: send same OTP to email and phone

                -- SET @v_shared_otp = LPAD(FLOOR(100000 + RAND() * 900000), 6, '0'); // remove comment when in production

                IF NULLIF(TRIM(v_email), '') IS NOT NULL THEN

                    CALL genOtp(
                        JSON_OBJECT(
                            'jData', JSON_OBJECT(
                                'P_CONTACT_TYPE',   'email',
                                'P_DESTINATION',    v_email,
                                'P_PURPOSE',        'LOGIN',
                                'P_PRESET_OTP',     v_shared_otp
                            )
                        ),
                        pjRespObj
                    );

                END IF;

                IF NULLIF(TRIM(v_phone), '') IS NOT NULL THEN

                    CALL genOtp(
                        JSON_OBJECT(
                            'jData', JSON_OBJECT(
                                'P_CONTACT_TYPE',   'phone',
                                'P_DESTINATION',    v_phone,
                                'P_PURPOSE',        'LOGIN',
                                'P_PRESET_OTP',     v_shared_otp
                            )
                        ),
                        pjRespObj
                    );

                END IF;

            WHEN 'email' THEN

                -- Email: send OTP to registered email

                CALL genOtp(
                    JSON_OBJECT(
                        'jData', JSON_OBJECT(
                            'P_CONTACT_TYPE',   'email',
                            'P_DESTINATION',    v_email,
                            'P_PURPOSE',        'LOGIN',
                            'P_PRESET_OTP',     v_shared_otp
                        )
                    ),
                    pjRespObj
                );

            WHEN 'phone' THEN

                -- Phone: send OTP to registered phone

                CALL genOtp(
                    JSON_OBJECT(
                        'jData', JSON_OBJECT(
                            'P_CONTACT_TYPE',   'phone',
                            'P_DESTINATION',    v_phone,
                            'P_PURPOSE',        'LOGIN',
                             'P_PRESET_OTP',     v_shared_otp
                        )
                    ),
                    pjRespObj
                );

        END CASE;
        
        -- =========================
        -- Credentials and OTP response
        -- =========================

        IF getJval(pjRespObj, 'jHeader.responseCode') = 0 THEN

            SET v_otp_message = getJval(pjRespObj, 'jHeader.message');

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',
                JSON_ARRAY(
                    'LOGIN_CREDENTIALS_VALID - Credentials verified successfully.',
                    v_otp_message
                )
            );

        END IF;


    END main_block;

    -- Logging here

END $$

DELIMITER ;
