-- ====================================================================================================================================
-- FUNCTION Name:  castJson()
-- Purpose: Cast the sample json to row 0
-- parameter values: 'corporate_account', 'customer', 'auth', 'customer_wallets', 'tradable_assets', 'asset_rate_history', 
-- 					  'wallet_ledger', 'products', 'inventory', 'money_manager', 'credit_card', 'outbound_messages', 'row_metadata',
--
--
--
-- ====================================================================================================================================
DROP FUNCTION castJson;

DELIMITER $$
CREATE FUNCTION castJson(
						  p_table_name VARCHAR(255)
						)
RETURNS JSON
DETERMINISTIC
BEGIN
		IF p_table_name IS NULL THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Parameter p_table_name must be provided';
		END IF;
		
        CASE p_table_name
-- =======================================================================
-- corporate_account.corporate_account_json
-- =======================================================================
		WHEN 'corporate_account' THEN
			RETURN CAST(
				'{
					"corporate_account_rec_id"        : 0,                                          "_comment_corporate_account_rec_id"         : "Auto-incremented unique corporate account ID",
					"main_account_num"                : "000",                                      "_comment_main_account_num"                 : "Unique corporate account number",
					"main_account_title"              : "azs",                                      "_comment_main_account_title"                : "Corporate main account title",
					"account_status"                  : "inactive",                                 "_comment_account_status"                   : "Current status: registration req, active, inactive, blocked, etc.",


					"status_change_history":[
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "SUBMITTED",                                     "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Account is opened by the customer",             "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "APPROVED",                                      "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "SUSPENDED",                                     "_comment_new_status"                    : "New status after change",
						  "notes"                    : "by Afzaal",                                    "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
						  "notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "CLOSED",                                        "_comment_new_status"                    : "New status after change",
						  "notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
						  }
					  ],          

					"account_admin" : { 
					  "_comment_create_customer_record_with_account_admin_info"                    : "create customer record with this account_admin_info as well",
					  "first_name"                   : "Ali",                                       "_comment_first_name"                      : "First name of primary contact",
					  "last_name"                    : "Raza",                                      "_comment_last_name"                       : "Last name of primary contact",
					  "primary_email"                : "ali.raza@abctraders.com",                   "_comment_primary_email"                   : "Primary contact email",
					  "primary_phone"                : "+92-300-2223344",                           "_comment_primary_phone"                   : "Primary contact phone",
					  "primary_contact"              : "Ali Raza",                                  "_comment_primary_contact"                 : "Primary contact person name",
					  "designation_of_contact"       : "Finance Manager",                           "_comment_designation_of_contact"          : "Designation/title of primary contact"
					},          

					"company" : {
						"company_name"                 : "AZS Traders Pvt Ltd",                        "_comment_company_name"                    : "Full registered name of the company",
						"company_email"                : "info@abctraders.com",                        "_comment_company_email"                   : "Official email of the company",
						"company_phone"                : "+92-300-1234567",                            "_comment_company_phone"                   : "Official phone of the company",
						"company_ntn_number"           : "1234567-8",                                  "_comment_company_ntn_number"              : "National Tax Number of company",
						"company_date_of_incorporation": "2018-06-15",                                 "_comment_company_date_of_incorporation"   : "Date company was incorporated",          

						"owner_info" : {
							"owner_name"                 : "Ahmed Khan",                               "_comment_owner_name"                      : "Name of company owner",
							"owner_email"                : "ahmed.khan@abctraders.com",                "_comment_owner_email"                     : "Email of company owner",
							"owner_phone"                : "+92-300-1112233",                          "_comment_owner_phone"                     : "Phone number of company owner",
							"owner_national_id"          : "35202-3344565-1",                          "_comment_national_id"                     : "CNIC number of company owner"
					  },          

						"company_address" : {
							"google_reference_number"       : "ChIJ1234567890",                        "_comment_google_reference_number"         : "Google Maps reference ID",
							"full_address"                  : "123 Main St, Apt 4B, New York, USA",    "_comment_full_address"                  : "Complete full address",
							"country"                       : "USA",                                   "_comment_country"                        : "Country name",
							"building_number"               : "123",                                   "_comment_building_number"                : "Building number or identifier",
							"street_name"                   : "Main St",                               "_comment_street_name"                    : "Street name",
							"street_address_2"              : "Apt 4B",                                 "_comment_street_address_2"               : "Secondary street info or apartment number",
							"city"                          : "New York",                              "_comment_city"                           : "City name",
							"state"                         : "New York",                              "_comment_state"                          : "State or province",
							"zip_code"                      : "10001",                                 "_comment_zip_code"                       : "Postal/zip code",
							"directions"                    : "Near Central Park",                     "_comment_directions"                     : "Additional directions to the address",
							"cross_street_1_name"           : "2nd Ave",                               "_comment_cross_street_1_name"             : "Nearby cross street 1",
							"cross_street_2_name"           : "3rd Ave",                               "_comment_cross_street_2_name"             : "Nearby cross street 2",
							"latitude"                      : "40.7128",                               "_comment_latitude"                       : "Latitude coordinate",
							"longitude"                     : "-74.006",                               "_comment_longitude"                      : "Longitude coordinate"
					  }
					},          

					"account_stats" : {
						"total Cash Wallet"           : "PKR 5000.00",                                  "_comment_total_cash_wallet"                : "Total cash balance in wallet",
						"total Gold Wallet"           : "230.4567 grams",                               "_comment_total_gold_wallet"                : "Total gold holdings in grams",
						"totla Silver Wallet"         : "1500.7890 grams",                              "_comment_total_silver_wallet"              : "Total silver holdings in grams",  
						"total_orders"                : 1340,                                           "_comment_total_orders"                     : "Total orders placed by the company",
						"total_assets"                : 85000000,                                       "_comment_total_assets"                     : "Total assets of the company",
						"open_tickets"                : 2,                                              "_comment_open_tickets"                     : "Number of open support tickets",
						"num_of_tickets"              : 18,                                             "_comment_num_of_tickets"                   : "Total number of support tickets",
						"num_of_employees"            : 25,                                             "_comment_num_of_employees"                 : "Total employees in company",
						"year_to_date_orders"         : 215,                                            "_comment_year_to_date_orders"              : "Orders placed this year"
					}
					}' AS JSON);

