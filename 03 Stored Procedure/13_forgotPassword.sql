-- ==================================================================================================
-- Procedure:   forgotPassword
-- Purpose:     Initiate password reset by sending OTP to verified contact
-- ==================================================================================================

DROP PROCEDURE IF EXISTS forgotPassword;

DELIMITER $$

CREATE PROCEDURE forgotPassword(
								IN      pjReqObj     JSON,   
								INOUT   pjRespObj   JSON
							 )
BEGIN
    
    DECLARE v_input             VARCHAR(255);
    DECLARE v_login_id       	VARCHAR(255);
    DECLARE v_email          	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
	DECLARE v_input_type        ENUM('user_name','email','phone');

    DECLARE v_err_msg           TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));
    END;

    main_block: BEGIN

      -- =========================
        -- Extract login ID input
        -- =========================
        SET v_input = getJval(pjReqObj, 'jData.P_LOGIN_ID');
        
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


        -- ============= Find user account =============
        SELECT  user_name,	 email, 	 phone
        INTO    v_login_id,  v_email, 	 v_phone
        FROM   	customer
		WHERE   (v_input_type = 'user_name' AND  user_name = v_input)
		OR 		(v_input_type = 'email'     AND  email = v_input)
		OR 		(v_input_type = 'phone'     AND  phone = v_input)
        LIMIT 1;

        IF v_login_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'customer not found');

            LEAVE main_block;
        END IF;

        -- ============ Generate OTP to verified contact(s) ============
        CASE v_input_type
        
        WHEN 'user_name' THEN
                -- Username supplied: send OTP to email and phone

            SET @v_shared_otp = LPAD(FLOOR(100000 + RAND() * 900000), 6, '0');

            IF v_email IS NOT NULL THEN
                CALL genOtp(
                            JSON_OBJECT(
                                        'jData', JSON_OBJECT(
                                                             'P_CONTACT_TYPE',  'email',
                                                             'P_DESTINATION',   v_email,
                                                             'P_PURPOSE',       'RESET PASSWORD',
                                                             'P_PRESET_OTP',    @v_shared_otp
                                                            )
                                        ), pjRespObj
                            );
            END IF;

            IF v_phone IS NOT NULL THEN
                CALL genOtp(
                            JSON_OBJECT(
                                        'jData', JSON_OBJECT(
                                                            'P_CONTACT_TYPE',  'phone',
                                                            'P_DESTINATION',   v_phone,
                                                            'P_PURPOSE',       'RESET PASSWORD',
                                                            'P_PRESET_OTP',     @v_shared_otp
                                                            )
                                        ), pjRespObj
                            );
            END IF;

        WHEN 'email' THEN
                CALL genOtp(
                            JSON_OBJECT(
                                        'jData', JSON_OBJECT(
                                                             'P_CONTACT_TYPE',  'email',
                                                             'P_DESTINATION',   v_email,
                                                             'P_PURPOSE',       'RESET PASSWORD'
                                                            )
                                        ), pjRespObj
                            );

        WHEN 'phone' THEN
                CALL genOtp(
                    JSON_OBJECT(
                                'jData', JSON_OBJECT(
                                                    'P_CONTACT_TYPE',  'phone',
                                                    'P_DESTINATION',   v_phone,
                                                    'P_PURPOSE',       'RESET PASSWORD'
                                                    )
                    ), pjRespObj
                );

        END CASE;

    END main_block;

    -- logging here

END $$

DELIMITER ;