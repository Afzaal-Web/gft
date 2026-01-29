-- customer json initialize

DELIMITER $$

CREATE PROCEDURE initialize_customer_json(
		OUT new_customer_id INT
)
BEGIN
    -- Insert a new row with full JSON skeleton and all null/default values
    INSERT INTO customer
    SET
        customer_json   = 	JSON_OBJECT(
            'customer_rec_id', 					NULL,
            'customer_status', 					NULL,
            'customer_type', 					NULL,
            'corporate_account_rec_id', 		NULL,

            'first_name', 						NULL,
            'last_name',  						NULL,
            'national_id', 						NULL,
            'email', 							NULL,
            'phone', 							NULL,
            'whatsapp_number', 					NULL,
            
			'main_account_num',          		NULL,
			'account_num',           			NULL,
			'account_title',              		NULL,
			'designation',                		NULL,
			'cus_profile_pic', 					NULL,

            'additional_contacts', JSON_ARRAY(
                JSON_OBJECT(
                    'Additional_email_1', 		NULL,
                    'Additional_phone_1', 		NULL
                ),
                JSON_OBJECT(
                    'Additional_email_2', 		NULL,
                    'Additional_phone_2', 		NULL
                )
            ),

            'residential_address', JSON_OBJECT(
                'google_reference_number', 		NULL,
                'full_address', 				Null,
                'country', 						Null,
                'building_number', 				Null,
                'street_name', 					Null,
                'street_address_2', 			Null,
                'city', 						Null,
                'state', 						Null,
                'zip_code', 					Null,
                'directions', 					Null,
                'cross_street_1_name', 			Null,
                'cross_street_2_name', 			Null,
                'latitude', 					Null,
                'longitude', 					Null
            ),
            'permissions', JSON_OBJECT(
                'is_buy_allowed', 				false,
                'is_sell_allowed', 				false,
                'is_redeem_allowed', 			false,
                'is_add_funds_allowed', 		false,
                'is_withdrawl_allowed', 		false
            ),

            'app_preferences', JSON_OBJECT(
                'time_zone', 					NULL,
                'preferred_currency',			NULL,
                'preferred_language', 			NULL,
                'auto_logout_minutes', 			NULL,
                'remember_me_enabled', 			false,
                'default_home_location', 		NULL,
                'biometric_login_enabled', 		false,
                'push_notifications_enabled', 	false,
                'transaction_alerts_enabled', 	false,
                'email_notifications_enabled', 	false
            )
        ),

        row_metadata 	= 	JSON_OBJECT(
            'created_at', 		NOW(3),
            'created_by', 		'registration_api',
            'updated_at', 		NOW(3),
            'updated_by', 		'registration_api',
            'status', 			'registration_request'
        );
        
        SET new_customer_id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- auth json initialize
DELIMITER $$

CREATE PROCEDURE initialize_auth_json(
    OUT new_auth_id INT
)
BEGIN
    INSERT INTO auth 
    SET
       auth_json = JSON_OBJECT(
            'auth_rec_id', 0,
            'parent_table_name', null,
            'parent_table_rec_id', null,
            'user_name', NULL,
            'latest_otp_code', NULL,
            'latest_otp_sent_at', NULL,
            'latest_otp_expires_at', NULL,
            'otp_retries', 0,
            'next_otp_in', 60,
            'two_fa', JSON_OBJECT(
                'is_2FA', true,
                '2FA_method', NULL,
                '2FA_method_value', NULL
            ),
            'login_attempts', JSON_OBJECT(
                'last_login_date', NULL,
                'login_attempts_count', 0,
                'login_attempt_minutes', 0
            ),
            'current_session', JSON_OBJECT(
                'latitude', NULL,
                'longitude', NULL,
                'device_id', NULL,
                'ip_address', NULL,
                'last_login_at', NULL,
                'session_status', NULL,
                'user_auth_token', NULL,
                'user_session_id', NULL,
                'last_login_device', NULL,
                'last_login_method', NULL,
                'session_expires_at', NULL
            ),
            'password_history', JSON_OBJECT(
                'is_active', true,
                'password_set_at', Null,
                'password_changed_by', NULL,
                'password_change_reason', Null,
                'last_password_updated_at', Null,
                'password_expiration_date', DATE_ADD(NOW(), INTERVAL 90 DAY)
            ),
            'login_credentials', JSON_OBJECT(
                'pin', NULL,
                'password', NULL,
                'username', NULL,
                'alternate_username', NULL,
                'is_force_password_change', false
            ),
            'security_questions', JSON_OBJECT(
                'auth_security_question', NULL,
                'auth_security_answer', NULL
            ),
            'biometric_authentication', JSON_OBJECT(
                'is_face_id_enabled', false,
                'is_fingerprint_enabled', false
            )
        ),
        row_metadata  = JSON_OBJECT(
            'created_at', NOW(3),
            'created_by', 'system',
            'updated_at', NOW(3),
            'updated_by', 'system'
        );
        SET new_auth_id = LAST_INSERT_ID();
END$$

DELIMITER ;



