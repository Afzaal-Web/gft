-- ====================================================================================================================================
-- FUNCTION Name:  getTemplate()
-- Purpose: template of the JSON for the table column with data type json
-- parameter values: 'corporate_account', 'customer', 'auth', 'customer_wallets', 'tradable_assets', 'asset_rate_history', 
-- 					  'wallet_ledger', ,'products', 'inventory', 'money_manager', 'credit_card', 'row_metadata',
--
--
--
-- =====================================================================================================================================

DROP FUNCTION getTemplate;

DELIMITER $$
CREATE FUNCTION getTemplate(
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
					"corporate_account_rec_id" 	 				  : null,
					"main_account_num"         	 				  : null,
					"main_account_title"       	 				  : null,
					"account_status"           	 				  : null,

					"status_change_history":  [
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						},
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						},
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						}
					],

					"account_admin":  {
						"first_name"             				  : null,
						"last_name"              				  : null,
						"primary_email"          				  : null,
						"primary_phone"          				  : null,
						"primary_contact"        				  : null,
						"designation_of_contact" 				  : null
					},

					"company":  {
						"company_name"                  		  : null,
						"company_email"                 		  : null,
						"company_phone"                 		  : null,
						"company_ntn_number"            		  : null,
						"company_date_of_incorporation" 		  : null,

						"owner_info":  {
							"owner_name"        				  : null,
							"owner_email"       				  : null,
							"owner_phone"       				  : null,
							"owner_national_id" 				  : null
						},

						"company_address": {
							"google_reference_number" 			  : null,
							"full_address"            			  : null,
							"country"                 			  : null,
							"building_number"         			  : null,
							"street_name"             			  : null,
							"street_address_2"        			  : null,
							"city"                    			  : null,
							"state"                   			  : null,
							"zip_code"                			  : null,
							"directions"              			  : null,
							"cross_street_1_name"     			  : null,
							"cross_street_2_name"     			  : null,
							"latitude"                			  : null,
							"longitude"               			  : null
						}
					},

					"account_stats":  {
						"total_cash_wallet"   					  : null,
						"total_gold_wallet"   					  : null,
						"total_silver_wallet" 					  : null,
						"total_orders"        					  : null,
						"total_assets"        					  : null,
						"open_tickets"        					  : null,
						"num_of_tickets"      					  : null,
						"num_of_employees"    					  : null,
						"year_to_date_orders" 					  : null
					}
				}' AS JSON);

-- =======================================================================
-- customer.customer_json    
-- =======================================================================
		WHEN 'customer' THEN
			RETURN CAST(
				'{
					"customer_rec_id"                			  : null,
					"customer_status"                			  : null,
					"customer_type"                  			  : null,
					"corporate_account_rec_id"       			  : null,
					"first_name"                    			  : null,
					"last_name"                      			  : null,
					"user_name"                      			  : null,
					"email"                         			  : null,
					"phone"                          			  : null,
					"whatsapp_number"                			  : null,
					"national_id"                    			  : null,
					"main_account_number"            			  : null,
					"account_number"                 			  : null,
					"cus_profile_pic"                			  : null,
					"is_verified"                    			  : null,

					"status_change_history":  [
						{
							"changed_at"             			  : null,
							"new_status"             			  : null,
							"notes"                  			  : null
						}
					],

					"documents":  [
						{
							"document_rec_id"        			  : null,
							"document_name"          			  : null,
							"is_verified"            			  : null,
							"uploaded_at"            			  : null,
							"verified_at"            			  : null,
							"verified_by"            			  : null
						}
					],

					"additional_contacts":  [
						{
							"additional_email"       			  : null,
							"additional_phone"       			  : null
						}
					],

					"residential_address":  {
						"google_reference_number"    			  : null,
						"full_address"               			  : null,
						"country"                    			  : null,
						"building_number"            			  : null,
						"street_name"                			  : null,
						"street_address_2"           			  : null,
						"city"                       			  : null,
						"state"                      			  : null,
						"zip_code"                   			  : null,
						"directions"                 			  : null,
						"cross_street_1_name"        			  : null,
						"cross_street_2_name"        			  : null,
						"latitude"                   			  : null,
						"longitude"                  			  : null
					},

					"permissions":  {
						"is_buy_allowed"             			  : null,
						"is_sell_allowed"            			  : null,
						"is_redeem_allowed"          			  : null,
						"is_add_funds_allowed"       			  : null,
						"is_withdrawl_allowed"       			  : null
					},

					"app_preferences":  {
						"time_zone"                  			  : null,
						"preferred_currency"         			  : null,
						"preferred_language"         			  : null,
						"auto_logout_minutes"        			  : null,
						"remember_me_enabled"        			  : null,
						"default_home_location"      			  : null,
						"biometric_login_enabled"    			  : null,
						"push_notifications_enabled" 			  : null,
						"transaction_alerts_enabled" 			  : null,
						"email_notifications_enabled" 			  : null,
						"is_face_id_enabled"         			  : null,
						"is_fingerprint_enabled"     			  : null
					},
                    "customer_wallets": []
				}' AS JSON);