-- =======================================================================
-- customer.customer_json    
-- =======================================================================	
		WHEN 'customer' THEN
			RETURN CAST(
				'{
					"customer_rec_id"                : 0,                                               "_comment_customer_rec_id"                : "Auto-incremented unique customer ID",
					"customer_status"                : "ACTIVE",                                        "_comment_customer_status"                : "Possible values: Active, Pending, Suspended, etc.",
					"customer_type"                  : "CORPORATE",                                     "_comment_customer_type"                  : "PERSONAL or CORPORATE",
					"corporate_account_rec_id"       : 1,                                               "_comment_corporate_account_rec_id"       : "References corporate_accounts table if customer_type is CORPORATE",
					"first_name"                     : "John",                                          "_comment_first_name"                     : "Customer\'s first name",
					"last_name"                      : "Doe",                                           "_comment_last_name"                      : "Customer\'s last name",
					"user_name"                      : "johndoe123",                                    "_comment_user_name"                      : "Unique username for login",
					"email"                          : "john.doe@example.com",                          "_comment_email"                          : "Primary email of the customer",
					"phone"                          : "+1234567890",                                   "_comment_phone"                          : "Primary phone number",
					"whatsapp_number"                : "+1234567890",                                   "_comment_whatsapp_number"                : "WhatsApp contact number",
					"national_id"                    : "331013434343433",                               "_comment_national_id"                    : "Government-issued national ID",
					"main_account_number"            : "AZS-001",                                       "_comment_main_account_number"            : "Main account number for the customer",
					"account_number"                 : "002",                                           "_comment_account_number"                 : "account number for the customer",              



					"cus_profile_pic"                : "https://example.com/profile_pic.jpg",           "_comment_cus_profile_pic"                : "URL to profile picture",
					"is_verified"                    : true,                                            "_comment_is_verified"                    : "Boolean: whether the customer is verified",              

					"status_change_history":[
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "SUBMITTED",                                     "_comment_new_status"                    : "New status after change",
							"notes"                    : "Account is opened by the customer",             "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "APPROVED",                                      "_comment_new_status"                    : "New status after change",
							"notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
							"notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "SUSPENDED",                                     "_comment_new_status"                    : "New status after change",
							"notes"                    : "by Afzaal",                                    "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
							"notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "CLOSED",                                        "_comment_new_status"                    : "New status after change",
							"notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
							}
						],              

					"documents": [
							{
								"document_rec_id"        : 1,                             "_comment_document_rec_id"        : "Auto-incremented unique document record ID",
								"document_name"          : "CNIC",                        "_comment_document_name"          : "Name or type of document",
								"is_verified"            : true,                          "_comment_is_verified"            : "Boolean: whether document is verified",
								"uploaded_at"            : "2026-11-10 09:15",            "_comment_uploaded_at"            : "Timestamp when document was uploaded",
								"verified_at"            : "2026-11-11 10:41",            "_comment_verified_at"            : "Timestamp when document was verified",
								"verified_by"            : "Afzaal",                      "_comment_verified_by"            : "User who verified the document"
							},
							{
								"document_rec_id"        : 2,                             "_comment_document_rec_id"        : "Auto-incremented unique document record ID",
								"document_name"          : "Bank Statement",               "_comment_document_name"          : "Name or type of document",
								"is_verified"            : false,                         "_comment_is_verified"            : "Boolean: whether document is verified",
								"uploaded_at"            : "2026-11-10 11:00",            "_comment_uploaded_at"            : "Timestamp when document was uploaded",
								"verified_at"            : null,                          "_comment_verified_at"            : "Timestamp when document was verified",
								"verified_by"            : null,                           "_comment_verified_by"            : "User who verified the document"
							}
						],              

					"additional_contacts" : [
							{
								"Additional_email_1"         : "j.doe.secondary@example.com",                  "_comment_Additional_email_1"            : "Secondary email for the customer",
								"Additional_phone_1"         : "+1234567891",                                  "_comment_Additional_phone_1"            : "Emergency contact phone number"
							},
							{
								"Additional_email_2"         : "j.doe.secondary@example.com",                  "_comment_Additional_email_2"            : "Secondary email for the customer",
								"Additional_phone_2"         : "+1234567891",                                  "_comment_Additional_phone_2"            : "Emergency contact phone number"
							}
					],             

					"residential_address" : {
							"google_reference_number"       : "ChIJ1234567890",                             "_comment_google_reference_number"         : "Google Maps reference ID",
							"full_address"                  : "123 Main St, Apt 4B, New York, USA",         "_comment_full_address"                    : "Complete full address",
							"country"                       : "USA",                                        "_comment_country"                         : "Country name",
							"building_number"               : "123",                                        "_comment_building_number"                 : "Building number or identifier",
							"street_name"                   : "Main St",                                    "_comment_street_name"                     : "Street name",
							"street_address_2"              : "Apt 4B",                                      "_comment_street_address_2"                : "Secondary street info or apartment number",
							"city"                          : "New York",                                   "_comment_city"                            : "City name",
							"state"                         : "New York",                                   "_comment_state"                           : "State or province",
							"zip_code"                      : "10001",                                      "_comment_zip_code"                        : "Postal/zip code",
							"directions"                    : "Near Central Park",                          "_comment_directions"                      : "Additional directions to the address",
							"cross_street_1_name"           : "2nd Ave",                                    "_comment_cross_street_1_name"             : "Nearby cross street 1",
							"cross_street_2_name"           : "3rd Ave",                                    "_comment_cross_street_2_name"             : "Nearby cross street 2",
							"latitude"                      : "40.7128",                                    "_comment_latitude"                        : "Latitude coordinate",
							"longitude"                     : "-74.006",                                    "_comment_longitude"                       : "Longitude coordinate"
					},              

					"permissions" : {
							"is_buy_allowed"                : true,                                         "_comment_is_buy_allowed"                 : "Boolean: whether buying is allowed",
							"is_sell_allowed"               : true,                                         "_comment_is_sell_allowed"                : "Boolean: whether selling is allowed",
							"is_redeem_allowed"             : false,                                        "_comment_is_redeem_allowed"              : "Boolean: whether redeeming is allowed",
							"is_add_funds_allowed"          : true,                                         "_comment_is_add_funds_allowed"           : "Boolean: whether adding funds is allowed",
							"is_withdrawl_allowed"          : true,                                         "_comment_is_withdrawl_allowed"           : "Boolean: whether withdrawing is allowed"
					},              

					"app_preferences" : {
							"time_zone"                     : "America/New_York",                           "_comment_time_zone"                      : "Preferred time zone",
							"preferred_currency"            : "USD",                                        "_comment_preferred_currency"             : "Preferred currency",
							"preferred_language"            : "en",                                         "_comment_preferred_language"             : "Preferred language",
							"auto_logout_minutes"           : 15,                                           "_comment_auto_logout_minutes"            : "Minutes before automatic logout",
							"remember_me_enabled"           : true,                                         "_comment_remember_me_enabled"            : "Boolean: remember me enabled",
							"default_home_location"         : "New York",                                   "_comment_default_home_location"          : "Default home location in app",
							"biometric_login_enabled"       : true,                                         "_comment_biometric_login_enabled"        : "Boolean: biometric login enabled",
							"push_notifications_enabled"    : true,                                         "_comment_push_notifications_enabled"     : "Boolean: push notifications enabled",
							"transaction_alerts_enabled"    : true,                                         "_comment_transaction_alerts_enabled"     : "Boolean: transaction alerts enabled",
							"email_notifications_enabled"   : true,                                         "_comment_email_notifications_enabled"    : "Boolean: email notifications enabled",
							"is_face_id_enabled"            : true,                                         "_comment_is_face_id_enabled"             : "Whether Face ID is enabled",
							"is_fingerprint_enabled"        : true,                                         "_comment_is_fingerprint_enabled"         : "Whether fingerprint login is enabled"
				} }' AS JSON);