-- CREATE customer
DELIMITER $$

CREATE PROCEDURE create_customer(
    IN pjReqObj JSON,
    OUT psResult VARCHAR(255)
)
proc_block: BEGIN
        DECLARE v_customer_rec_id INT;
        DECLARE v_auth_rec_id INT;
        DECLARE national_id_val VARCHAR(50);   
        DECLARE v_password_plain VARCHAR(255);
		DECLARE v_password_hashed VARCHAR(255);
		DECLARE v_username VARCHAR(50);
        
		SET national_id_val = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id'));
        SET v_password_plain = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.password'));

    IF EXISTS (
        SELECT 1
        FROM customer
        WHERE national_id = CONVERT(national_id_val USING utf8mb4)
                             COLLATE utf8mb4_0900_ai_ci
    ) THEN
        SET psResult = 'National ID already exists.';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'National ID already exists.',
                MYSQL_ERRNO = 9999;
    END IF;

    CALL initialize_customer_json(v_customer_rec_id);

    UPDATE customer
    SET
        first_name  = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')),
        last_name   = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name')),
        national_id = 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id')),
        customer_json = JSON_SET(
            customer_json,
            '$.customer_rec_id', 								v_customer_rec_id,
            '$.first_name', 									JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')),
            '$.last_name', 										JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name')),
            '$.national_id', 									JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id')),
            '$.email', 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.email')),
            '$.phone', 											JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.phone')),
            '$.whatsapp_number', 								JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.whatsapp_number')),
            '$.residential_address.google_reference_number', 	JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.google_reference_number')),
            '$.residential_address.full_address', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.full_address')),
            '$.residential_address.country', 					JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.country')),
            '$.residential_address.building_number', 			JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.building_number')),
            '$.residential_address.street_name', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.street_name')),
            '$.residential_address.street_address_2', 			JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.street_address_2')),
            '$.residential_address.city', 						JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.city')),
            '$.residential_address.state', 						JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.state')),
            '$.residential_address.zip_code', 					JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.zip_code')),
            '$.residential_address.directions', 				JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.directions')),
            '$.residential_address.cross_street_1_name', 		JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.cross_street_1_name')),
            '$.residential_address.cross_street_2_name', 		JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.residential_address.cross_street_2_name')),
            '$.residential_address.latitude', 					JSON_EXTRACT(pjReqObj, 				'$.residential_address.latitude'),
            '$.residential_address.longitude', 					JSON_EXTRACT(pjReqObj, 				'$.residential_address.longitude')
        )
    WHERE customer_rec_id = v_customer_rec_id;
    
    CALL initialize_auth_json(v_auth_rec_id);
    
	SET v_password_hashed = SHA2(v_password_plain, 256);
    SET v_username = CONCAT(
        JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')),
        JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name')),
        LPAD(FLOOR(RAND() * 1000), 3, '0')
    );
    
	UPDATE auth
	SET
    parent_table_name    = 'CUSTOMER',
    parent_table_rec_id  = v_customer_rec_id,
    user_name            = v_username,
    auth_json = JSON_SET(
        auth_json,
        '$.auth_rec_id', 								v_auth_rec_id,
        '$.parent_table_name', 							'customer',
        '$.parent_table_rec_id', 							v_customer_rec_id,
        '$.login_credentials.password', v_password_hashed,
        '$.login_credentials.username', v_username,
        '$.login_credentials.alternate_username', CONCAT(
            JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name')), '.',
            JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name'))
        ),
        '$.parent_table_rec_id', v_customer_rec_id
    ),
    row_metadata = JSON_SET(
        row_metadata,
        '$.updated_at', NOW(3),
        '$.updated_by', 'registration_api'
    )
WHERE auth_rec_id = v_auth_rec_id;

    
    SET psResult 				= 'Your account has been successfully created.
								   To continue, please complete the verification steps below.';

END$$

DELIMITER ;

-- Test script

SET @pjReqObj = JSON_OBJECT(
    'first_name', 'Alice',
    'last_name', 'Smith',
    'national_id', '987654321653',
    'email', 'alice.smith@example.com',
    'phone', '+19876543210',
    'whatsapp_number', '+19876543210',
	'google_reference_number', 'GRN987',
	'full_address', '456 Elm Street',
	'country', 'USA',
	'building_number', '20B',
	'street_name', 'Elm Street',
	'street_address_2', 'Apt 12',
	'city', 'Los Angeles',
	'state', 'CA',
	'zip_code', '90001',
	'directions', 'Near Hollywood Blvd',
	'cross_street_1_name', 'Sunset Blvd',
	'cross_street_2_name', 'Vine St',
	'latitude', 34.0522,
	'longitude', -118.2437,
    'password', 'Alice@Pass2026'
);

-- Step 2: Declare variable to receive result message
SET @psResult = '';

-- Step 3: Call create_customer procedure
CALL create_customer(@pjReqObj, @psResult);

-- Step 4: Check the result message
SELECT @psResult AS registration_status;

SELECT JSON_TYPE(@pjReqObj), JSON_VALID(@pjReqObj);
