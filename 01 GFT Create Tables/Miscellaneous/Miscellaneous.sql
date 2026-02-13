-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- Miscellaneous Module Started

-- ===============================================
-- outbound_messages Table Started
-- ===============================================

DROP TABLE IF EXISTS outbound_msgs;
-- ===============================================
-- Create outbound_messages Table
-- ===============================================
CREATE TABLE IF NOT EXISTS outbound_msgs (
    outbound_msgs_rec_id     		INT                            PRIMARY KEY AUTO_INCREMENT,
    message_guid                 		VARCHAR(100)                   NOT NULL UNIQUE,
    parent_message_table_name    		VARCHAR(100),           
	parent_message_table_rec_id      	INT,                                  
    object_name                  		VARCHAR(100)                   NOT NULL,

    outbound_msgs_json                 	JSON,
    row_metadata                 		JSON
);

-- ===============================================
-- Demo row: out_messages_rec_id = 0
-- ===============================================

INSERT INTO outbound_msgs
SET
    outbound_msgs_rec_id 			= 0,
    message_guid             			= 'MSG-2026-0001',
    parent_message_table_name			= 'Orders',
    parent_message_table_rec_id        	= 0,
    object_name              			= 'orders',

	outbound_msgs_json					= castJson('outbound_msgs'),
    row_metadata						= castJson('row_metadata');

-- ===============================================
-- outbound_messages table ended
-- ===============================================

-- ===============================================
-- Logs Table Started
-- ===============================================

DROP TABLE IF EXISTS logs;
-- ===============================================
-- Create money_manager table
-- ===============================================
CREATE TABLE IF NOT EXISTS logs (
    log_rec_id              	INT                                  PRIMARY KEY AUTO_INCREMENT,
    customer_rec_id         	INT                                  NULL,
    org_employee_rec_id     	INT                                  NULL,
    db_username             	VARCHAR(100)                         NULL,
    logged_by               	VARCHAR(100)                         NOT NULL,
    application_name        	VARCHAR(100)                         NOT NULL,

    logs_json               	JSON,
    row_metadata            	JSON
);