-- =======================================================================
-- customer.customer_json.customer_wallets 
-- =======================================================================
		WHEN 'customer_wallets' THEN
			RETURN CAST(
						 '{
							  "wallet_id":					null,
							  "tradeable_asset_rec_id": 	null,
							  "wallet_title": 				null,
							  "asset_name": 				null,
							  "asset_code": 				null,
							  "wallet_type": 				null,
							  "wallet_status": 				null,
							  "wallet_balance": 			null,
							  "balance_unit": 				null,
							  "balance_last_updated_at": 	null,
							  "blockchain_info": {
									"blockchain_id": 		null,
									"blockchain_name": 		null,
									"blockchain_url": 		null
							}
						} ' AS JSON);

-- =======================================================================
-- auth.auth_json
-- =======================================================================
		WHEN 'auth' THEN
			RETURN CAST(
				'{
					"auth_rec_id"                 : 0,                                          "_comment_auth_rec_id"                 : "Auto-incremented unique auth ID",
					"parent_table_name"           : "customers",                                "_comment_parent_table_name"           : "The parent table this auth belongs to, e.g., customers or employees",
					"parent_table_rec_id"         : 0,                                          "_comment_parent_table_rec_id"         : "The corresponding record ID in the parent table",
					"user_name" 				    :"john@gmail.com",                            "_comment_user_name"                   : "Primary username or email for login",


				"user_mfa" : {
					"is_MFA"                    : true,                                       "_comment_is_2FA"                      : "Whether 2FA is enabled",
					"MFA_method"                : "SMS",                                      "_comment_2FA_method"                  : "Method used for 2FA: SMS, Email, Authenticator app, etc.",
					"MFA_method_value"          : "+1234567890",                              "_comment_2FA_method_value"            : "Value used for 2FA (phone, email, app secret)"
				},

				"login_attempts" : [
					{ 
					"last_login_date"           : "NOW()",                                   "_comment_last_login_date"             : "Last login date of user",
					"login_attempts_count"      : 1,                                         "_comment_login_attempts_count"        : "Number of login attempts",
					"login_attempt_minutes"     : 0,                                         "_comment_login_attempt_minutes"       : "Minutes since last login attempt"
					},
					{ 
					"last_login_date"           : "2026-08-01 09:00",                        "_comment_last_login_date"             : "Last login date of user",
					"login_attempts_count"      : 3,                                         "_comment_login_attempts_count"        : "Number of login attempts",
					"login_attempt_minutes"     : 30,                                        "_comment_login_attempt_minutes"       : "Minutes since last login attempt"
					}
				],

				"current_session" : {
					"latitude"                  : 24.8607,                                    "_comment_latitude"                    : "Latitude of current session login",
					"device_id"                 : "device-001",                               "_comment_device_id"                   : "Device identifier of current session",
					"longitude"                 : 67.0011,                                    "_comment_longitude"                   : "Longitude of current session login",
					"ip_address"                : "192.168.1.1",                              "_comment_ip_address"                  : "IP address of current session",
					"last_login_at"             : "NOW(3)",                                   "_comment_last_login_at"               : "Timestamp of last login in this session",
					"session_status"            : "ACTIVE",                                   "_comment_session_status"              : "Current session status: ACTIVE, EXPIRED, LOGGED_OUT",
					"user_auth-token"           : "abc123xyz456",                             "_comment_user_auth_token"             : "Authentication token for current session",
					"user_session_id"           : "session-001",                              "_comment_user_session_id"             : "Unique session ID",
					"last_login_device"         : "iPhone 14",                                "_comment_last_login_device"           : "Device used in last login",
					"last_login_method"         : "Password + 2FA",                           "_comment_last_login_method"           : "Method used for last login",
					"session_expires_at"        : "DATE_ADD(NOW(3), INTERVAL 1 HOUR)",        "_comment_session_expires_at"          : "Expiration timestamp for current session"
				},

				"login_credentials" : {
				"pin"                       	: "1234",                                     "_comment_pin"                         : "Optional PIN for login",
				"password"                  	: "StrongP@ssword1",                          "_comment_password"                    : "User\'s login password (hashed in database)",
				"username"                  	: "johndoe",                                  "_comment_username"                    : "Primary username for login",
				"alternate_username"        	: "john.doe",                                 "_comment_alternate_username"          : "Alternate username for login",
				"is_force_password_change"  	: false,                                      "_comment_is_force_password_change"    : "Whether user must change password at next login",
				"password_policy" : {
						"min_length"              : 8,                                      "_comment_min_length"                  : "Minimum password length",
						"max_length"              : 64,                                     "_comment_max_length"                  : "Maximum password length",
						"require_uppercase"       : true,                                   "_comment_require_uppercase"           : "Password must contain uppercase letter",
						"require_lowercase"       : true,                                   "_comment_require_lowercase"           : "Password must contain lowercase letter",
						"require_number"          : true,                                   "_comment_require_number"              : "Password must contain numeric digit",
						"require_special_char"    : true,                                   "_comment_require_special_char"        : "Password must contain special character",
						"password_expiry_days"    : 90,                                     "_comment_password_expiry_days"        : "Number of days before password expires",
						"password_history_limit"  : 5,                                      "_comment_password_history_limit"      : "Number of previous passwords disallowed",
						"lockout_attempts"        : 5,                                      "_comment_lockout_attempts"            : "Failed login attempts before lockout",
						"lockout_duration_minutes": 30,                                     "_comment_lockout_duration_minutes"    : "Account lockout duration in minutes",
						"allow_reuse"             : false,                                  "_comment_allow_reuse"                 : "Whether old passwords can be reused",
						"password_strength_level" : "STRONG",                                "_comment_password_strength_level"    : "Password strength classification"
				}
				},

				"security_questions" :[
					{
					"auth_security_question"    : "What is your mother\'s maiden name?",       "_comment_auth_security_question"     : "User selected security question",
					"auth_security_answer"      : "Khan",                                     "_comment_auth_security_answer"        : "Answer to security question (hashed in DB)"
				},
				{
					"auth_security_question"    : "What is your mother\'s maiden name?",       "_comment_auth_security_question"     : "User selected security question",
					"auth_security_answer"      : "Khan",                                     "_comment_auth_security_answer"        : "Answer to security question (hashed in DB)"
				}
				]
				}' AS JSON);

