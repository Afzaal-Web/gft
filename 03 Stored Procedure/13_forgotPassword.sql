-- ==================================================================================================
-- Procedure:   forgotPassword
-- Purpose:     Initiate password reset by sending OTP to verified contact
-- ==================================================================================================

DROP PROCEDURE IF EXISTS forgotPassword;

DELIMITER $$

CREATE PROCEDURE forgotPassword(
								IN  pReqJson   JSON,   
								OUT pResJson   JSON
							 )
BEGIN
    
    DECLARE v_input             VARCHAR(255);
    DECLARE v_login_id       	VARCHAR(255);
    DECLARE v_email          	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
	DECLARE v_input_type        ENUM('user_name','email','phone');

    main_block: BEGIN

      -- =========================
        -- Extract login ID input
        -- =========================
        SET v_input = getJval(pReqJson, 'P_LOGIN_ID');
        
		-- =========================
        -- Detect input type
        -- =========================
        IF v_input LIKE '%@%' THEN
            SET v_input_type = 'email';
            
        ELSEIF v_input REGEXP '^[0-9]+$' THEN
            SET v_input_type = 'phone';
            
        ELSE
            SET v_input_type = 'username';
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
            SET pResJson = JSON_OBJECT(
										'status', 	'USER_NOT_FOUND',
										'message', 	'No account matches the provided login ID.'
									 );
            LEAVE main_block;
        END IF;

		   -- =========================
        -- Send OTP according to input type
        -- =========================
        CASE v_input_type
        
         WHEN 'username' THEN
                -- Send OTP to all verified contacts
                IF v_email IS NOT NULL THEN
                    CALL genOtp('email', v_email, 'RESET PASSWORD');
                END IF;
                IF v_phone IS NOT NULL THEN
                    CALL genOtp('phone', v_phone, 'RESET PASSWORD');
                END IF;

            WHEN 'email' THEN
                -- Send OTP only to email
                CALL genOtp('email', v_email, 'RESET PASSWORD');

            WHEN 'phone' THEN
                -- Send OTP only to phone
                CALL genOtp('phone', v_phone, 'RESET PASSWORD');
        END CASE;


        -- ============ Prepare response ============
        SET pResJson = JSON_OBJECT(
									'status', 			'OTP_SENT',
									'message', 			'OTP has been sent to your verified contact. Use it to reset your password.'
								);

    END main_block;

END $$

DELIMITER ;
