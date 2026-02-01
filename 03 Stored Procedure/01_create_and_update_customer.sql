-- ==================================================================================================
-- Procedure: 					createCustomer
-- Purpose:   					get registration data of user and insert into customer, auth and upcoming tables
-- Functions used in this Pro:
								-- isFalsy(): 					validate the values come from reqObj
								-- getJval(): 					get value of req object
								-- getTemplate(): 				template of json column used in tables
								-- fillTemplate(): 				used to insert values from reqObj in template json
                                -- getSequence():				to get sequence number for main account num & account num
                                -- createAcustomerWallet():		create a customer wallet from current assets and generate wallet activity 
-- ===================================================================================================

DROP PROCEDURE IF EXISTS upsertCustomer;

DELIMITER $$

CREATE PROCEDURE upsertCustomer(
								 IN  pjReqObj   JSON,
								 OUT psResObj   JSON
								)
    
BEGIN

    DECLARE v_customer_rec_id     		 	INT;
    DECLARE v_auth_rec_id         		 	INT;

    /* ===================== Customer Core ===================== */
    DECLARE v_customer_status     			VARCHAR(30) DEFAULT 'registration_request';
    DECLARE v_customer_type       			VARCHAR(30) DEFAULT 'personal';
    DECLARE v_email               			VARCHAR(100);
    DECLARE v_user_name           			VARCHAR(100);
    DECLARE v_password_plain      			VARCHAR(255);
    DECLARE v_password_hashed     			VARCHAR(255);
    DECLARE v_account_seq 		  			VARCHAR(255);
    DECLARE v_mode 							VARCHAR(20);

    /* ===================== JSON Objects ===================== */
    DECLARE v_customer_json       		JSON;
    DECLARE v_auth_json           		JSON;
    DECLARE v_row_metadata   			JSON;

    /* ===================== Validation Variables ===================== */
    DECLARE v_errors              		JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg       			TEXT;
    
   /* ===================== Variable for tradable_assets table and for cursor ===================== */
	DECLARE done 						INT;
	DECLARE v_tradable_asset_rec_id 	INT;

	DECLARE 	asset_cursor 			CURSOR FOR
    SELECT  	tradable_assets_rec_id
    FROM    	tradable_assets
    WHERE   	available_to_customers = TRUE  AND tradable_assets_rec_id > 0;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	/* ===================== Error Handler ===================== */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
									'status', 			'error',
									'status_code',		'1',
									'message', 			'Registration failed',
									'system_error',		v_err_msg
								   );
    END;
    /* ===================== Main ===================== */
    main_block: BEGIN

        /* ===================== Extract Scalars ===================== */
        SET v_email     		= getJval(pjReqObj, 'email');
        SET v_user_name 		= v_email;
	
            /* ===================== Set template values from Request Object ===================== */
        SET v_customer_json 			= fillTemplate(pjReqObj, getTemplate('customer'));
		SET v_row_metadata 				= getTemplate('row_metadata');
        
    SET v_mode =
				CASE
					WHEN isFalsy(getJval(pjReqObj,'customer_rec_id')) THEN
					'INSERT'
					ELSE
					'UPDATE'
				END;
                
		/* ========================================================================================= */
        /* ======================================= INSERT ========================================== */
        /* ========================================================================================= */
    
    CASE v_mode
        
		WHEN 'INSERT' THEN
        
            /* ===================== Validations ===================== */
			IF isFalsy(getJval(pjReqObj,'first_name')) THEN
				SET v_errors		= JSON_ARRAY_APPEND(v_errors,'$','First name is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'last_name')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','Last name is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'national_id')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','National ID is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'phone')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','Phone number is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'password')) THEN
				SET v_errors		= JSON_ARRAY_APPEND(v_errors,'$','Password is required');
			END IF;
        
        /* ===================== Check the INSERT uniqueness ===================== */

			IF EXISTS (
						SELECT 1 FROM customer
						WHERE national_id = getJval(pjReqObj,'national_id')
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$', 'Customer already exists with this National ID');
			END IF;

			IF EXISTS (
						SELECT 1 FROM customer
						WHERE email = v_email
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Email already exists');
			END IF;
            
			IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
										'status', 				'error',
										'status_code', 			'1',
										'errors', 				v_errors
									   );
            LEAVE main_block;
			END IF;


			/* =============== CREATE CUSTOMER: INSERT NEW ROW IF REC ID NOT EXISTS in Request ============= */
            
			CALL getSequence('CUSTOMER.MAIN_ACCOUNT_NUM',NULL, NULL,'creatCustomer sp', v_account_seq);
        
			SET v_customer_json				= JSON_SET( v_customer_json,
														'$.customer_status',		v_customer_status,
														'$.customer_type', 			v_customer_type,
														'$.user_name', 				v_user_name,
														'$.main_account_number',	v_account_seq,
														'$.account_number',			v_account_seq
											  );
            
			SET v_row_metadata				= JSON_SET( v_row_metadata,
														'$.status', 		v_customer_status,   -- reg req
														'$.created_at',		DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
														'$.created_by', 	'SYSTEM'
														);
                                                   
			INSERT INTO customer
			SET customer_status 			= v_customer_status,		-- registration_request
					customer_type   		= v_customer_type,			-- personal
					first_name				= getJval(pjReqObj, 'first_name'),
					last_name				= getJval(pjReqObj, 'last_name'),
					user_name       		= v_user_name,
					email           		= v_email,
					phone           		= getJval(pjReqObj,'phone'),
					whatsapp_num    		= getJval(pjReqObj,'whatsapp_number'),
					national_id     		= getJval(pjReqObj,'national_id'),
					main_account_num       	= v_account_seq,
					account_num            	= v_account_seq,
					customer_json   		= v_customer_json,
					row_metadata    		= v_row_metadata;

			SET v_customer_rec_id 			= LAST_INSERT_ID();

			SET v_customer_json 			= JSON_SET( v_customer_json,
														'$.customer_rec_id', v_customer_rec_id
													  );

			UPDATE  customer
			SET 	customer_json  	= v_customer_json
			WHERE   customer_rec_id = v_customer_rec_id;
				
				 /* ---------- get Auth JSON ---------- */
			SET v_auth_json 	= getTemplate('auth');
                
				/* ===================== Password ===================== */
			SET v_password_plain  			= getJval(pjReqObj,'password');
			SET v_password_hashed 			= SHA2(v_password_plain,256);
            
            

				/* ---------- Prepare Auth JSON ---------- */
			SET v_auth_json					= JSON_SET( v_auth_json,
														'$.parent_table_name',						'customer',
														'$.parent_table_rec_id',					v_customer_rec_id,
														'$.user_name',								v_user_name,
														'$.login_credentials.password',				v_password_hashed,
														'$.login_credentials.username',				v_email                                               
													);
                                      
				/* ---------- Insert Auth ---------- */
			INSERT INTO auth
			SET parent_table_name   			= 'customer',
					parent_table_rec_id 		= v_customer_rec_id,
					user_name           		= v_user_name,
					auth_json           		= v_auth_json,
					row_metadata        		= v_row_metadata;

			SET v_auth_rec_id 	= LAST_INSERT_ID();
				
			SET v_auth_json 	= JSON_SET( v_auth_json,'$.auth_rec_id', v_auth_rec_id );

			UPDATE  auth
			SET 	auth_json 	  = v_auth_json
			WHERE   auth_rec_id = v_auth_rec_id;
            
            INSERT INTO password_history
			SET 	parent_table_name   		= 'customer',
					parent_table_rec_id 		= v_customer_rec_id,
					password_hash           	= v_password_hashed,
					password_set_at           	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
					password_changed_by        	= null,
                    password_change_reason		= 'Initial password setup',
                    last_password_updated_at	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
                    password_expiration_date	= DATE_ADD(NOW(),INTERVAL 90 DAY),
                    is_active					= TRUE;
                
				/* ===================== CREATE CUSTOMER WALLETS ===================== */
			
            SET done = FALSE;
			OPEN asset_cursor;

				asset_loop: LOOP
				FETCH asset_cursor INTO v_tradable_asset_rec_id;
				IF done THEN
					LEAVE asset_loop;
				END IF;
			
				CALL createAcustomerWallet(v_customer_rec_id,v_tradable_asset_rec_id);
		
				END LOOP asset_loop;

			CLOSE asset_cursor;
            




		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */     
        
        
        
		
		WHEN 'UPDATE' THEN
        
				SET v_customer_rec_id 		= getJval(pjReqObj,'customer_rec_id');
                
		/* ===================== Update Validations ===================== */
            
		/* ===================== UPDATE must target existing record ===================== */
			IF NOT EXISTS (
							SELECT 1 FROM customer
							WHERE customer_rec_id = v_customer_rec_id
						  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid customer_rec_id: record does not exist');
			END IF;

	 /* ===================== Check NIC Uniqueness ===================== */
			IF EXISTS (
						SELECT 1 FROM customer
						WHERE national_id	 = getJval(pjReqObj,'national_id')
						AND customer_rec_id  <> v_customer_rec_id
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$', 'National ID already used by another customer');
			END IF;
	
    /* ===================== Check Email Uniqueness ===================== */
			IF EXISTS (
					SELECT 1 FROM customer
					WHERE email = v_email
					AND customer_rec_id <> v_customer_rec_id
				) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Email already used by another customer');
            END IF;
            
   /* ===================== Stop if errors  ===================== */
			IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT(
										'status', 				'error',
										'status_code', 			'1',
										'errors', 				v_errors
									   );
            LEAVE main_block;
			END IF;
            
			 /* =============== Customer Profile and password update: UPDATE EXISTING ROW IF REC ID EXISTS in Request ============= */
            
             /* =============== fil existed CustomerJson from reqObj ============= */
			SET v_customer_json = fillTemplate(pjReqObj, getCustomer(v_customer_rec_id));
            
            SELECT 	row_metadata
            INTO 	v_row_metadata
            FROM 	customer
            WHERE 	customer_rec_id = v_customer_rec_id;
				
			SET v_row_metadata	  		= JSON_SET( v_row_metadata,
													'$.status',			COALESCE(getJval(pjReqObj, 'customer_status'),	v_customer_status),	
													'$.updated_by', 	'SYSTEM',
													'$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
												 );
			
			UPDATE customer
			SET customer_status 			= COALESCE(getJval(v_customer_json, 'customer_status'),		 v_customer_status),		-- registration_request
				customer_type   			= COALESCE(getJval(v_customer_json, 'customer_type'),		 v_customer_type),			-- personal
                corporate_account_rec_id	= getJval(pjReqObj, 'corporate_account_rec_id'),			
				first_name					= getJval(v_customer_json, 'first_name'),
				last_name					= getJval(v_customer_json, 'last_name'), 						
				user_name       			= getJval(v_customer_json, 'email'), 						
				email           			= getJval(v_customer_json, 'email'), 							
				phone           			= getJval(v_customer_json,'phone'),							
				whatsapp_num    			= getJval(v_customer_json,'whatsapp_number'),					
				national_id     			= getJval(v_customer_json,'national_id'),						
				customer_json   			= v_customer_json,
				row_metadata    			= v_row_metadata
				WHERE customer_rec_id		= v_customer_rec_id;
				
                
			/* =============== get existed AuthJson ============= */
                
            SET v_auth_json			= getAuth(v_customer_rec_id);
            
            		/* ---------- update Auth Json ---------- */
			SET v_auth_json					= JSON_SET( v_auth_json,
														'$.user_name',								getJval(v_customer_json, 'email'),
														'$.login_credentials.username',				getJval(v_customer_json, 'email')                                               
													);
												   
			/* ---------- Update password if provided  ---------- */
            IF NOT isFalsy(getJval(pjReqObj,'password')) THEN
            
					SET v_password_plain  		= getJval(pjReqObj,'password');
					SET v_password_hashed 		= SHA2(v_password_plain,256);
					
					UPDATE  password_history
					SET 	is_active 				= FALSE
					WHERE   parent_table_name 		= 'customer'
					AND 	parent_table_rec_id 	= v_customer_rec_id
					AND 	is_active 				= TRUE;

					INSERT INTO password_history
					SET parent_table_name         	= 'customer',
						parent_table_rec_id       	= v_customer_rec_id,
						password_hash             	= v_password_hashed,
						password_set_at           	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
						password_changed_by 		= CONCAT(getJval(v_customer_json, 'first_name'),' ', getJval(v_customer_json, 'last_name')),
						password_change_reason    	= 'UPDATE',
						last_password_updated_at  	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
						password_expiration_date  	= DATE_ADD(NOW(), INTERVAL 90 DAY),
						is_active                 	= TRUE;

					SET v_auth_json 				= JSON_SET( v_auth_json, '$.login_credentials.password', v_password_hashed );
			 END IF;
	

				/* ---------- Update Auth table with  ---------- */
			UPDATE auth
			SET   user_name        		= COALESCE(getJval(pjReqObj, 'email'),getJval(v_auth_json, 'user_name')),
				  auth_json        		= v_auth_json,
				  row_metadata     		= v_row_metadata
			WHERE parent_table_rec_id 	= v_customer_rec_id;
				
			IF ROW_COUNT() = 0 THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Update failed: no rows affected';
			END IF;

	END CASE;



		        /* ===================== Successful Registration ===================== */
		SET psResObj = JSON_OBJECT(
									'status', 'success',
									'status_code', '0',
									'message',
									IF(isFalsy(getJval(pjReqObj,'customer_rec_id')),
									   'Customer created successfully',
									   'Customer updated successfully'
                                   )
		);
    END main_block;
    
	-- inert general code here like LOG
	-- call log proc
    
END $$    -- proc end

DELIMITER ;



ALTER TABLE password_history
ADD INDEX idx_password_history_parent (parent_table_name, parent_table_rec_id, is_active);

ALTER TABLE auth
ADD UNIQUE INDEX uk_auth_parent (parent_table_name, parent_table_rec_id);

SELECT @@SQL_SAFE_UPDATES;