-- =======================================================================
-- tradeable_assets.tradeable_assets_json
-- =======================================================================		
		WHEN 'tradable_assets' THEN
			RETURN CAST(
						 '
                         {
							"asset_rec_id"              : 0,                              "_comment_commodity_rec_id"            : "Primary ID",
							"asset_name"                : "Gold",                         "_comment_comm_name"                   : "Commodity name",
							"short_name"                : "gold",                         "_comment_comm_code"                   : "Short code",
							"asset_code"                : "GLD",                          "_comment_internal_code"               : "Internal asset code",
							"asset_intl_code"           : "XAU",                          "_comment_commodity_code"              : "Commodity code",
							"asset_type"                : "Metal",                        "_comment_comm_type"                   : "metal, crptocurrency, fiat, currency",
							"forex_code"                : "XAU",                          "_comment_forex_code"                  : "Foreign exchange code",
							"available_to_customers"    : true,                           "_comment_available_to_customers"      : "Is available for customers",
							"tradeable_json"            : "{}",                           "_comment_tradeable_json"              : " tradeable assets all columns json",

							"how_to_measure"             : "by_weight",                   "_comment_how_to_measure"              : "by_weight, by number",
							"standard_units"             : "gram",                        "_comment_standard_weight_units"       : "grams, QTY etc",
							"min_order"                  : 1.0,                           "_comment_minimum_order_weight"        : "Minimum order weight",
							"max_order"                  : 10000.0,                       "_comment_max_order_weight"            : "Maximum order weight",
							"minimum_reedem_level"       : "1 g",                         "_comment_minimum_reedem_level"        : "Minimum redeem level",
							"max_reedem_level"           : "10 toz",                      "_comment_max_reedem_level"            : "Max Redeem Level",
                            
                               "transaction_fee":{
									"buy":                  230.00,                          "_comment_buy_fee"                    : "Transaction fee for buying per unit",
									"sell":                 150.00,                          "_comment_sell_fee"                   : "Transaction fee for selling per unit",
									"redeem":               100.00,                          "_comment_redeem_fee"                 : "Transaction fee for redeeming per unit"
								},
							"taxes" : {
								"GST"                    : "18%",                         "_comment_GST"                         : "Goods and Service Tax in percent",
								"withholding_tax"        : "10%",                         "_comment_withholding_tax"             : "Withholding tax in percent",
								"Import_Duty"            : 5,                             "_comment_ImportDuty"                  : "Import duty in percent",
								"Luxury_Tax"             : 2,                             "_comment_LuxuryTax"                   : "Luxury tax percent if applicable"
							},

							"stats" : {
								"bullion_weight_available": 5000.0,                         "_comment_bullion_weight_available"    : "Total bullion weight available in grams",
								"products_weight"         : 1500.0,                         "_comment_products_weight"             : "Weight of ready products available"
							},

							"spot_rate" : {
								"updated_at"              : "2026-01-16T06:00:00Z",         "_comment_updated_at"               : "Timestamp of last spot rate update",
								"api_name"                : "metals-api",                   "_comment_api_name"                 : "API providing spot rate",
								"url"                     : "https://metals-api.com/",      "_comment_url"                  : "API endpoint URL",
								"unit"                    : "gram",                         "_comment_unit"                     : "Unit for spot rate",
								"current_rate"            : 4433.85,                        "_comment_current_rate"              : "Current market rate",
								"currency"                : "USD",                          "_comment_currency"                  : "Currency of rate",
								"quality"                 : "24K",                          "_comment_quality"                   : "Purity or quality of the commodity"
							},
							"media_library" : [
									{
										"url"               : "https://example.com/images/gold_front.jpg",
										"description"       : "Front view of Gold Bar",
										"uploaded_at"       : "2024-05-20T09:15:00Z"
									},
									{
										"url"               : "https://example.com/images/gold_side.jpg",
										"description"       : "Side view of Gold Bar",
										"uploaded_at"       : "2024-05-22T11:45:00Z"
									}
						]
						}' AS JSON);
 
-- =======================================================================
-- asset_rate_history.asset_rate_history_json
-- =======================================================================
		WHEN 'asset_rate_history' THEN
			RETURN CAST(
						 '{
							"asset_rate_rec_id"          : 0,                                 "_comment_commodity_rate_rec_id"      : "Auto-incremented asset_rate record ID",
							"tradable_assets_rec_id"     : 0,                                 "_comment_commodity_rec_id"           : "Primary key to tradeable asset",
							"asset_code"                 : "GLD",                             "_comment_internal_code"              : "Internal asset code",

							"spot_rate"                  : 4433.85,                           "_comment_spot_rate"                  : "Spot market rate",
							"weight_unit"                : "gram",                            "_comment_weight_unit"                : "Unit of weight for the rate",
							"currency_unit"              : "USD",                             "_comment_currency_unit"              : "Currency of the rate",
							"rate_timestamp"             : "2026-01-16T06:00:00",             "_comment_rate_timestamp"             : "Timestamp when rate was recorded",
							"effective_date"             : "2026-01-16",                      "_comment_effective_date"             : "Date when rate becomes effective",
							"valid_until"                : "2026-01-17",                      "_comment_valid_until"                : "Expiry date of this rate",

							"source_info"                : 
								{
								"rate_source"            : "metals-api",                       "_comment_rate_source"                : "API or source name",
								"source_url"             : "https://metals-api.com/",          "_comment_source_url"                 : "Source URL",
								"market_status"          : "Open",                             "_comment_market_status"              : "Market status",
								"update_frequency"       : "Daily",                            "_comment_update_frequency"           : "Frequency of updates"
								},

							"foreign_exchange"           : 
								{
								"foreign_exchange_rate"  : 278.50,                             "_comment_foreign_exchange_rate"     : "FX conversion rate",
								"foreign_exchange_source": "OpenExchange",                     "_comment_foreign_exchange_source"   : "FX rate source"
								}
						}' AS JSON);

-- =======================================================================
-- wallet_ledger.wallet_ledger_json
-- ======================================================================= 
		WHEN 'wallet_ledger' THEN
			RETURN CAST(
						'
                        {
							"wallet_ledger_rec_id"        : 0,                              "_comment_wallet_ledger_rec_id"        : "Auto-incremented ledger ID",
							"customer_rec_id"             : 0,                              "_comment_customer_wallet_rec_id"      : "Foreign key to customer_wallets",
							"account_number"              : null,                           "_comment_customer_name"               : "customer account number",
							"wallet_id"                  :  0,                              "_comment_wallet_id"                   : "sequence number",
							"wallet_title"                : null,                           "_comment_wallet_title"                : "Wallet title",
							"asset_code"                  : null,                           "_comment_asset_code"                  : "Asset code LIKE gld",
							"asset_name"                  : null,                           "_comment_asset_name"                  : "Asset name like Gold",
							"order_rec_id"                : null,                           "_comment_order_rec_id"                : "Foreign key to orders table",
							"order_number"                : null,                           "_comment_order_number"                : "order number: Sequence number",  
							"transaction_type"            : "debit",                        "_comment_transaction_type"            : "debit or credit or open",

							"ledger_transaction" : {
								"transaction_number"      : null,                           "_comment_transaction_number"          : "Unique transaction number: Sequence number",
								"transaction_at"          : null,                           "_comment_transaction_at"              : "Timestamp of transaction",
								"transaction_reason"      : null,                           "_comment_transaction_reason"          : "Reason for transaction",
								"balance_before"         : null,                            "_comment_opening_balance"             : "Balance before transaction",
								"debit_amount"            : null,                           "_comment_debit"                       : "Debited amount",
								"credit_amount"           : null,                           "_comment_credit"                      : "Credited amount",
								"balance_after"         : null,                             "_comment_current_balance"             : "Balance after transaction"
							},

							"initiated_by_info" : {
								"initiated_by"            : null,                           "_comment_initiated_by"                : "User who initiated transaction",
								"initiated_by_name"       : null,                           "_comment_initiated_by_name"          : "Name of initiator"
							},

							"approval_info" : {
								"approved_at"             : null,                           "_comment_approved_at"                 : "Timestamp of approval",
								"approved_by_rec_id"      : null,                           "_comment_approved_by_rec_id"          : "Approver ID",
								"approved_by_name"        : null,                           "_comment_approved_by_name"            : "Approver name",
								"approval_number"         : null,                           "_comment_approval_number"             : "Approval reference number"
							},

							"contract_info" : {
								"contract_number"         : null,                           "_comment_contract_number"             : "Contract reference number"
							},

							"blockchain_info" : {
								"blockchain_id"           : null,                           "_comment_blockchain_id"               : "Blockchain record ID",
								"blockchain_name"         : null,                           "_comment_blockchain_name"             : "Blockchain name",
								"blockchain_url"          : null,                           "_comment_blockchain_url"              : "Blockchain explorer URL"
							}
						}' AS JSON);

-- =======================================================================
-- products.products_json
-- =======================================================================
		WHEN 'products' THEN
			RETURN CAST(
						'{
							"product_rec_id":               0,                                             "_comment_product_rec_id":             "Auto-increment product record ID",
							"tradable_assets_rec_id":       0,                                             "_comment_tradable_assets_rec_id":     "Linked tradable_assets record",
							"asset_code":                   "GLD",                                         "_comment_asset_code":                 "Owning company code like GLD for gold, SLV for silver, etc.",
							"product_code":                 "PG-3344" ,                                    "_comment_product_code":               "Unique User typed product code",
							"product_type":                 "bar",                                         "_comment_product_type":               "product type values: bar, jewellry",
							"product_name":                 "Gold Bar 10g",                                "_comment_product_name":               "Full product name",

							"product_short_name":           "GB10",                                        "_comment_product_short_name":        "Short display name",
							"product_description":          "24K pure gold bar",                           "_comment_product_description":       "Detailed product description",
							"product_classification":       "Bar",                                         "_comment_product_classification":    "Product classification",
							"asset_type":                   "Gold",                                        "_comment_asset_type":                "Type of asset like Gold, silver , etc",
							"product_quality":              "24K",                                         "_comment_product_quality":           "Metal purity or quality",
							"approximate_weight":           10.0,                                          "_comment_approximate_weight":        "Approximate product weight",
							"weight_unit":                  "gram",                                        "_comment_weight_unit":               "Weight unit",
							"dimensions":                   "25mm x 15mm x 2mm",                           "_comment_dimensions":                "Physical dimensions",
							"is_physical":                  true,                                          "_comment_is_physical":               "Indicates if product is physical",
							"is_SliceAble":                 false,                                         "_comment_is_SliceAble":              "Indicates if product can be sliced",
							"standard_price":               650.00,                                        "_comment_approximat_price":          "Approximate selling price",
							"standard_premium":             15.00,                                         "_comment_standard_premium":          "Standard premium over spot",
							"price_currency":               "USD",                                         "_comment_price_currency":            "Price currency",

							"applicable_taxes":[
								{ 
								"tax_name":                 "Sales Tax",                                   "_comment_tax_name":                  "Applicable tax name",
								"taxes_description":        "Some description of tax",                     "_comment_taxes_description":         "Tax details description",
								"amount":                   5,                                             "_comment_amount":                    "Tax amount", 
								"fixed or perecent":        "percentage",                                  "_comment_fixed_or_perecent":         "Is tax fixed amount or percentage" 
								}
							],

							"quantity_on_hand":             100,                                           "_comment_quantity_on_hand":          "Available stock quantity",
							"minimum_order_quantity":       1,                                             "_comment_minimum_order_quantity":    "Minimum order quantity",
							"total_sold":                   250,                                           "_comment_total_sold":                "Total units sold",
							"offer_to_customer":            true,                                          "_comment_offer_to_customer":         "Is product available for sale",
							"display_order":                1,                                             "_comment_display_order":             "Determines sorting order on the mobile app list. Lower numbers appear first.",
							"Alert_on_low_stock":           true,                                          "_comment_Alert_on_low_stock":        "Low stock alert flag",

							"media_library": [
								{
									"media_type":           "image",                                       "_comment_media_type":                "Type of media (image | video | document | certificate)",
									"media_url":            "/media/products/gold_bar_10g_xl.png",         "_comment_media_url":                 "Media file path or URL",
									"is_featured":          true,                                          "_comment_is_featured":               "featured display media"
								},
								{
									"media_type":           "image",                                       
									"media_url":            "/media/products/gold_bar_10g_sm.png",         
									"is_featured":          true                                          
								},
								{
									"media_type":           "certificate",
									"media_url":            "/media/products/gold_bar_cert.pdf",
									"is_featured":          false
								}
							],

							"transaction_fee": {
								"fee_type":                 "percentage",                                  "_comment_fee_type":                  "Fee type (percentage/fixed)",
								"fee_value":                1.5,                                           "_comment_fee_value":                 "Transaction fee value",
								"fee_currency":             "USD",                                         "_comment_fee_currency":              "Currency for fixed fee",
								"fee_description":          "Platform transaction charges",                "_comment_fee_description":           "Fee explanation"
							}
						}' AS JSON);

-- =======================================================================
-- inventory.inventory_json
-- =======================================================================
		WHEN 'inventory' THEN
			RETURN CAST(
						'{
							"inventory_rec_id":            0,                                              "_comment_inventory_rec_id":           "Auto-increment inventory record ID",
							"product_rec_id":              0,                                              "_comment_product_rec_id":             "Linked product record ID",
							"item_name":                   "Gold Bar - 1000g",                             "_comment_item_name":                  "Inventory item name",
							"item_type":                   "Bar",                                          "_comment_item_type":                  "Inventory item type like: Bar,Gold Ring, Bracelet, Locket, Jwellery etc",
							"asset_type":                  "Gold",                                         "_comment_asset_type":                 "Type of asset like Gold, silver , etc",  
							"availability_status":         "Available",                                    "_comment_availability_status":        "Current availability status like: Available,Sold, redeemed, Slice Bought",



							"item_Size":                    "2 inches",                                    "_comment_Size":                       "like ring size",
							"weight_adjustment":            0.5,                                           "_comment_weight_adjustment":          "Weight adjustment applied",
							"net_weight":                   1000.0,                                        "_comment_net_weight":                 "Net usable weight",
							"available_weight":             330.00,                                        "_comment_available_weight":           "Remaining available weight",
							"item_quality":                 "24K",                                         "_comment_item_quality":               "Quality of the item",
							"location_details":             "dollman ",                                    "_comment_location_details":           "Physical storage location details",
						 
							"pricing_adjustments": {
								"item_margin_adjustment":    1.2,                                           "_comment_item_margin_adjustment":     "Margin adjustment percentage",
								"Discount":                  0.5,                                           "_comment_Discount":                   "Discount percentage",
								"Promotions":                "Ramadan Offer",                               "_comment_Promotions":                 "Active promotion details"
							},

							"media_library": [
								{
									"media_type":            "image",                                       "_comment_media_type":                 "Media type",
									"media_url":             "/media/inventory/item1.png",                  "_comment_media_url":                  "Media file URL",
									"is_featured":           true,                                          "_comment_is_featured":                "Primary media flag"
								}
							],

							"ownership_metrics": {
								"weight_sold_so_far":       770.00,                                        "_comment_weight_sold":                "Total weight sold already",
								"number_of_shareholders":    3,                                             "_comment_number_of_shareholders":     "Total shareholders",
								"number_of_transactions":    12,                                            "_comment_number_of_transactions":     "Total transactions count"
							},

							"manufacturer_info": {
								"manufacturing_country":     "Switzerland",                                 "_comment_manufacturing_country":      "Country of manufacture",
								"manufacturer_name":         "Valcambi",                                    "_comment_manufacturer_name":          "Manufacturer name",
								"manufacturing_date":        "2025-01-10",                                  "_comment_manufacturing_date":         "Manufacturing date",
								"serial_number":             "VAL-1000G-001",                               "_comment_serial_number":              "Unique serial number",
								"serial_verification_url":   "https://verify.valcambi.com/VAL-1000G-001",   "_comment_serial_verification_url":    "Verification URL",
								"serial_verification_text":  "Verified",                                    "_comment_serial_verification_text":   "Verification status",
								"dimensions":                "120mm x 55mm x 9mm",                          "_comment_dimensions":                 "Physical dimensions"
							},

							"purchase_from": {
								"purchase_from_rec_id":      22,                                            "_comment_purchase_from_rec_id":       "Supplier record ID",
								"receipt_number":            "RCPT-8899",                                   "_comment_receipt_number":             "Purchase receipt number",
								"receipt_date":              "2025-10-05",                                  "_comment_receipt_date":               "Receipt date",
								"from_name":                 "ABC Bullion Ltd",                             "_comment_from_name":                  "Supplier name",
								"from_address":              "Dubai, UAE",                                  "_comment_from_address":               "Supplier address",
								"from_phone":                "+971000000",                                  "_comment_from_phone":                 "Supplier phone",
								"from_email":                "sales@abc.com",                               "_comment_from_email":                 "Supplier email",
								"purchase_date":             "2025-10-05",                                  "_comment_purchase_date":              "Purchase date",
								"packaging":                 "Sealed",                                      "_comment_packaging":                  "Packaging details",
								"metal_rate":                63.5,                                          "_comment_metal_rate":                 "Metal rate at purchase",
								"metal_weight":              10.0,                                          "_comment_metal_weight":               "Metal weight purchased",
								"making_charges":            5.0,                                           "_comment_making_charges":             "Making charges",
								"premium_paid":              10.0,                                          "_comment_premium_paid":               "Premium paid",
								"total_tax_paid":            3.5,                                           "_comment_total_tax_paid":             "Total tax paid",
								"tax_description":           "Import tax",                                  "_comment_tax_description":            "Tax description",
								"total_price_paid":          650.0,                                         "_comment_total_price_paid":           "Total amount paid",
								"mode_of_payment":           "Bank Transfer",                               "_comment_mode_of_payment":            "Payment method",
								"check_or_transaction_no":   "TXN-778899",                                  "_comment_check_or_transaction_no":    "Payment reference"
							},

							"sold_to": [
										{
											"order_date":             "2025-11-01",                                 "_comment_order_date":                 "Order date",
											"order_number":           "ORD-1001",                                   "_comment_order_number":               "Order number",
											"receipt_number":         "SR-1001",                                    "_comment_receipt_number":             "Sales receipt number",
											"sold_date":              "2025-11-02",                                 "_comment_sold_date":                  "Sold date",
											"sold_to_id":              501,                                         "_comment_sold_to_id":                 "Customer ID",
											"sold_to_name":            "Ali Khan",                                  "_comment_sold_to_name":               "Customer name",
											"sold_to_phone":           "+923001112233",                             "_comment_sold_to_phone":              "Customer phone",
											"sold_to_email":           "ali@email.com",                             "_comment_sold_to_email":              "Customer email",
											"sold_to_address":         "Karachi",                                   "_comment_sold_to_address":            "Customer address",
											"metal_rate":              65.0,                                        "_comment_metal_rate":                 "Metal rate at sale",
											"weight_sold":             2.5,                                         "_comment_weight_sold":                "Weight sold",
											"making_charges":          2.0,                                         "_comment_making_charges":             "Making charges",
											"premium_charged":         5.0,                                         "_comment_premium_charged":            "Premium charged",
											"taxes":                   1.2,                                         "_comment_taxes":                      "Taxes charged",
											"taxes_description":       "Sales tax",                                 "_comment_taxes_description":          "Tax description",
											"total_price_charged":     180.0,                                       "_comment_total_price_charged":        "Total charged amount",
											"transaction_details": 
											{
												"transaction_num":         "TXN-555666",                                  "_comment_transaction_num":            "Unique transaction number",
												"fee_type":                  "percentage",                                  "_comment_fee_type":                  "Fee type (percentage/fixed)",
												"fee_value":                 1.5,                                           "_comment_fee_value":                 "Transaction fee value",
												"fee_currency":              "USD",                                         "_comment_fee_currency":              "Currency for fixed fee",
												"fee_description":           "Platform transaction charges",                "_comment_fee_description":           "Fee explanation",
												"transaction_status":        "Completed",                                   "_comment_transaction_status":        "Transaction status"
										}
									}

							]

						}' AS JSON);

-- =======================================================================
-- money_manager.money_manager_json
-- =======================================================================
		WHEN 'money_manager' THEN
			RETURN CAST(
						'{
							"money_manager_rec_id"       : 0,
							"customer_rec_id"            : 1,
							"status"                     : "INITIATED",                  	"_comment_status"                   : "Current status of the transaction",                   
							"account_number"             : "azs-001",            	        "_comment_account_number"           : "Customer account number",
							"request_type"               : "Deposit",                    	"_comment_request_type"             : "Type of money manager request like deposit, withdrawal, transfer",  
							"transaction_type"           : "Bank Transfer",              	"_comment_transaction_type"         : "Type of transaction: Cash Deposit, Bank transfer, Check deposite, e-wallets, credit_card. ",
							"backoffice_post_number"     : "GFT-2026-0001",                 "_comment_back_office_post_num"     : "Back office posting number" ,
							"trans_posted_at"            : "2026-01-16T06:00:00",           "_comment_trans_posted_at"          : "Transaction posting timestamp",



							"life_cycle": [
								{
									"status":    "INITIATED",                      "_comment_status"                : "Initial status when transaction is created",
									"user_name": "ali.raza@gmail.com",             "_comment_user_name"             : "login id of user who created the transaction",
									"action_by": "Ali Raza",                       "_comment_action_by"             : "name of user who initiated the transaction: CUSTOMER",
									"action_at": "2026-01-14 14:04:39",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":      null,                            "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "PROCESSED",                      "_comment_status"                : "Status when transaction is processed",
									"user_name": "zain.ahmad@gmail.com",           "_comment_user_name"             : "login id of user who processed the transaction",
									"action_by": "Zain Ahmed",                     "_comment_action_by"             : "name of user who processed the transaction: CUSTOMER",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     null,                             "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "REVIEWED",                       "_comment_status"                : "Status when transaction is reviewed",
									"user_name": "sara.khan@gmail.com",            "_comment_user_name"             : "login id of user who review the transaction",
									"action_by": "Sara Khan",                      "_comment_action_by"             : "name of user who reviewed the transaction: MANAGER REVIEW",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     null,                             "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "APPROVED / REJECTED",            "_comment_status"                : "Status when transaction is approved OR rejected: FINAL APPROVAL BY MANAGER",
									"user_name": "sara.khan@gmail.com",            "_comment_user_name"             : "login id of user who approved or reject the transaction",
									"action_by": "Kamran Iqbal",                   "_comment_action_by"             : "name of user who approved the transaction",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     "approved: all data correct",     "_comment_Notes"                 : "Additional notes or comments"
								}
							],

								
							"sender_info" : {
								"initiated_by"           : "Ali Raza",               	    "_comment_initiated_by"            : "Company employee who initiated the transaction",   
								"institution_name"       : "Bank Al Habib",        		    "_comment_institution_name"        : "Name of sending institution",
								"account_holder_name"    : "Ali Raza",             		    "_comment_account_holder_name"     : "Sender account holder name",
								"account_number"         : "ACC-123456",            	    "_comment_account_number"          : "Sender account number",
								"amount_sent"            : 45838.50,                	    "_comment_amount_sent"             : "Amount sent by sender",
								"transaction_id"         : "TXN-2026-001",          	    "_comment_transaction_id"          : "Transaction reference ID",
								"receipt_number"         : "RCT-2026-0001",         	    "_comment_receipt_number"          : "Receipt number for the transaction",
								"receipt_picture_rec_id" : 501,                    		    "_comment_receipt_picture_rec_id"  : "Reference ID for receipt picture",
								"trans_at"               : "2026-01-14 14:04:39",   	    "_comment_trans_at"                : "Transaction timestamp"
							},

							"receiver_info" : {
								"institution_name"       : "Meezan Bank",           	    "_comment_institution_name"        : "Name of receiving institution",
								"account_holder_name"    : "GFT Company",          		    "_comment_account_holder_name"     : "Receiver account holder name",
								"account_number"         : "ACC-987654",            	    "_comment_account_number"          : "Receiver account number",
								"amount_received"        : 45838.50,                	    "_comment_amount_received"         : "Amount received",
								"received_at"            : "2026-01-16 06:00:00",   	    "_comment_received_at"             : "Timestamp when amount received",
								"processing_fee"         : 25.00,                   	    "_comment_processing_fee"          : "Fee charged for processing"
							}
						}' AS JSON);

-- =======================================================================
-- credit_card.credit_card_json
-- =======================================================================
		WHEN 'credit_card' THEN
			RETURN CAST(
						'{
							"credit_card_rec_id"       : 0,
							"money_manager_rec_id"     : 0,
                            "status"                   : "INITIATED",                  	"_comment_status"                   : "Current status of the transaction",                   
							"account_number"           : "CUS-001",                     "_comment_account_number"           : "Unique customer account identifier",
							"processor_name"           : "Visa Processor",              "_comment_processor_name"           : "Name of the payment processor",
							"processor_token"          : "tok_1A2B3C4D5E6F",            "_comment_processor_token"          : "Token provided by the payment processor",
							"card_last_4"              : "1234",                        "_comment_card_last_4"              : "Last 4 digits of the card number",
							"trans_posted_at"          : "2026-01-16T06:00:00",         "_comment_trans_posted_at"          : "Transaction posting timestamp",
							"backoffice_post_number"   : "BOP-2026-0005",               "_comment_backoffice_post_number"   : "Backoffice posting reference number",
							

							"card_info": {
								"card_type"             : "Visa",                       "_comment_card_type"                : "Type of card: Visa, Mastercard, etc.",
								"card_number"           : "**** **** **** 1234",        "_comment_card_number"              : "Masked card number",
								"card_holder_name"      : "Ali Raza",                   "_comment_card_holder_name"         : "Name on card",
								"card_expiration_date"  : "12/2028",                    "_comment_card_expiration_date"     : "Card expiry date",
								"cvv2"                  : "932",                        "_comment_cvv2"                     : "Masked CVV2",

								"billing_address": {
									"billing_country"       : "Pakistan",                   "_comment_billing_country"          : "Country for billing",
									"billing_address1"      : "Shahrah-e-Faisal",           "_comment_billing_address1"         : "Primary billing address line",
									"billing_address2"      : "Business Plaza",             "_comment_billing_address2"         : "Secondary billing address line",
									"billing_city"          : "Karachi",                    "_comment_billing_city"             : "Billing city",
									"billing_state"         : "Sindh",                      "_comment_billing_state"            : "Billing state or province",
									"billing_zip_code"      : "75400",                      "_comment_billing_zip_code"         : "Billing postal code"
								}
							},

							"bank_approval": {
								"approval_number"       : "APR-00077",                  "_comment_approval_number"          : "Bank approval reference",
								"approval_at"           : "2026-01-16T06:00:00",        "_comment_approval_at"              : "Approval timestamp",
								"settlement_amount"     : 45838.50,                     "_comment_settlement_amount"        : "Settled amount",
								"settlement_date"       : "2026-01-16T06:00:00",        "_comment_settlement_date"          : "Settlement date"
							},

							"life_cycle": [
								{
									"status":    "INITIATED",                      "_comment_status"                : "Initial status when transaction is created",
									"user_name": "ali.raza@gmail.com",             "_comment_user_name"             : "login id of user who created the transaction",
									"action_by": "Ali Raza",                       "_comment_action_by"             : "name of user who initiated the transaction: CUSTOMER",
									"action_at": "2026-01-14 14:04:39",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":      null,                            "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "PROCESSED",                      "_comment_status"                : "Status when transaction is processed",
									"user_name": "zain.ahmad@gmail.com",           "_comment_user_name"             : "login id of user who processed the transaction",
									"action_by": "Zain Ahmed",                     "_comment_action_by"             : "name of user who processed the transaction: CUSTOMER",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     null,                             "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "REVIEWED",                       "_comment_status"                : "Status when transaction is reviewed",
									"user_name": "sara.khan@gmail.com",            "_comment_user_name"             : "login id of user who review the transaction",
									"action_by": "Sara Khan",                      "_comment_action_by"             : "name of user who reviewed the transaction: MANAGER REVIEW",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     null,                             "_comment_Notes"                 : "Additional notes or comments"
								},
								{
									"status":    "APPROVED / REJECTED",            "_comment_status"                : "Status when transaction is approved OR rejected: FINAL APPROVAL BY MANAGER",
									"user_name": "sara.khan@gmail.com",            "_comment_user_name"             : "login id of user who approved or reject the transaction",
									"action_by": "Kamran Iqbal",                   "_comment_action_by"             : "name of user who approved the transaction",
									"action_at": "2026-01-14 16:10:00",            "_comment_action_at"             : "Timestamp when the action was taken",
									"Notes":     "approved: all data correct",     "_comment_Notes"                 : "Additional notes or comments"
								}
							]
						}' AS JSON);

-- =======================================================================
-- outbound_msgs.outbound_msgs_json
-- =======================================================================
		WHEN 'outbound_msgs' THEN
			RETURN CAST(
						'{
							"outbound_msgs_rec_id":        0,                                           "_comment_outbound_messages_rec_id":       "Message record ID",
							"message_guid":                    "MSG-2026-0001",                             "_comment_message_guid":                   "Unique message GUID",
							"parent_message_table_name":       "Orders",
							"parent_message_table_rec_id":     0,
							"object_name":                     "orders",                                   "_comment_object_name":                    "Related business object",

							"business_context": {
								"module_name":                 "Order Management",                          "_comment_module_name":                    "Application module",
								"message_name":                "Order Confirmation",                        "_comment_message_name":                   "Message name",
								"message_type":                "Email",                                     "_comment_message_type":                    "Email / SMS / Push",
								"notes":                       "Order placed successfully",                 "_comment_notes":                           "Internal notes",
								"login_id":                    101,                                         "_comment_login_id":                       "User login ID"
							},

							"delivery_config": {
								"channel_number":              1,                                           "_comment_channel_number":                "Channel identifier",
								"priority_level":              "High",                                      "_comment_priority_level":                  "Message priority",
								"is_need_tracking":            true,                                        "_comment_is_need_tracking":                "Delivery tracking flag"
							},

							"sender_info": {
								"from_name":                   "GFT System",                                "_comment_from_name":                       "Sender display name",
								"from_address":                "no-reply@gft.com",                          "_comment_from_address":                    "Sender address"
							},

							"recipient_info": {
								"to_address":                  "ali.raza@email.com",                        "_comment_to_address":                      "Primary recipient",
								"cc_list":                     ["support@gft.com"],                         "_comment_cc_list":                         "CC recipients",
								"bcc_list":                    [],                                          "_comment_bcc_list":                        "BCC recipients",
								"is_email_verified":           true,                                        "_comment_is_email_verified":               "Recipient verification status"
							},

							"message_content": {
								"message_subject":             "Order Confirmation - ORD-2026-0001",        "_comment_message_subject":                 "Email subject",
								"message_body":                "Your order has been placed successfully.",  "_comment_message_body":                    "Email body",
								"attachment_list":             ["invoice.pdf"],                             "_comment_attachment_list":                 "Attachments"
							},

							"scheduling": {
								"scheduled_at":                "NOW()",                                    "_comment_scheduled_at":                    "Scheduled send time",
								"retry_interval":              15,                                         "_comment_retry_interval":                  "Retry interval in minutes"
							},

							"lifecycle_status": {
								"current_status":              "Queued",                                   "_comment_current_status":                  "Queued / Sent / Failed",
								"delivery_status":             "Pending",                                  "_comment_delivery_status":                 "Delivery state",
								"send_attempts":               0,                                          "_comment_send_attempts":                   "Send attempt count",
								"number_of_retries":            3,                                          "_comment_number_of_retries":               "Max retry attempts"
							}
						}' AS JSON);
		
-- =======================================================================
-- row_metadta for all tables
-- =======================================================================
        WHEN 'row_metadata' THEN
			RETURN CAST(
          		'{
					"status" : "active",
					"created_at" : "2026-01-19 20:10:29.282000",
					"created_by" : "system",
					"updated_at" : "2026-01-19 20:10:29.282000",
					"updated_by" : "system"
				}' AS JSON);

				
		ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid p_table_name value';
        
        END CASE;
END $$
DELIMITER ;
