-- ==================================================================================================
-- Procedure:   resetPassword
-- Purpose:     Reset user password after OTP verification using reset token
-- ==================================================================================================

DROP PROCEDURE IF EXISTS resetPassword;
DELIMITER $$

CREATE PROCEDURE resetPassword(
                                IN  pReqJson       JSON,
                                OUT pResJson      JSON
                              )
BEGIN

    DECLARE v_login_id            VARCHAR(255);
    DECLARE v_new_password        VARCHAR(255);
    DECLARE v_reset_token         VARCHAR(100);
    
    DECLARE v_customer_rec_id     INT;
    DECLARE v_user_name           VARCHAR(255);
    DECLARE v_email               VARCHAR(255);
    DECLARE v_phone               VARCHAR(20);
    DECLARE v_token_expiry        DATETIME;
    DECLARE v_db_reset_token 	 VARCHAR(100);

    main_block: BEGIN

        -- =========================
        -- Extract values from JSON
        -- =========================
        SET v_login_id    		 = getJval(pReqJson, 'P_LOGIN_ID');
        SET v_new_password 		 = getJval(pReqJson, 'P_NEW_PASSWORD');
        SET v_reset_token 		 = getJval(pReqJson, 'P_RESET_TOKEN');

        -- Validate input
        IF v_login_id IS NULL OR v_new_password IS NULL OR v_reset_token IS NULL THEN
            SET pResJson = JSON_OBJECT(
										'status',  'INVALID_REQUEST',
										'message', 'Login ID, New Password and Reset Token are required.'
									);
            LEAVE main_block;
        END IF;

        -- =========================
        -- Find customer & validate reset token
        -- =========================
        SELECT customer_rec_id, 	user_name, 		email, 		phone, 	  getJval(customer_json,'$.otp_reset_token') AS token, 	getJval(customer_json,'$.reset_token_expiry') AS token_expiry
        INTO   v_customer_rec_id, 	v_user_name, 	v_email, 	v_phone,  v_db_reset_token, 									v_token_expiry
        FROM   customer
        WHERE  user_name = v_login_id
            OR email = v_login_id
            OR phone = v_login_id
        LIMIT 1;

        -- Customer not found
        IF v_customer_rec_id IS NULL THEN
            SET pResJson = JSON_OBJECT(
										'status',  'USER_NOT_FOUND',
										'message', 'No account matches the provided login ID.'
									);
            LEAVE main_block;
        END IF;

        -- Token mismatch
        IF v_reset_token <>  v_db_reset_token THEN
            SET pResJson = JSON_OBJECT(
										'status', 'INVALID_TOKEN',
										'message', 'The reset token is invalid.'
									);
            LEAVE main_block;
        END IF;

        -- Token expired
        IF NOW() > v_token_expiry THEN
            SET pResJson = JSON_OBJECT(
										'status', 'EXPIRED_TOKEN',
										'message', 'The reset token has expired.'
									);
            LEAVE main_block;
        END IF;

        -- =========================
        -- Prevent reuse of last passwords
        -- =========================
        IF EXISTS (
            SELECT 1 
            FROM password_history
            WHERE 	parent_table_name = 'customer'
            AND		parent_table_rec_id = v_customer_rec_id
			AND 	password_hash = SHA2(v_new_password,256)
        ) THEN
            SET pResJson = JSON_OBJECT(
										'status',  'PASSWORD_REUSED',
										'message', 'You cannot reuse a previous password.'
									);
            LEAVE main_block;
        END IF;

        -- =========================
        -- Update password in auth table
        -- =========================
        UPDATE auth
        SET auth_json  = JSON_SET(auth_json, '$.login_credentials.password', SHA2(v_new_password,256))
        WHERE 	parent_table_name = 'customer'
		AND		parent_table_rec_id = v_customer_rec_id;
        
		-- =========================
        -- Deactivate previous passwords
        -- =========================
        UPDATE password_history
		SET is_active = 0
		WHERE 	parent_table_name 	= 'customer'
		AND 	parent_table_rec_id = v_customer_rec_id
		AND 	is_active 			= 1;

        -- =========================
        -- Insert into password history NEW ROW
        -- =========================
        INSERT INTO password_history
        SET   parent_table_name 		= 'customer',
              parent_table_rec_id		= v_customer_rec_id,
              password_hash				= SHA2(v_new_password,256),
              password_set_at			= NOW(),
              password_change_by		= 'customer',
              password_change_reason	= 'forgot password',
              last_password_updated_at  = NOW(),
              password_expiration_date	= DATE_ADD(NOW(), INTERVAL 90 DAY),
             is_active					= 1;

        -- =========================
        -- Clear reset token
        -- =========================
        UPDATE customer
        SET customer_json = JSON_REMOVE(customer_json,'$.otp_reset_token','$.reset_token_expiry')
        WHERE customer_rec_id = v_customer_rec_id;

        -- =========================
        -- Success Response
        -- =========================
        SET pResJson = JSON_OBJECT(
            'status',  'PASSWORD_RESET_SUCCESS',
            'message', 'Your password has been successfully reset.'
        );

    END main_block;

END $$

DELIMITER ;