-- =======================================================================
-- customer.customer_json.customer_wallets 
-- =======================================================================
		WHEN 'customer_wallets' THEN
			RETURN CAST(
						 '{
							  "wallet_id":					null,
							  "tradable_assets_rec_id": 	null,
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
					"auth_rec_id"                  				  : null,
					"parent_table_name"            				  : null,
					"parent_table_rec_id"          				  : null,
					"user_name"                    				  : null,

					"latest_otp":  {
						"latest_otp_code"          				  : null,
						"latest_otp_sent_at"       				  : null,
						"latest_otp_expires_at"    				  : null,
						"otp_retries"              				  : null,
						"next_otp_in"              				  : null
					},

					"user_mfa":  {
						"is_MFA"                   				  : null,
						"MFA_method"               				  : null,
						"MFA_method_value"         				  : null
					},

					"login_attempts":  [
						{
							"last_login_date"      				  : null,
							"login_attempts_count" 				  : null,
							"login_attempt_minutes"				  : null
						}
					],

					"current_session":  {
						"latitude"                 				  : null,
						"device_id"                				  : null,
						"longitude"                				  : null,
						"ip_address"               				  : null,
						"last_login_at"            				  : null,
						"session_status"           				  : null,
						"user_auth_token"          				  : null,
						"user_session_id"          				  : null,
						"last_login_device"        				  : null,
						"last_login_method"        				  : null,
						"session_expires_at"       				  : null
					},

					"login_credentials":  {
						"pin"                         			  : null,
						"password"                    			  : null,
						"username"                    			  : null,
						"alternate_username"          			  : null,
						"is_force_password_change"    			  : null,

						"password_policy":  {
							"min_length"              		 	  : null,
							"max_length"              		 	  : null,
							"require_uppercase"       		 	  : null,
							"require_lowercase"       		 	  : null,
							"require_number"          		 	  : null,
							"require_special_char"    		 	  : null,
							"password_expiry_days"    		 	  : null,
							"password_history_limit"  		 	  : null,
							"lockout_attempts"        		 	  : null,
							"lockout_duration_minutes"		 	  : null,
							"allow_reuse"             		 	  : null,
							"password_strength_level" 		 	  : null
						}
					},

					"security_questions":  [
						{
							"auth_security_question"  			  : null,
							"auth_security_answer"    			  : null
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
							"tradable_assets_rec_id"  : null,
							"asset_name"              : null,
							"short_name"              : null,
							"asset_code"              : null,
							"asset_intl_code"         : null,
							"wallet_type"              : null,
							"forex_code"              : null,
							"available_to_customers"  : null,

							"how_to_measure"          : null,
							"standard_units"          : null,
							"min_order"               : null,
							"max_order"               : null,
							"minimum_reedem_level"    : null,
							"max_reedem_level"        : null,

							"taxes" : {
								"GST"                 : null,
								"withholding_tax"     : null,
								"Import_Duty"         : null,
								"Luxury_Tax"          : null
							},

							"stats" : {
								"bullion_weight_available" : null,
								"products_weight"          : null
							},

							"spot_rate" : {
								"updated_at"           : null,
								"api_name"             : null,
								"url"                  : null,
								"unit"                 : null,
								"current_rate"         : null,
								"currency"             : null,
								"quality"              : null
							},

							"media_library" : [
								{
									"url"             : null,
									"description"     : null,
									"uploaded_at"     : null
								},
								{
									"url"             : null,
									"description"     : null,
									"uploaded_at"     : null
								}
							]
						}' AS JSON);
  
-- =======================================================================
-- asset_rate_history.asset_rate_history_json
-- =======================================================================
		WHEN 'asset_rate_history' THEN
			RETURN CAST(
						 '
						{
							"asset_rate_rec_id"        : null,
							"tradable_assets_rec_id"   : null,
							"asset_code"               : null,

							"spot_rate"                : null,
							"weight_unit"              : null,
							"currency_unit"            : null,
							"rate_timestamp"           : null,
							"effective_date"           : null,
							"valid_until"              : null,

							"source_info" : {
								"rate_source"          : null,
								"source_url"           : null,
								"market_status"        : null,
								"update_frequency"     : null
							},

							"foreign_exchange" : {
								"foreign_exchange_rate"  : null,
								"foreign_exchange_source": null
							}
						}' AS JSON);

-- =======================================================================
-- wallet_ledger.wallet_ledger_json
-- =======================================================================
		WHEN 'wallet_ledger' THEN
			RETURN CAST(
						'{
							"wallet_ledger_rec_id"      : null,
							"customer_rec_id"           : null,
							"account_number"            : null,
							"wallet_id"                 : null,
							"wallet_title"              : null,
							"asset_code"                : null,
							"asset_name"                : null,
							"order_rec_id"              : null,
							"order_number"              : null,
							"transaction_number"        : null,
							"transaction_type"          : null,

							"ledger_transaction" : {
								"transaction_number"    : null,
								"transaction_at"        : null,
								"transaction_reason"    : null,
								"balance_before"        : null,
								"debit_amount"          : null,
								"credit_amount"         : null,
								"balance_after"         : null
							},

							"initiated_by_info" : {
								"initiated_by"          : null,
								"initiated_by_name"     : null
							},

							"approval_info" : {
								"approved_at"           : null,
								"approved_by_rec_id"    : null,
								"approved_by_name"      : null,
								"approval_number"       : null
							},

							"contract_info" : {
								"contract_number"       : null
							},

							"blockchain_info" : {
								"blockchain_id"         : null,
								"blockchain_name"       : null,
								"blockchain_url"        : null
							}
						}' AS JSON);

-- =======================================================================
-- products.products_json
-- =======================================================================
		WHEN 'products' THEN
			RETURN CAST(
						'{
							"product_rec_id":               null,
							"tradable_assets_rec_id":       null,
							"asset_code":                   null,
							"product_code":                 null,
							"product_type":                 null,
							"product_name":                 null,

							"product_short_name":           null,
							"product_description":          null,
							"product_classification":       null,
							"asset_type":                   null,
							"product_quality":              null,
							"approximate_weight":           null,
							"weight_unit":                  null,
							"dimensions":                   null,
							"is_physical":                  null,
							"is_SliceAble":                 null,
							"standard_price":               null,
							"standard_premium":             null,
							"price_currency":               null,

							"applicable_taxes": [
								{
									"tax_name":              null,
									"taxes_description":     null,
									"amount":                null,
									"fixed or perecent":     null
								}
							],

							"quantity_on_hand":             null,
							"minimum_order_quantity":       null,
							"total_sold":                   null,
							"offer_to_customer":            null,
							"display_order":                null,
							"Alert_on_low_stock":           null,

							"media_library": [
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								},
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								},
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								}
							],

							"transaction_fee": {
								"fee_type":                 null,
								"fee_value":                null,
								"fee_currency":             null,
								"fee_description":          null
							}
						}' AS JSON);