ALTER TABLE logs
ADD CONSTRAINT fk_logs_customer
FOREIGN KEY (customer_rec_id)
REFERENCES customers(customer_rec_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- ===============================================
-- make employee_rec_id after employee table
-- ===============================================
ALTER TABLE logs
ADD CONSTRAINT fk_logs_employee
FOREIGN KEY (org_employee_rec_id)
REFERENCES org_employees(org_employee_rec_id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO logs
SET
    log_rec_id          = 0,
    customer_rec_id     = 0,
    org_employee_rec_id = 0,
    db_username         = 'gft_app_user',
    logged_by           = 'SYSTEM',
    application_name    = 'GFT Web App',

    logs_json		    = JSON_OBJECT(

    /* ===================== Root Level ===================== */
    'log_rec_id', 0,                                         '_comment_log_rec_id', 'Log record ID',
    'customer_rec_id', 0,                                  '_comment_customer_rec_id', 'Customer reference',
    'employee_rec_id', 0,                                   '_comment_employee_rec_id', 'Employee reference',
    'db_username', 'gft_app_user',                            '_comment_db_username', 'Database username',
    'logged_by', 'SYSTEM',                                   '_comment_logged_by', 'Who generated the log',
    'application_name', 'GFT Web App',                        '_comment_application_name', 'Source application',

    /* ===================== Application Context ===================== */
    'application_context', JSON_OBJECT(
        'module_name', 'Orders',                              '_comment_module_name', 'Application module',
        'view_name', 'OrderDetails',                           '_comment_view_name', 'UI view or screen',
        'section_name', 'PaymentSection',                     '_comment_section_name', 'UI section',
        'event_action', 'CLICK',                               '_comment_event_action', 'User action',
        'element_id', 'btnPayNow',                             '_comment_element_id', 'UI element ID',
        'element_value', 'Pay Now',                            '_comment_element_value', 'Element value',
        'action_time', NOW(),                                  '_comment_action_time', 'Action timestamp',
        'action_code', 'ORD_PAY_CLICK',                        '_comment_action_code', 'Business action code',
        'log_type', 'INFO',                                   '_comment_log_type', 'INFO / WARN / ERROR'
    ),

    /* ===================== Database Activity ===================== */
    'database_activity', JSON_OBJECT(
        'db_procedure_name', 'sp_create_order',               '_comment_db_procedure_name', 'Stored procedure',
        'input_params', JSON_OBJECT(
            'order_number', 'ORD-2026-0001'
        ),                                                     '_comment_input_params', 'Procedure inputs',
        'environment_variables', JSON_OBJECT(
            'env', 'PROD',
            'region', 'ME'
        ),                                                     '_comment_environment_variables', 'Runtime environment',
        'db_sql_query', 'INSERT INTO orders ...',              '_comment_db_sql_query', 'Executed SQL',
        'db_response', 'SUCCESS',                               '_comment_db_response', 'DB response'
    ),

    /* ===================== User Device & Location ===================== */
    'user_device_location', JSON_OBJECT(
        'user_device_category', 'Desktop',                    '_comment_user_device_category', 'Desktop / Mobile',
        'user_device_type', 'Chrome Browser',                 '_comment_user_device_type', 'Device type',
        'user_device_id', 'DEV-88392',                         '_comment_user_device_id', 'Device identifier',
        'user_ip_address', '192.168.1.25',                     '_comment_user_ip_address', 'IP address',
        'country', 'Pakistan',                                 '_comment_country', 'Country',
        'city', 'Karachi',                                     '_comment_city', 'City',
        'latitude', 24.860735,                                 '_comment_latitude', 'Latitude',
        'longitude', 67.001137,                                 '_comment_longitude', 'Longitude'
    ),

    /* ===================== URL / Navigation Tracking ===================== */
    'navigation_tracking', JSON_OBJECT(
        'url_hit', '/orders/checkout',                        '_comment_url_hit', 'Visited URL',
        'url_method', 'POST',                                  '_comment_url_method', 'HTTP method',
        'session_id', 'SES-998877',                            '_comment_session_id', 'Session identifier',
        'time_spent', 12.45,                                   '_comment_time_spent', 'Time spent (seconds)'
    ),

    /* ===================== Error & Exception Details ===================== */
    'error_details', JSON_OBJECT(
        'error_type', NULL,                                   '_comment_error_type', 'Exception type',
        'error_code', NULL,                                   '_comment_error_code', 'Error code',
        'error_message', NULL,                                '_comment_error_message', 'Error message',
        'stack_trace', NULL,                                   '_comment_stack_trace', 'Stack trace'
    ),

    /* ===================== External API & Integration Logs ===================== */
    'external_api_logs', JSON_OBJECT(
        'external_api_logs_rec_id', 77,                       '_comment_external_api_logs_rec_id', 'External log ID',
        'interface_id', 'PAY-GATEWAY-01',                     '_comment_interface_id', 'Integration interface',
        'endpoint', '/api/payments/charge',                   '_comment_endpoint', 'API endpoint',
        'http_method', 'POST',                                '_comment_http_method', 'HTTP method',
        'request_payload', JSON_OBJECT(
            'amount', 45838.50,
            'currency', 'USD'
        ),                                                     '_comment_request_payload', 'Request payload',
        'response_payload', JSON_OBJECT(
            'status', 'APPROVED'
        ),                                                     '_comment_response_payload', 'Response payload',
        'status_code', 200,                                   '_comment_status_code', 'HTTP status',
        'execution_time_ms', 842,                             '_comment_execution_time_ms', 'Execution time',
        'correlation_id', 'CORR-2026-00045',                   '_comment_correlation_id', 'Trace ID'
    )
)
,
    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL
    );


-- ===============================================
-- logs table ended
-- ===============================================

-- ===============================================
-- App preferences Table Started
-- ===============================================

DROP TABLE IF EXISTS app_preferences;
-- ===============================================
-- Create money_manager table
-- ===============================================
CREATE TABLE IF NOT EXISTS app_preferences (
    preference_rec_id      INT                                  PRIMARY KEY AUTO_INCREMENT,
    preference_key         VARCHAR(100),                         
    preference_value       VARCHAR(100),                                 

    app_preferences_json    JSON,
    row_metadata            JSON
);


-- ===============================================
-- Demo row app_preferences_rec_id :  = 0
-- ===============================================

INSERT INTO app_preferences
SET
    preference_rec_id 		 = 0,
    preference_key    		 = 'default_currency',
    preference_value  		 = 'USD',

    app_preferences_json	 = JSON_OBJECT(
    
        'preference_rec_id', 0,                                 '_comment_preference_rec_id', 'Auto-increment preference record ID',
        'preference_key', 'default_currency',                   '_comment_preference_key', 'Preference unique key',
        'preference_value', 'USD',                               '_comment_preference_value', 'Preference configured value',

        /* ===================== Application Scope ===================== */
        'application_scope', JSON_OBJECT(
            'application_name', 'GFT',                           '_comment_application_name', 'Application name',
            'module_name', 'GlobalSettings',                     '_comment_module_name', 'Module where preference applies',
            'environment', 'Production',                         '_comment_environment', 'Environment scope (Prod/Test/Dev)'
        ),

        /* ===================== Preference Behavior ===================== */
        'preference_behavior', JSON_OBJECT(
            'is_user_editable', TRUE,                            '_comment_is_user_editable', 'Can user modify this preference',
            'is_system_defined', TRUE,                           '_comment_is_system_defined', 'System-level preference',
            'effective_from', NOW(),                             '_comment_effective_from', 'Preference effective date',
            'effective_until', NULL,                              '_comment_effective_until', 'Expiration date if any'
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'Active'
    );

-- ===============================================
-- App preferences table ended
-- ===============================================


-- ===============================================
-- Document_Management Started
-- ===============================================

DROP TABLE IF EXISTS document_management;
-- ===============================================
-- Create money_manager table
-- ===============================================
CREATE TABLE IF NOT EXISTS document_management (
    document_management_rec_id   INT 		PRIMARY KEY AUTO_INCREMENT,
    customer_rec_id              INT 		NULL,
    org_employee_rec_id          INT 		NULL,

    document_management_json     JSON,
    row_metadata                 JSON
);

   
ALTER TABLE document_management
ADD CONSTRAINT fk_doc_mgmt_customer
        FOREIGN KEY (customer_rec_id)
        REFERENCES customers(customer_rec_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE;

-- ===============================================
-- make employee_rec_id after employee table
-- ===============================================
ALTER TABLE document_management
ADD  CONSTRAINT fk_doc_mgmt_employee
        FOREIGN KEY (org_employee_rec_id)
        REFERENCES org_employees(org_employee_rec_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
        
-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO document_management
SET
    document_management_rec_id  = 0,
    customer_rec_id             = 0,
    org_employee_rec_id             = 0,

    document_management_json    = JSON_OBJECT(
        'document_management_rec_id', 0,                      						'_comment_document_management_rec_id', 'Auto-increment document record ID',
        'customer_rec_id', 0,                                 						'_comment_customer_rec_id', 'Customer record ID',
        'employee_rec_id', 0,                                 						'_comment_employee_rec_id', 'Employee record ID',

        /* ===================== Document Details ===================== */
        'document_details', JSON_OBJECT(
            'doc_type', 'Passport',                            						'_comment_doc_type', 'Type of document',
            'file_name', 'passport_ali_raza.pdf',              						'_comment_file_name', 'File name of the document',
            'file_path', '/uploads/customers/101/passport_ali_raza.pdf',			'_comment_file_path', 'Path where file is stored',
            'mime_type', 'application/pdf',                    						'_comment_mime_type', 'Document MIME type'
        ),

        /* ===================== Status & Lifecycle ===================== */
        'status_lifecycle', JSON_OBJECT(
            'status', 'Active',                                						'_comment_status', 'Document status',
            'is_mandatory', TRUE,                              						'_comment_is_mandatory', 'Is document mandatory?',
            'is_latest_version', TRUE,                         						'_comment_is_latest_version', 'Is this the latest version?',
            'is_deleted', FALSE,                                 					'_comment_is_deleted', 'Has document been deleted?'
        ),

        /* ===================== Time Tracking ===================== */
        'time_tracking', JSON_OBJECT(
            'uploaded_at', NOW(),                               					'_comment_uploaded_at', 'Document upload timestamp',
            'reviewed_at', NULL,                                					'_comment_reviewed_at', 'Document review timestamp',
            'expiry_at', '2031-01-13',                        					    '_comment_expiry_at', 'Document expiry date',
            'last_updated_at', NOW(),                           					 '_comment_last_updated_at', 'Last update timestamp',
            'last_accessed_at', NULL,                            					'_comment_last_accessed_at', 'Last accessed timestamp',
            'deleted_at', NULL,                                   					'_comment_deleted_at', 'Deletion timestamp if deleted'
        ),

        /* ===================== Audit ===================== */
        'audit', JSON_OBJECT(
            'reviewed_by_rec_id', NULL,                          					'_comment_reviewed_by_rec_id', 'Employee who reviewed document',
            'deleted_by_rec_id', NULL,                            					'_comment_deleted_by_rec_id', 'Employee who deleted document',
            'remarks', 'Uploaded during account creation',         					'_comment_remarks', 'Additional remarks'
        ),

        /* ===================== Access & Permission ===================== */
        'access_permissions', JSON_OBJECT(
            'download_allowed_to', JSON_ARRAY('CUSTOMER','COMPLIANCE','ADMIN'), 	'_comment_download_allowed_to', 'Entities allowed to download'
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),                                  
        'created_by', 'SYSTEM',                                 
        'updated_at', NULL,                                     
        'updated_by', NULL,                                     
        'status', 'Active'                                      
    );


-- ===============================================
-- Document table ended
-- ===============================================


DROP TABLE IF EXISTS organization_info;
-- ===============================================
-- Create organization_info table
-- ===============================================
CREATE TABLE IF NOT EXISTS organization_info (
    organization_info_rec_id     INT         	PRIMARY KEY AUTO_INCREMENT,
    organization_name            VARCHAR(255), 	
    primary_email                VARCHAR(255), 	
    primary_phone                VARCHAR(50),

    organizational_info_json     JSON,
    row_metadata                 JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO organization_info
SET
    organization_info_rec_id     = 0,
    organization_name            = 'Demo Organization',
    primary_email                = 'info@demoorg.com',
    primary_phone                = '+1234567890',

    organizational_info_json     = JSON_OBJECT(
    
		'organization_info_rec_id',0,
		'organization_name','Demo Organization',
		'primary_email','info@demoorg.com',
		'primary_phone','+1234567890',
    
        'branding', JSON_OBJECT(
            'tagline', 'Innovation at its Best',                       	'_comment_tagline', 'Organization tagline',
            'logo_url', '/uploads/organization/logo.png',            	'_comment_logo_url', 'URL/path to organization logo',
            'building_image', '/uploads/organization/building.png',  	'_comment_building_image', 'URL/path to building image'
        ),

        /* ===================== Additional Contact Info ===================== */
        'additional_contact_info', JSON_OBJECT(
            'secondary_email', 'support@GFT.com',                		'_comment_secondary_email', 'Secondary email',
            'secondary_phone', '+1987654321',                         	'_comment_secondary_phone', 'Secondary phone',
            'uan_helpline', '+1800123456',                            	'_comment_uan_helpline', 'Universal Access Number',
            'support_whatsapp', '+12345678901',                       	'_comment_support_whatsapp', 'WhatsApp support number',
            'website_url', 'https://www.gft.com',                 		'_comment_website_url', 'Organization website'
        ),

        /* ===================== Address & Location Details ===================== */
        'address_location', JSON_OBJECT(
            'location_address', '123 Demo Street, City, Country',    	'_comment_location_address', 'Full location address',
            'location_ip', '192.168.1.1',                            	 '_comment_location_ip', 'IP address of the organization location',
            'location_lat', '24.8607',                                	'_comment_location_lat', 'Latitude',
            'location_lng', '67.0011',                                	'_comment_location_lng', 'Longitude',
            'business_hours', 'Mon-Fri 9:00-18:00',                  	'_comment_business_hours', 'Business operating hours'
        ),

        /* ===================== Roles / Key Contacts ===================== */
        'roles_key_contacts', JSON_ARRAY(
            JSON_OBJECT(
                'role', 'CEO',                                      '_comment_role', 'Role/Position',
                'role_name', 'Ali Khan',                             '_comment_role_name', 'Name of person',
                'role_phone', '+1234000000',                         '_comment_role_phone', 'Contact number',
                'role_email', 'ali.khan@demoorg.com',               '_comment_role_email', 'Email address'
            ),
            JSON_OBJECT(
                'role', 'CTO',
                'role_name', 'Sara Malik',
                'role_phone', '+1234000001',
                'role_email', 'sara.malik@demoorg.com'
            )
        ),

        /* ===================== Branches ===================== */
        'branches', JSON_ARRAY(
            JSON_OBJECT(
                'branch_name', 'Main Branch',                        '_comment_branch_name', 'Branch name',
                'branch_address', '123 Demo Street, City, Country',  '_comment_branch_address', 'Branch address'
            ),
            JSON_OBJECT(
                'branch_name', 'Secondary Branch',
                'branch_address', '456 Another St, City, Country'
            )
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),                                  
        'created_by', 'SYSTEM',                                 
        'updated_at', NULL,                                     
        'updated_by', NULL                                                                      
    );

-- ===============================================
-- Organization Info table ended
-- ===============================================

DROP TABLE IF EXISTS org_employees;
-- ===============================================
-- Create org_employees table
-- ===============================================
CREATE TABLE IF NOT EXISTS org_employees (
    org_employee_rec_id           INT         	PRIMARY KEY AUTO_INCREMENT,
    first_name                    VARCHAR(100) 	NULL,
    last_name                     VARCHAR(100) 	NULL,
    primary_phone_number          VARCHAR(50)  	NULL,
    primary_email_address         VARCHAR(255) 	NULL,
    primary_whatsapp_number       VARCHAR(50)  	NULL,
    profile_pic                   VARCHAR(255) 	NULL,
    role_designation              VARCHAR(100) 	NULL,
    employee_status               VARCHAR(50)  	NULL,

    employee_json                 JSON,
    row_metadata                  JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO org_employees
SET
    org_employee_rec_id           = 0,
    first_name                    = 'Ali',
    last_name                     = 'Raza',
    primary_phone_number          = '+923001234567',
    primary_email_address         = 'ali.raza@demoorg.com',
    primary_whatsapp_number       = '+923001234567',
    profile_pic                   = '/uploads/employees/ali_raza.png',
    role_designation              = 'Manager',
    employee_status               = 'Active',

    employee_json = JSON_OBJECT(
			'org_employee_rec_id ', 0,
            'employee_rec_id', 0,                                 		'_comment_employee_rec_id', 'Employee record ID',
            'employee_REC_id', 0,                              			'_comment_employee_id', 'DB employee ID',
            'first_name', 'Ali',                                   		'_comment_first_name', 'Employee first name',
            'last_name', 'Raza',                                 	 	'_comment_last_name', 'Employee last name',
            'primary_phone_number', '+923001234567',              		'_comment_primary_phone_number', 'Primary contact number',
            'primary_email_address', 'ali.raza@demoorg.com',      		'_comment_primary_email_address', 'Primary email',
            'primary_whatsapp_number', '+923001234567',           		'_comment_primary_whatsapp_number', 'WhatsApp number',
            'emp_profile_pic', '/uploads/employees/ali_raza.png', 		'_comment_emp_profile_pic', 'Profile picture path',
            'emp_department', 'Operations',                       	 	'_comment_emp_department', 'Department of employee',
            'role_designation', 'Manager',                          	'_comment_role_designation', 'Role or designation',
            'employee_status' ,'Active',
  
        /* ===================== Permissions ===================== */
        'permissions', JSON_OBJECT(
            'access_type', 'Full',                                  '_comment_access_type', 'Level of access',
            'can_manage_product_and_inventory', TRUE,               '_comment_can_manage_product_and_inventory', 'Permission to manage products/inventory',
            'can_post_transactions', TRUE,                          '_comment_can_post_transactions', 'Permission to post transactions',
            'can_manage_app_users', FALSE,                           '_comment_can_manage_app_users', 'Permission to manage app users',
            'can_manage_system_settings', FALSE,                     '_comment_can_manage_system_settings', 'Permission to manage system settings',
            'can_configure_api_configuration', FALSE,                 '_comment_can_configure_api_configuration', 'Permission to configure API settings'
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),                                  
        'created_by', 'SYSTEM',                                 
        'updated_at', NULL,                                     
        'updated_by', NULL                                                                       
    );

-- ===============================================
-- Org Employees table ended
-- ===============================================


-- ===============================================
-- Create promotions table
-- ===============================================
DROP TABLE IF EXISTS promotions;

CREATE TABLE IF NOT EXISTS promotions (
    promotions_rec_id       INT         	PRIMARY KEY AUTO_INCREMENT,
    promo_code              VARCHAR(50) 	NULL,
    
    promotions_json         JSON,
    row_metadata            JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO promotions
SET
    promotions_rec_id       = 0,
    promo_code              = 'WELCOME2026',

    promotions_json         = JSON_OBJECT(
        'title', 'Welcome Bonus',                               '_comment_title', 'Promotion title',
        'description', 'Get 10% off on your first transaction', '_comment_description', 'Promotion description',
        'promo_type', 'Percentage',                              '_comment_promo_type', 'Type of promotion (Percentage/Flat)',
        'discount_value', 10,                                    '_comment_discount_value', 'Discount value',
        'max_discount', 50,                                      '_comment_max_discount', 'Maximum discount applicable',
        'min_transaction_amount', 100,                           '_comment_min_transaction_amount', 'Minimum transaction required',
        'start_date', '2026-01-15',                              '_comment_start_date', 'Promotion start date',
        'end_date', '2026-12-31',                                '_comment_end_date', 'Promotion end date',
        'usage_limit_global', 1000,                               '_comment_usage_limit_global', 'Global usage limit',
        'usage_limit_per_user', 5,                                '_comment_usage_limit_per_user', 'Usage limit per user',
        'status', 'Active',                                       '_comment_status', 'Promotion status',
        'is_first_purchase', TRUE,                                '_comment_is_first_purchase', 'Applicable only on first purchase?',
        'is_zero_fee', FALSE,                                     '_comment_is_zero_fee', 'Is zero fee promotion?',
        'referral_id', NULL,                                      '_comment_referral_id', 'Referral ID if applicable',
        'referral_discount', 5,                                   '_comment_referral_discount', 'Referral discount value',
        'referral_discount_type', 'Percentage',                   '_comment_referral_discount_type', 'Referral discount type',
        'referral_rate', 2,                                        '_comment_referral_rate', 'Referral reward rate'
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL
    );

-- ===============================================
-- Promotions table ended
-- ===============================================

DROP TABLE IF EXISTS gft_ui_metadata;
-- ===============================================
-- Create gft_ui_metadata table
-- ===============================================
CREATE TABLE IF NOT EXISTS gft_ui_metadata (
    gft_rec_id               INT         		PRIMARY KEY AUTO_INCREMENT,
    app_name                 VARCHAR(100) 		NULL,
    view_name                VARCHAR(100) 		NULL,
    object_key               VARCHAR(100) 		NULL,
    object_value             VARCHAR(100) 		NULL,

    gft_ui_metadata_json     JSON,
    row_meta_data            JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO gft_ui_metadata
SET
    gft_rec_id               = 0,
    app_name                 = 'GFT App',
    view_name                = 'Dashboard',
    object_key               = 'welcome_message',
    object_value             = 'Welcome to GFT App!',

    gft_ui_metadata_json     = JSON_OBJECT(
        'gft_rec_id', 0,                                         '_comment_gft_rec_id', 'Auto-increment record ID',
        'app_name', 'GFT App',                                    '_comment_app_name', 'Application name',
        'view_name', 'Dashboard',                                  '_comment_view_name', 'Name of the view or screen',
        'object_key', 'welcome_message',                          '_comment_object_key', 'UI object key identifier',
        'object_value', 'Welcome to GFT App!',                    '_comment_object_value', 'UI object value'
    ),

    row_meta_data = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL
    );

-- ===============================================
-- gft_ui_metadata table ended
-- ===============================================


DROP TABLE IF EXISTS external_interfaces;
-- ===============================================
-- Create external_interfaces table
-- ===============================================
CREATE TABLE IF NOT EXISTS external_interfaces (
    external_interface_rec_id   	INT         								PRIMARY KEY AUTO_INCREMENT,
    `description`                 	VARCHAR(255), 	
    provider_name               	VARCHAR(100), 	
    short_name                  	VARCHAR(50),  
    category                    	VARCHAR(50),  
    billing_info                	JSON,
    access_control              	JSON,
    start_date                  	DATETIME,       
    end_date                    	DATETIME,        
    quota                       	VARCHAR(20),         
    current_status              	ENUM('active', 'inactive', 'expire'),
    is_required_vpn             	BOOLEAN   ,  
    request_parameters          	JSON,
    output                      	JSON,
    
    external_interface_json     	JSON,
    row_metadata                	JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO external_interfaces
SET
    external_interface_rec_id   = 0,
    `description`                 = 'Demo Payment Gateway API',
    provider_name               = 'PayGate',
    short_name                  = 'PAYG',
    category                    = 'Payment',
    billing_info                = JSON_OBJECT('billing_cycle', 'Monthly', 'amount', 100), 
    access_control              = JSON_OBJECT('allowed_roles', JSON_ARRAY('ADMIN','COMPLIANCE')), 
    start_date                  = '2026-01-14',
    end_date                    = '2030-12-31',
    quota                       = 100000,
    current_status              = 'active',
    is_required_vpn             = TRUE,
    request_parameters          = JSON_OBJECT('param1','value1','param2','value2'),
    output                      = JSON_OBJECT('response_code', 200, 'message','Success'),

    external_interface_json     = JSON_OBJECT(
        /* ===================== Top-level Columns ===================== */
        'external_interface_rec_id', 0,                         								'_comment_external_interface_rec_id', 'Auto-increment interface ID',
        'description', 'Demo Payment Gateway API',               								'_comment_description', 'Description of the interface',
        'provider_name', 'PayGate',                               								'_comment_provider_name', 'Provider name',
        'short_name', 'PAYG',                                     								'_comment_short_name', 'Short name/alias',
        'category', 'Payment',                                   								 '_comment_category', 'Category of interface',
        'billing_info', JSON_OBJECT('billing_cycle','Monthly','amount',100), 					'_comment_billing_info', 'Billing information',
        'access_control', JSON_OBJECT('allowed_roles', JSON_ARRAY('ADMIN','COMPLIANCE')), 		'_comment_access_control', 'Access control JSON',
        'start_date', '2026-01-14',                              							 	'_comment_start_date', 'Interface start date',
        'end_date', '2030-12-31',                                								 '_comment_end_date', 'Interface end date',
        'quota', 100000,                                         								'_comment_quota', 'Quota for usage',
        'status', 'Active',                                      								 '_comment_status', 'Current status',
        'is_required_vpn', TRUE,                                  								'_comment_is_required_vpn', 'VPN required?',
        'request_parameters', JSON_OBJECT('param1','value1','param2','value2'), 				'_comment_request_parameters', 'Request parameters JSON',
        'output', JSON_OBJECT('response_code',200,'message','Success'), 						'_comment_output', 'Sample output JSON',

        /* ===================== Credentials ===================== */
        'credentials', JSON_OBJECT(
            'environment', 'Production',                           								'_comment_environment', 'API environment (Dev/Test/Prod)',
            'api_key', 'demo_api_key_123',                         								'_comment_api_key', 'API key for authentication',
            'base_url', 'https://api.paygate.com',                 								'_comment_base_url', 'Base URL for API calls',
            'port', 443,                                           								'_comment_port', 'Port number',
            'status', 'Active',                                    								'_comment_cred_status', 'Status of credentials',
            'client_id', 'client_001',                             								'_comment_client_id', 'Client ID',
            'client_secret', 'secret_001',                         								'_comment_client_secret', 'Client secret',
            'access_token', 'token_12345',                          							'_comment_access_token', 'Access token',
            'token_expiry', '2026-01-15T00:00:00',                 								'_comment_token_expiry', 'Token expiry datetime',
            'extra_config', JSON_OBJECT('timeout',30),            								'_comment_extra_config', 'Any extra configuration',
            'is_active', TRUE,                                      							'_comment_is_active', 'Is credential active?'
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'Active'
    );

-- ===============================================
-- External Interfaces table ended
-- ===============================================

DROP TABLE IF EXISTS company_bank;
-- ===============================================
-- Create company_bank table
-- ===============================================
CREATE TABLE IF NOT EXISTS company_bank (
    company_bank_rec_id          INT         PRIMARY KEY AUTO_INCREMENT,
    company_name                 VARCHAR(255) NULL,
    bank_name                    VARCHAR(255) NULL,
    account_number               VARCHAR(50)  NULL,
    iban                         VARCHAR(50)  NULL,
    branch_name                  VARCHAR(255) NULL,
    branch_address               VARCHAR(255) NULL,
    swift_code                   VARCHAR(50)  NULL,
    
    company_bank_json            JSON,
    row_metadata                 JSON
);

-- ===============================================
-- Demo row log_rec_id :  = 0
-- ===============================================

INSERT INTO company_bank
SET
    company_bank_rec_id          = 0,
    company_name                 = 'Demo Organization',
    bank_name                    = 'Demo Bank',
    account_number               = '1234567890',
    iban                         = 'PK00DEMO1234567890',
    branch_name                  = 'Main Branch',
    branch_address               = '123 Demo Street, City, Country',
    swift_code                   = 'DEMO123',

    company_bank_json            = JSON_OBJECT(
        /* ===================== Bank Details ===================== */
        'company_bank_rec_id', 0,                                '_comment_company_bank_rec_id', 'Auto-increment bank record ID',
        'company_name', 'Demo Organization',                     '_comment_company_name', 'Name of the company',
        'bank_name', 'Demo Bank',                                 '_comment_bank_name', 'Name of the bank',
        'account_number', '1234567890',                           '_comment_account_number', 'Bank account number',
        'iban', 'PK00DEMO1234567890',                             '_comment_iban', 'IBAN number',
        'branch_name', 'Main Branch',                              '_comment_branch_name', 'Branch name',
        'branch_address', '123 Demo Street, City, Country',       '_comment_branch_address', 'Branch address',
        'swift_code', 'DEMO123',                                  '_comment_swift_code', 'SWIFT code',

        /* ===================== E-Wallets ===================== */
        'e_wallets', JSON_ARRAY(
            JSON_OBJECT(
                'wallet_name', 'PayPal',                            '_comment_wallet_name', 'E-wallet provider name',
                'wallet_id', 'PAYPAL001',                            '_comment_wallet_id', 'Wallet account ID',
                'wallet_balance', 1000.00,                           '_comment_wallet_balance', 'Wallet balance',
                'currency', 'USD',                                   '_comment_currency', 'Wallet currency',
                'status', 'Active',                                   '_comment_status', 'Wallet status'
            ),
            JSON_OBJECT(
                'wallet_name', 'Skrill',
                'wallet_id', 'SKRILL001',
                'wallet_balance', 500.00,
                'currency', 'USD',
                'status', 'Active'
            ),
            JSON_OBJECT(
                'wallet_name', 'JazzCash',
                'wallet_id', 'JAZZ001',
                'wallet_balance', 2000.00,
                'currency', 'PKR',
                'account_number', '03001234567',                      '_comment_account_number', 'JazzCash account number',
                'status', 'Active'
            )
        )
    ),

    row_metadata = JSON_OBJECT(
        'created_at', NOW(3),
        'created_by', 'SYSTEM',
        'updated_at', NULL,
        'updated_by', NULL,
        'status', 'Active'
    );

-- ===============================================
-- Company Bank table ended
-- ===============================================

