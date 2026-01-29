CREATE DATABASE IF NOT EXISTS gft;
USE gft;

-- Auth and customer Module Started

-- ===============================================
-- Corporate Account Table Started
-- ===============================================

DROP TABLE IF EXISTS corporate_accounts;
-- ===============================================
-- Create corporate_account table
-- ===============================================
CREATE TABLE IF NOT EXISTS corporate_accounts (
    corporate_account_rec_id 		INT 										PRIMARY KEY AUTO_INCREMENT,
    account_num 					VARCHAR(50),
    account_status 					ENUM('Active','InActive', 'Suspended')		NOT NULL,
    corporate_account_json 			JSON,
    row_metadata 					JSON
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===============================================
-- Demo row: corporate_account_rec_id = 0
-- ===============================================
INSERT INTO corporate_accounts (
    corporate_account_rec_id,
    account_num,
    account_status,
    corporate_account_json,
    row_metadata
) VALUES (
    0,
    'AZS12345',
    'ACTIVE',
    JSON_OBJECT(
        'corporate_account_rec_id', 0,									'_comment_corporate_account_rec_id', 'Auto-incremented unique corporate account ID',
        'account_num', 'AZS-001',										'_comment_account_num', 'Unique corporate account number',
        'account_status', 'ACTIVE',										'_comment_account_status', 'Current status: ACTIVE, INACTIVE, BLOCKED, etc.',
        'Account', JSON_OBJECT(
            'Account_info', JSON_OBJECT(
                'account_num', 'AZS-001',								'_comment_account_num', 'Internal account number',
                'account_title', 'ABC Traders Corporate Account',		'_comment_account_title', 'Title of this account',
                'main_account_num', 'MAIN-AZS-001',						'_comment_main_account_num', 'Main corporate account number',
                'main_account_title', 'ABC Traders Main Account',		'_comment_main_account_title', 'Title of main corporate account'
            ),
            'account_lifecycle', JSON_OBJECT(
                'account_end_at', NULL,									'_comment_account_end_at', 'Date when account is closed or deactivated',
                'account_start_at', '2024-01-01',						'_comment_account_start_at', 'Date when account was created',
                'user_account_block_at', NULL,							'_comment_user_account_block_at', 'Date when account was blocked, if any',
                'latest_status_updated_at', NOW(3),						'_comment_latest_status_updated_at', 'Timestamp of last status update'
            )
        ),
        'company', JSON_OBJECT(
            'owner_info', JSON_OBJECT(
                'owner_name', 'Ahmed Khan',								'_comment_owner_name', 'Name of company owner',
                'owner_email', 'ahmed.khan@abctraders.com',				'_comment_owner_email', 'Email of company owner',
                'owner_phone', '+92-300-1112233',						'_comment_owner_phone', 'Phone number of company owner'
            ),
            'company_info', JSON_OBJECT(
                'company_name', 'ABC Traders Pvt Ltd',					'_comment_company_name', 'Full registered name of the company',
                'company_email', 'info@abctraders.com',					'_comment_company_email', 'Official email of the company',
                'company_phone', '+92-300-1234567',						'_comment_company_phone', 'Official phone of the company',
                'company_ntn_number', '1234567-8',						'_comment_company_ntn_number', 'National Tax Number of company',
                'company_date_of_incorporation', '2018-06-15',			'_comment_company_date_of_incorporation', 'Date company was incorporated'
            ),
            'customer_stats', JSON_OBJECT(
                'open_tickets', 2,										'_comment_open_tickets', 'Number of open support tickets',
                'total_assets', 85000000,								'_comment_total_assets', 'Total assets of the company',
                'total_orders', 1340,									'_comment_total_orders', 'Total orders placed by the company',
                'num_of_tickets', 18,									'_comment_num_of_tickets', 'Total number of support tickets',
                'num_of_employees', 25,									'_comment_num_of_employees', 'Total employees in company',
                'year_to_date_orders', 215,								'_comment_year_to_date_orders', 'Orders placed this year'
            ),
            'company_address', JSON_OBJECT(
                'city', 'Karachi',										'_comment_city', 'City of company',
                'state', 'Sindh',										'_comment_state', 'State of company',
                'country', 'Pakistan',									'_comment_country', 'Country of company',
                'latitude', 24.8607,									'_comment_latitude', 'Latitude coordinate',
                'zip_code', '75400',									'_comment_zip_code', 'Postal/zip code',
                'longitude', 67.0011,									'_comment_longitude', 'Longitude coordinate',
                'directions', 'Near FTC Building',						'_comment_directions', 'Directions to company location',
                'street_name', 'Shahrah-e-Faisal',						'_comment_street_name', 'Street name',
                'full_address', 'Office 402, Business Plaza, Karachi',	'_comment_full_address', 'Complete full address',
                'building_number', '402',								'_comment_building_number', 'Building number',
                'street_address_2', 'Business Plaza',					'_comment_street_address_2', 'Additional street info',
                'company_mailing_address', 'PO Box 1234, Karachi',		'_comment_company_mailing_address', 'Mailing address for company',
                'google_reference_number', 'ChIJ123ABC',				'_comment_google_reference_number', 'Google Maps reference ID'
            ),
            'primary_contact_info', JSON_OBJECT(
                'primary_email', 'ali.raza@abctraders.com',				'_comment_primary_email', 'Primary contact email',
                'primary_phone', '+92-300-2223344',						'_comment_primary_phone', 'Primary contact phone',
                'primary_contact', 'Ali Raza',							'_comment_primary_contact', 'Primary contact person name',
                'designation_of_contact', 'Finance Manager',			'_comment_designation_of_contact', 'Designation/title of primary contact'
            )
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'system',
        'updated_at', NOW(3),
        'updated_by', 'system',
        'status', 'active'
    )
);

-- ===============================================
-- Production corporate_account_rec_id = 0
-- ===============================================
INSERT INTO corporate_accounts (
    account_num,
    account_status,
    corporate_account_json,
    row_metadata
) VALUES (
    122,
    'active',
    JSON_OBJECT(
        'corporate_account_rec_id', NULL,
        'account_num', NULL,
        'account_status', NULL,
        'Account', JSON_OBJECT(
            'Account_info', JSON_OBJECT(
                'account_num', NULL,
                'account_title', NULL,
                'main_account_num', NULL,
                'main_account_title', NULL
            ),
            'account_lifecycle', JSON_OBJECT(
                'account_end_at', NULL,
                'account_start_at', NULL,
                'user_account_block_at', NULL,
                'latest_status_updated_at', NULL
            )
        ),
        'company', JSON_OBJECT(
            'owner_info', JSON_OBJECT(
                'owner_name', NULL,
                'owner_email', NULL,
                'owner_phone', NULL
            ),
            'company_info', JSON_OBJECT(
                'company_name', NULL,
                'company_email', NULL,
                'company_phone', NULL,
                'company_ntn_number', NULL,
                'company_date_of_incorporation', NULL
            ),
            'customer_stats', JSON_OBJECT(
                'open_tickets', NULL,
                'total_assets', NULL,
                'total_orders', NULL,
                'num_of_tickets', NULL,
                'num_of_employees', NULL,
                'year_to_date_orders', NULL
            ),
            'company_address', JSON_OBJECT(
                'city', NULL,
                'state', NULL,
                'country', NULL,
                'latitude', NULL,
                'zip_code', NULL,
                'longitude', NULL,
                'directions', NULL,
                'street_name', NULL,
                'full_address', NULL,
                'building_number', NULL,
                'street_address_2', NULL,
                'company_mailing_address', NULL,
                'google_reference_number', NULL
            ),
            'primary_contact_info', JSON_OBJECT(
                'primary_email', NULL,
                'primary_phone', NULL,
                'primary_contact', NULL,
                'designation_of_contact', NULL
            )
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', NULL,
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'inactive'
    )
);

-- ===============================================
-- Update primary key in json
-- ===============================================
UPDATE corporate_accounts
SET corporate_account_json = JSON_SET(
    corporate_account_json,
    '$.corporate_account_rec_id',
    corporate_account_rec_id
)
WHERE corporate_account_rec_id = LAST_INSERT_ID();

-- ===============================================
-- Corporate Account Table Ended
-- ===============================================


-- ===============================================
-- Customers Table started
-- ===============================================
DROP TABLE IF EXISTS customers;
CREATE TABLE IF NOT EXISTS customers (
    customer_rec_id 			INT PRIMARY KEY AUTO_INCREMENT,
    customer_status 			VARCHAR(50),
    customer_type 				ENUM('PERSONAL','CORPORATE') NOT NULL,
	corporate_account_rec_id  	INT NULL,
    
	first_name 					VARCHAR(100),
    last_name 					VARCHAR(100),
    national_id					VARCHAR(50) UNIQUE,
    
    main_account_num			VARCHAR(50),
    account_num					VARCHAR(50),
    account_title				VARCHAR(50),
    designation					VARCHAR(50),
    
    customers_json 				JSON,
    row_metadata				JSON,
    
    CONSTRAINT fk_customer_corporate
	FOREIGN KEY (corporate_account_rec_id)
	REFERENCES corporate_accounts(corporate_account_rec_id)
	ON DELETE SET NULL
	ON UPDATE CASCADE,
    
    CONSTRAINT account_num_combination
    UNIQUE (main_account_num, account_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===============================================
-- Demo row: customer_rec_id = 0
-- ===============================================
INSERT INTO customers (
    customer_rec_id,
    customer_status,
    customer_type,
    corporate_account_rec_id,
    first_name,
    last_name,
    national_id,
    main_account_num,
    account_num,
    account_title,
    designation,
    customers_json,
    row_metadata
) VALUES (
    0,
    'ACTIVE',
    'CORPORATE',
    1,
    'John',
    'Doe',
    '331013434343433',
    'MAIN-AZS-001',
    'AZS-001',
    'John Doe Corporate Account',
    'CEO',
    JSON_OBJECT(
        'customer_rec_id', 0,																'_comment_customer_rec_id', 'Auto-incremented unique customer ID',
        'customer_status', 'ACTIVE',														'_comment_customer_status', 'Possible values: Active, Pending, Suspended, etc.',
        'customer_type', 'CORPORATE',														'_comment_customer_type', 'PERSONAL or CORPORATE',
        'corporate_account_rec_id', 1,														'_comment_corporate_account_rec_id', 'References corporate_accounts table if customer_type is CORPORATE',
        'first_name', 'John',																'_comment_first_name', 'Customer''s first name',
        'last_name', 'Doe',																	'_comment_last_name', 'Customer''s last name',
        'national_id', '331013434343433',													'_comment_national_id', 'Government-issued national ID',
        'personal_info', JSON_OBJECT(
            'contacts_info', JSON_OBJECT(
                'email', 'john.doe@example.com',											'_comment_email', 'Primary email of the customer',
                'phone', '+1234567890',														'_comment_phone', 'Primary phone number',
                'cus_profile_pic', 'https://example.com/profile_pic.jpg',					'_comment_cus_profile_pic', 'URL to profile picture',
                'whatsapp_number', '+1234567890',											'_comment_whatsapp_number', 'WhatsApp contact number'
            ),
            'additional_contacts', JSON_OBJECT(
                'secondary_email', 'j.doe.secondary@example.com',							'_comment_secondary_email', 'Secondary email for the customer',
                'emergency_contact', '+1234567891',											'_comment_emergency_contact', 'Emergency contact phone number'
            )
        ),
        'address', JSON_OBJECT(
            'city', 'New York',																'_comment_city', 'City name',
            'state', 'New York',															'_comment_state', 'State or province',
            'country', 'USA',																'_comment_country', 'Country name',
            'latitude', 40.7128,															'_comment_latitude', 'Latitude coordinate',
            'zip_code', '10001',															'_comment_zip_code', 'Postal/zip code',
            'longitude', -74.006,															'_comment_longitude', 'Longitude coordinate',
            'directions', 'Near Central Park',												'_comment_directions', 'Additional directions to the address',
            'street_name', 'Main St',														'_comment_street_name', 'Street name',
            'full_address', '123 Main St, Apt 4B, New York, USA',							'_comment_full_address', 'Complete full address',
            'building_number', '123',														'_comment_building_number', 'Building number or identifier',
            'street_address_2', 'Apt 4B',													'_comment_street_address_2', 'Secondary street info or apartment number',
            'cross_street_1_name', '2nd Ave',												'_comment_cross_street_1_name', 'Nearby cross street 1',
            'cross_street_2_name', '3rd Ave',												'_comment_cross_street_2_name', 'Nearby cross street 2',
            'google_reference_number', 'ChIJ1234567890',									'_comment_google_reference_number', 'Google Maps reference ID'
        ),
        'permissions', JSON_OBJECT(
            'is_buy_allowed', true,															'_comment_is_buy_allowed', 'Boolean: whether buying is allowed',
            'is_sell_allowed', true,														'_comment_is_sell_allowed', 'Boolean: whether selling is allowed',
            'is_redeem_allowed', false,														'_comment_is_redeem_allowed', 'Boolean: whether redeeming is allowed',
            'is_add_funds_allowed', true,													'_comment_is_add_funds_allowed', 'Boolean: whether adding funds is allowed',
            'is_withdrawl_allowed', true,													'_comment_is_withdrawl_allowed', 'Boolean: whether withdrawing is allowed'
        ),
        'app_preferences', JSON_OBJECT(
            'time_zone', 'America/New_York',												'_comment_time_zone', 'Preferred time zone',
            'preferred_currency', 'USD',													'_comment_preferred_currency', 'Preferred currency',
            'preferred_language', 'en',														'_comment_preferred_language', 'Preferred language',
            'auto_logout_minutes', 15,														'_comment_auto_logout_minutes', 'Minutes before automatic logout',
            'remember_me_enabled', true,													'_comment_remember_me_enabled', 'Boolean: remember me enabled',
            'default_home_location', 'New York',											'_comment_default_home_location', 'Default home location in app',
            'biometric_login_enabled', true,												'_comment_biometric_login_enabled', 'Boolean: biometric login enabled',
            'push_notifications_enabled', true,												'_comment_push_notifications_enabled', 'Boolean: push notifications enabled',
            'transaction_alerts_enabled', true,												'_comment_transaction_alerts_enabled', 'Boolean: transaction alerts enabled',
            'email_notifications_enabled', true,											'_comment_email_notifications_enabled', 'Boolean: email notifications enabled'
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'system',
        'updated_at', NOW(3),
        'updated_by', 'system',
        'status', 'active'
    )
);

-- ===============================================
-- Production template row: customer_rec_id = 1
-- ===============================================
INSERT INTO customers (
    customer_status,
    customer_type,
    corporate_account_rec_id,
    first_name,
    last_name,
    national_id,
    main_account_num,
    account_num,
    account_title,
    designation,
    customers_json,
    row_metadata
) VALUES (
    'ACTIVE',
    'CORPORATE',
    1,
    'John',
    'Doe',
    '353024343434343',
    'MAIN-AZS-001',
    'AZS-002',
    'John Doe Corporate Account',
    'CEO',
    JSON_OBJECT(
        'customer_rec_id', NULL,
        'customer_status', NULL,
        'customer_type', NULL,
        'corporate_account_rec_id', NULL,
        'first_name', NULL,
        'last_name', NULL,
        'national_id', NULL,
        'personal_info', JSON_OBJECT(
            'contacts_info', JSON_OBJECT(
                'email', NULL,
                'phone', NULL,
                'cus_profile_pic', NULL,
                'whatsapp_number', NULL
            ),
            'additional_contacts', JSON_OBJECT(
                'secondary_email', NULL,
                'emergency_contact', NULL
            )
        ),
        'address', JSON_OBJECT(
            'city', NULL,
            'state', NULL,
            'country', NULL,
            'latitude', NULL,
            'zip_code', NULL,
            'longitude', NULL,
            'directions', NULL,
            'street_name', NULL,
            'full_address', NULL,
            'building_number', NULL,
            'street_address_2', NULL,
            'cross_street_1_name', NULL,
            'cross_street_2_name', NULL,
            'google_reference_number', NULL
        ),
        'permissions', JSON_OBJECT(
            'is_buy_allowed', NULL,
            'is_sell_allowed', NULL,
            'is_redeem_allowed', NULL,
            'is_add_funds_allowed', NULL,
            'is_withdrawl_allowed', NULL
        ),
        'app_preferences', JSON_OBJECT(
            'time_zone', NULL,
            'preferred_currency', NULL,
            'preferred_language', NULL,
            'auto_logout_minutes', NULL,
            'remember_me_enabled', NULL,
            'default_home_location', NULL,
            'biometric_login_enabled', NULL,
            'push_notifications_enabled', NULL,
            'transaction_alerts_enabled', NULL,
            'email_notifications_enabled', NULL
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', NULL,
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'inactive'
    )
);

-- ===============================================
-- Update primary key in json
-- ===============================================
UPDATE customers
SET customers_json = JSON_SET(
    customers_json,
    '$.cusromer_rec_id',
    customer_rec_id
)
WHERE customer_rec_id = LAST_INSERT_ID();
-- ===============================================
-- Auth table Started
-- ===============================================

DROP TABLE IF EXISTS auth;

-- ===============================================
-- Create auth table
-- ===============================================
CREATE TABLE IF NOT EXISTS auth (
    auth_rec_id 				INT 				PRIMARY KEY AUTO_INCREMENT,
    parent_table_name 			VARCHAR(50),
    parent_table_rec_id 		INT,
    latest_otp_code 			CHAR(6),
    latest_otp_sent_at 			DATETIME(3),
    latest_otp_expires_at 		DATETIME(3),
    otp_retries 				TINYINT				UNSIGNED DEFAULT 0,
    next_otp_in 				SMALLINT 			UNSIGNED DEFAULT 0,
    auth_json 					JSON,
    row_metadata 				JSON
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- ===============================================
-- Insert Demo row: auth_rec_id = 0
-- ===============================================
INSERT INTO auth (
    auth_rec_id,
    parent_table_name,
    parent_table_rec_id,
    latest_otp_code,
    latest_otp_sent_at,
    latest_otp_expires_at,
    otp_retries,
    next_otp_in,
    auth_json,
    row_metadata
) VALUES (
    0,
    'CUSTOMER',
    1,
    '123456',
    NOW(),
    DATE_ADD(NOW(), INTERVAL 5 MINUTE),
    1,
    60,
    JSON_OBJECT(
        'user_rec_id', 0,   													'_comment_user_rec_id', 'Auto-incremented unique user ID',
        'parent_table_name', 'customers',										'_comment_parent_table_name', 'The parent table this auth belongs to, e.g., customers or employees',
        'parent_table_rec_id', 1,												'_comment_parent_table_rec_id', 'The corresponding record ID in the parent table',
        'latest_otp_code', '123456',											'_comment_latest_otp_code', 'Most recent OTP sent to user',
        'latest_otp_sent_at', NOW(),											'_comment_latest_otp_sent_at', 'Timestamp when OTP was sent',
        'latest_otp_expires_at', DATE_ADD(NOW(), INTERVAL 5 MINUTE),			'_comment_latest_otp_expires_at', 'Timestamp when OTP expires',
        'otp_retries', 0,														'_comment_otp_retries', 'Number of OTP retry attempts',
        'next_otp_in', 60,														'_comment_next_otp_in', 'Seconds before user can request next OTP',
        'two_fa', JSON_OBJECT(
            'is_2FA', true,														'_comment_is_2FA', 'Whether 2FA is enabled',
            '2FA_method', 'SMS',												'_comment_2FA_method', 'Method used for 2FA: SMS, Email, Authenticator app, etc.',
            '2FA_method_value', '+1234567890',									'_comment_2FA_method_value', 'Value used for 2FA (phone, email, app secret)'
        ),
        'login_attempts', JSON_OBJECT(
            'last_login_date', NOW(3),											'_comment_last_login_date', 'Last login date of user',
            'login_attempts_count', 1,											'_comment_login_attempts_count', 'Number of login attempts',
            'login_attempt_minutes', 0,											'_comment_login_attempt_minutes', 'Minutes since last login attempt'
        ),
        'current_session', JSON_OBJECT(
            'latitude', 24.8607,												'_comment_latitude', 'Latitude of current session login',
            'device_id', 'device-001',											'_comment_device_id', 'Device identifier of current session',
            'longitude', 67.0011,												'_comment_longitude', 'Longitude of current session login',
            'ip_address', '192.168.1.1',										'_comment_ip_address', 'IP address of current session',
            'last_login_at', NOW(3),											'_comment_last_login_at', 'Timestamp of last login in this session',
            'session_status', 'ACTIVE',											'_comment_session_status', 'Current session status: ACTIVE, EXPIRED, LOGGED_OUT',
            'user_auth-token', 'abc123xyz456',									'_comment_user_auth_token', 'Authentication token for current session',
            'user_session_id', 'session-001',									'_comment_user_session_id', 'Unique session ID',
            'last_login_device', 'iPhone 14',									'_comment_last_login_device', 'Device used in last login',
            'last_login_method', 'Password + 2FA',								'_comment_last_login_method', 'Method used for last login',
            'session_expires_at', DATE_ADD(NOW(3), INTERVAL 1 HOUR),			'_comment_session_expires_at', 'Expiration timestamp for current session'
        ),
        'password_history', JSON_OBJECT(
            'is_active', true,													'_comment_is_active', 'Whether this password is currently active',
            'password_set_at', NOW(3),											'_comment_password_set_at', 'When password was initially set',
            'password_changed_by', 1,											'_comment_password_changed_by', 'User ID who changed the password',
            'password_change_reason', 'Initial setup',							'_comment_password_change_reason', 'Reason for changing password',
            'last_password_updated_at', NOW(3),									'_comment_last_password_updated_at', 'Timestamp of last password update',
            'password_expiration_date', DATE_ADD(NOW(3), INTERVAL 90 DAY),		'_comment_password_expiration_date', 'When password expires'
        ),
        
        'login_credentials', JSON_OBJECT(
            'pin', '1234',														'_comment_pin', 'Optional PIN for login',
            'password', 'StrongP@ssword1',										'_comment_password', 'User\'s login password (hashed in database)',
            'username', 'johndoe',												'_comment_username', 'Primary username for login',
            'alternate_username', 'john.doe',									'_comment_alternate_username', 'Alternate username for login',
            'is_force_password_change', false,									'_comment_is_force_password_change', 'Whether user must change password at next login'
        ),
        'security_questions', JSON_OBJECT(
            'auth_security_question', 'What is your mother\'s maiden name?',	'_comment_auth_security_question', 'User selected security question',
            'auth_security_answer', 'Khan',										'_comment_auth_security_answer', 'Answer to security question (hashed in DB)'
        ),
        'biometric_authentication', JSON_OBJECT(
            'is_face_id_enabled', true,											'_comment_is_face_id_enabled', 'Whether Face ID is enabled',
            'is_fingerprint_enabled', true,										'_comment_is_fingerprint_enabled', 'Whether fingerprint login is enabled'
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'system',
        'updated_at', NOW(3),
        'updated_by', 'system',
        'status', 'active'
    )
);

-- ===============================================
-- Production row: user_rec_id = 1
-- ===============================================
INSERT INTO auth (
    parent_table_name,
    parent_table_rec_id,
    auth_json,
    row_metadata
) VALUES (
    'Customers',
    NULL,
    JSON_OBJECT(
        'auth_rec_id', NULL,
        'parent_table_name', NULL,
        'parent_table_rec_id', NULL,
        'latest_otp_code', NULL,
        'latest_otp_sent_at', NULL,
        'latest_otp_expires_at', NULL,
        'otp_retries', 0,
        'next_otp_in', 0,
        'two_fa', JSON_OBJECT(
            'is_2FA', NULL,
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
            'device_id', NULL,
            'longitude', NULL,
            'ip_address', NULL,
            'last_login_at', NULL,
            'session_status', NULL,
            'user_auth-token', NULL,
            'user_session_id', NULL,
            'last_login_device', NULL,
            'last_login_method', NULL,
            'session_expires_at', NULL
        ),
        'password_history', JSON_OBJECT(
            'is_active', NULL,
            'password_set_at', NULL,
            'password_changed_by', NULL,
            'password_change_reason', NULL,
            'last_password_updated_at', NULL,
            'password_expiration_date', NULL
        ),
        'login_credentials', JSON_OBJECT(
            'pin', NULL,
            'password', NULL,
            'username', NULL,
            'alternate_username', NULL,
            'is_force_password_change', NULL
        ),
        'security_questions', JSON_OBJECT(
            'auth_security_question', NULL,
            'auth_security_answer', NULL
        ),
        'biometric_authentication', JSON_OBJECT(
            'is_face_id_enabled', NULL,
            'is_fingerprint_enabled', NULL
        )
    ),
    JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', NULL,
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'inactive'
    )
);

-- ===============================================
-- Update primary key in json
-- ===============================================

UPDATE auth
SET auth_json = JSON_SET(
    auth_json,
    '$.auth_rec_id',
    auth_rec_id
)
WHERE auth_rec_id = LAST_INSERT_ID();

-- ===============================================
-- Auth table ended
-- ===============================================


-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';