-- =======================================================================
-- inventory.inventory_json
-- =======================================================================
 		WHEN 'inventory' THEN
			RETURN CAST(
						'{
							"inventory_rec_id"       :  null,
							"product_rec_id"         :  null,
							"item_name"              :  null,
							"item_type"              :  null,
							"asset_type"             :  null,
							"availability_status"    :  null,
							"item_Size"              :  null,
							"weight_adjustment"      :  null,
							"net_weight"             :  null,
							"available_weight"       :  null,
							"item_quality"           :  null,
							"location_details"       :  null,
							"pricing_adjustments"    :  {
															"item_margin_adjustment" :  null,
															"Discount"               :  null,
															"Promotions"             :  null
														 },
							"media_library"          :  [
															{
																"media_type"     :  null,
																"media_url"      :  null,
																"is_featured"    :  null
															}
														],
							"ownership_metrics"      :  {
															"weight_sold_so_far"       :  null,
															"number_of_shareholders"   :  null,
															"number_of_transactions"   :  null
														},
							"manufacturer_info"      :  {
															"manufacturing_country"       :  null,
															"manufacturer_name"           :  null,
															"manufacturing_date"          :  null,
															"serial_number"               :  null,
															"serial_verification_url"     :  null,
															"serial_verification_text"    :  null,
															"dimensions"                  :  null
														},
							"purchase_from"          :  {
															"purchase_from_rec_id"       :  null,
															"receipt_number"             :  null,
															"receipt_date"               :  null,
															"from_name"                  :  null,
															"from_address"               :  null,
															"from_phone"                 :  null,
															"from_email"                 :  null,
															"purchase_date"              :  null,
															"packaging"                  :  null,
															"metal_rate"                 :  null,
															"metal_weight"               :  null,
															"making_charges"             :  null,
															"premium_paid"               :  null,
															"total_tax_paid"             :  null,
															"tax_description"            :  null,
															"total_price_paid"           :  null,
															"mode_of_payment"            :  null,
															"check_or_transaction_no"    :  null
														},
							"sold_to"                :  [
															{
																"order_date"          :  null,
																"order_number"        :  null,
																"receipt_number"      :  null,
																"sold_date"           :  null,
																"sold_to_id"          :  null,
																"sold_to_name"        :  null,
																"sold_to_phone"       :  null,
																"sold_to_email"       :  null,
																"sold_to_address"     :  null,
																"metal_rate"          :  null,
																"weight_sold"         :  null,
																"making_charges"      :  null,
																"premium_charged"     :  null,
																"taxes"               :  null,
																"taxes_description"   :  null,
																"total_price_charged" :  null,
																"transaction_details" :  {
																							"transaction_num"      :  null,
																							"fee_type"             :  null,
																							"fee_value"            :  null,
																							"fee_currency"         :  null,
																							"fee_description"      :  null,
																							"transaction_status"   :  null
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
							"money_manager_rec_id"      : null,
							"customer_rec_id"           : null,
							"account_number"            : null,
							"request_type"              : null,
							"transaction_type"          : null,

							"transaction_change_log"    : [
								{
									"transaction_posted_at" : null,
									"back_office_post_num"  : null
								}
							],

							"company_log" : {
								"processed_by"          : null,
								"reviewed_by"           : null,
								"approved_by"           : null
							},

							"sender_info" : {
								"initiated_by"          : null,
								"institution_name"      : null,
								"account_holder_name"   : null,
								"account_number"        : null,
								"amount_sent"           : null,
								"transaction_id"        : null,
								"receipt_number"        : null,
								"receipt_picture_rec_id": null,
								"trans_at"              : null
							},

							"receiver_info" : {
								"institution_name"      : null,
								"account_holder_name"   : null,
								"account_number"        : null,
								"amount_received"       : null,
								"received_at"           : null,
								"processing_fee"        : null
							}
						}' AS JSON);

-- =======================================================================
-- credit_card.credit_card_json
-- =======================================================================
		WHEN 'credit_card' THEN
			RETURN CAST(
						'{
							"credit_card_rec_id"       : null,
							"money_manager_rec_id"     : null,

							"account_number"           : null,
							"trans_posted_at"          : null,
							"backoffice_post_number"   : null,
							"processor_name"           : null,
							"processor_token"          : null,
							"card_last_4"              : null,

							"card_info" : {
								"card_type"            : null,
								"card_number"          : null,
								"card_holder_name"     : null,
								"card_expiration_date" : null,
								"cvv2"                 : null
							},

							"billing_address" : {
								"billing_country"      : null,
								"billing_address1"     : null,
								"billing_address2"     : null,
								"billing_city"         : null,
								"billing_state"        : null,
								"billing_zip_code"     : null
							},

							"bank_approval" : {
								"approval_number"      : null,
								"approval_at"          : null,
								"settlement_amount"    : null,
								"settlement_date"      : null
							},

							"company_log" : {
								"processed_by"         : null,
								"reviewed_by"          : null,
								"approved_by"          : null
							}
						}' AS JSON);
		
-- =======================================================================
-- row_metadta for all tables
-- =======================================================================
		WHEN 'row_metadata' THEN
			RETURN CAST(
				'{
					"status"       								  : null,
					"created_at"   								  : null,
					"created_by"   								  : null,
					"updated_at"   								  : null,
					"updated_by"   								  : null
				}' AS JSON);
		
		ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid p_table_name value';
        
        END CASE;
END $$
DELIMITER ;





