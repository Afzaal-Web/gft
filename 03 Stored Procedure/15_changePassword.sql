-- ==================================================================================================
-- Procedure:   changePassword
-- Purpose:     Change user password after verifying old password
-- ==================================================================================================

DROP PROCEDURE IF EXISTS changePassword;
DELIMITER $$

CREATE PROCEDURE changePassword(
								IN  pReqObj       JSON,
								OUT pResObj       JSON
							)
BEGIN
    DECLARE v_login_id        VARCHAR(255);
    DECLARE v_old_password    VARCHAR(255);
    DECLARE v_new_password    VARCHAR(255);
    
    DECLARE v_customer_rec_id 	INT;
    DECLARE v_user_name       	VARCHAR(255);
    DECLARE v_email           	VARCHAR(255);
    DECLARE v_phone             VARCHAR(20);
    DECLARE v_db_password     	VARCHAR(255);

    main_block: BEGIN

        -- =========================
        -- Extract values from JSON
        -- =========================
        SET v_login_id      = getJval(pReqObj, 'P_LOGIN_ID');
        SET v_old_password  = getJval(pReqObj, 'P_OLD_PASSWORD');
        SET v_new_password  = getJval(pReqObj, 'P_NEW_PASSWORD');

        -- Validate input
        IF v_login_id IS NULL OR v_old_password IS NULL OR v_new_password IS NULL THEN
            SET pResObj = JSON_OBJECT(
                'status',  'INVALID_REQUEST',
                'message', 'Login ID, Old Password and New Password are required.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Find user and get current password
        -- =========================
        SELECT customer_rec_id, 	user_name, 	 email, 	phone,    getJval(auth_json,'$.login_credentials.password')  AS current_password
        INTO   v_customer_rec_id,   v_user_name, v_email,   v_phone,  v_db_password
        FROM   auth a
        JOIN   customer c ON a.parent_table_rec_id = c.customer_rec_id
        WHERE  c.user_name 	= v_login_id
            OR c.email 		= v_login_id
            OR c.phone 		= v_login_id
        LIMIT 1;

        -- User not found
        IF v_customer_rec_id IS NULL THEN
            SET pResObj = JSON_OBJECT(
                'status',  'USER_NOT_FOUND',
                'message', 'No account matches the provided login ID.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Validate old password
        -- =========================
        IF SHA2(v_old_password,256) <> v_db_password THEN
            SET pResObj = JSON_OBJECT(
										'status', 'INVALID_OLD_PASSWORD',
										'message', 'The old password is incorrect.'
									);
            LEAVE main_block;
        END IF;
        
		-- =========================
        -- Check if new password equals current password
        -- =========================
        
        IF SHA2(v_new_password,256) = v_db_password THEN
            SET pResObj = JSON_OBJECT(
                'status', 'PASSWORD_REUSED',
                'message', 'New password cannot be the same as your current password.'
            );
            LEAVE main_block;
        END IF;
        
        -- =========================
        -- Prevent reuse of last passwords
        -- =========================
        IF EXISTS (
            SELECT 1 
            FROM password_history
            WHERE parent_table_name		 = 'customer'
              AND parent_table_rec_id 	 = v_customer_rec_id
              AND password_hash 		 = SHA2(v_new_password,256)
        ) THEN
            SET pResObj = JSON_OBJECT(
                'status', 'PASSWORD_REUSED',
                'message', 'You cannot reuse a previous password.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Update password in auth table
        -- =========================
        UPDATE auth
        SET auth_json = JSON_SET(auth_json, '$.login_credentials.password', SHA2(v_new_password,256))
        WHERE 	parent_table_name = 'customer'
		AND		parent_table_rec_id = v_customer_rec_id;

        -- =========================
        -- Deactivate previous password in history
        -- =========================
        UPDATE password_history
        SET is_active = 0
        WHERE parent_table_name = 'customer'
          AND parent_table_rec_id = v_customer_rec_id
          AND is_active = 1;

        -- =========================
        -- Insert new password into password history
        -- =========================
        
          INSERT INTO password_history
        SET   parent_table_name 		= 'customer',
              parent_table_rec_id		= v_customer_rec_id,
              password_hash				= SHA2(v_new_password,256),
              password_set_at			= NOW(),
              password_change_by		= 'customer',
              password_change_reason	= 'Change password',
              last_password_updated_at  = NOW(),
              password_expiration_date	= DATE_ADD(NOW(), INTERVAL 90 DAY),
             is_active					= 1;

        -- =========================
        -- Success response
        -- =========================
        SET pResObj  = JSON_OBJECT(
            'status',  'PASSWORD_CHANGE_SUCCESS',
            'message', 'Your password has been successfully changed.'
        );

    END main_block;

END $$

DELIMITER ;
