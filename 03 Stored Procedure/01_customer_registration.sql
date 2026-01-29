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

DROP PROCEDURE IF EXISTS createCustomer;

DELIMITER $$

CREATE PROCEDURE createCustomer(
								IN  pjReqObj   JSON,
								OUT psResObj   JSON
								)
    
BEGIN

    DECLARE v_customer_rec_id     		 INT;
    DECLARE v_auth_rec_id         		 INT;

    /* ===================== Customer Core ===================== */
    DECLARE v_customer_status     		VARCHAR(30) DEFAULT 'registration_request';
    DECLARE v_customer_type       		VARCHAR(30) DEFAULT 'personal';

    DECLARE v_email               		VARCHAR(100);
    DECLARE v_user_name           		VARCHAR(100);
    DECLARE v_password_plain      		VARCHAR(255);
    DECLARE v_password_hashed     		VARCHAR(255);
    DECLARE v_account_seq 		  		VARCHAR(255);


    /* ===================== JSON Objects ===================== */
    DECLARE v_customer_json       		JSON;
    DECLARE v_auth_json           		JSON;
    DECLARE v_row_metadata   			JSON;

    /* ===================== Validation Variables ===================== */
    DECLARE v_errors              		JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg       			TEXT;
    
   /* ===================== Variable for tradable_assets table and for cursor ===================== */
	DECLARE done 						INT DEFAULT FALSE;
	DECLARE v_tradable_asset_rec_id 	INT;

	DECLARE asset_cursor CURSOR FOR
    SELECT tradable_assets_rec_id
    FROM tradable_assets
    WHERE available_to_customers = TRUE  AND tradable_assets_rec_id > 0;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
        /* ===================== Error Handler ===================== */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
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
		IF isFalsy(getJval(pjReqObj,'customer_rec_id')) THEN

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

		/* ===================== Check the Update uniqueness & UPDATE must target existing record ===================== */
		ELSE

			IF NOT EXISTS (
							SELECT 1 FROM customer
							WHERE customer_rec_id = getJval(pjReqObj,'customer_rec_id')
						 )  THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid customer_rec_id: record does not exist');
			END IF;

			IF EXISTS (
						SELECT 1 FROM customer
						WHERE national_id	 = getJval(pjReqObj,'national_id')
						AND customer_rec_id  <> getJval(pjReqObj,'customer_rec_id')
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$', 'National ID already used by another customer');
			END IF;

			IF EXISTS (
					SELECT 1 FROM customer
					WHERE email = v_email
					AND customer_rec_id <> getJval(pjReqObj,'customer_rec_id')
				) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Email already used by another customer');
		END IF;

		END IF;

     /* ===================== Send Valdation Responses in object of Arrays ===================== */
        IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT(
										'status', 				'error',
										'status_code', 			'1',
										'errors', 				v_errors
									   );
            LEAVE main_block;
        END IF;

        /* ===================== Password ===================== */
        SET v_password_plain  			= getJval(pjReqObj,'password');
        SET v_password_hashed 			= SHA2(v_password_plain,256);

		CALL getSequence('CUSTOMER.MAIN_ACCOUNT_NUM',NULL, NULL,'creatCustomer sp', v_account_seq);
        
        /* ===================== Set template values from Request Object ===================== */
        SET v_customer_json 			= fillTemplate(pjReqObj, getTemplate('customer'));
        
        SET v_customer_json				= JSON_SET( v_customer_json,
												'$.customer_status',		v_customer_status,
												'$.customer_type', 			v_customer_type,
                                                '$.main_account_number',	v_account_seq,
                                                '$.account_number',			v_account_seq
											  );

        /* ===================== Customer Row Metadata ===================== */
        SET v_row_metadata 		= getTemplate('row_metadata');
        
      
       
        
        /* =============== INSERT NEW ROW IF REC ID NOT EXISTS in Request ============= */
	START TRANSACTION;
        IF isFalsy(getJval(pjReqObj,'customer_rec_id')) THEN
        
				 SET v_row_metadata		= JSON_SET( v_row_metadata,
													'$.status', 		v_customer_status,   -- reg req
													'$.created_at',		DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
													'$.created_by', 	'SYSTEM'
												   );
		  /* ===================== Transaction ===================== */
	
             
				INSERT INTO customer
				SET customer_status 		= v_customer_status,		-- registration_request
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

				SET v_customer_rec_id 		= LAST_INSERT_ID();

				SET v_customer_json 		= JSON_SET( v_customer_json,
														'$.customer_rec_id', v_customer_rec_id
													  );

				UPDATE  customer
				SET 	customer_json  	= v_customer_json
				WHERE   customer_rec_id = v_customer_rec_id;
				
				 /* ---------- get Auth JSON ---------- */
				SET v_auth_json 	= getTemplate('auth');

				/* ---------- Prepare Auth JSON ---------- */
				SET v_auth_json = JSON_SET( v_auth_json,
											'$.parent_table_name',					'customer',
											'$.parent_table_rec_id',				v_customer_rec_id,
											'$.user_name',							v_user_name,
											'$.login_credentials.password',			v_password_hashed,
											'$.password_history[0].password',		v_password_hashed
										  );

				/* ---------- Insert Auth ---------- */
				INSERT INTO auth
				SET parent_table_name   				= 'customer',
					parent_table_rec_id 				= v_customer_rec_id,
					user_name           				= v_user_name,
					auth_json           				= v_auth_json,
					row_metadata        				= v_row_metadata;

				SET v_auth_rec_id 	= LAST_INSERT_ID();
				
				
				SET v_auth_json 	= JSON_SET( v_auth_json,
												'$.auth_rec_id',	v_auth_rec_id
											  );

				UPDATE auth
				SET auth_json 	  = v_auth_json
				WHERE auth_rec_id = v_auth_rec_id;
                
		 COMMIT;
				/* ===================== CREATE CUSTOMER WALLETS ===================== */
		
				OPEN asset_cursor;

				asset_loop: LOOP
					FETCH asset_cursor INTO v_tradable_asset_rec_id;
					IF done THEN
						LEAVE asset_loop;
					END IF;
		START TRANSACTION;
					CALL createAcustomerWallet(
						v_customer_rec_id,
						v_tradable_asset_rec_id
					);
		COMMIT;
				END LOOP asset_loop;

				CLOSE asset_cursor;
    
                /* =============== UPDATE EXISTING ROW IF REC ID EXISTS in Request ============= */
        ELSE
        
        START TRANSACTION;
        
				SET v_customer_rec_id 		= getJval(pjReqObj,'customer_rec_id');
				
				SELECT 	row_metadata, customer_json
				INTO 	v_row_metadata, v_customer_json
				FROM 	customer
				WHERE 	customer_rec_id = v_customer_rec_id;
				
				SET v_row_metadata	  		= JSON_SET( v_row_metadata,
														  '$.updated_by', 	'SYSTEM',
														   '$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
													   );
												   
				SET v_customer_json 		= fillTemplate(pjReqObj, v_customer_json);
				
				UPDATE customer
				SET customer_status 		= v_customer_status,		-- registration_request
					customer_type   		= v_customer_type,			-- personal
					first_name				= getJval(pjReqObj, 'first_name'),
					last_name				= getJval(pjReqObj, 'last_name'),
					user_name       		= v_user_name,
					email           		= v_email,
					phone           		= getJval(pjReqObj,'phone'),
					whatsapp_num    		= getJval(pjReqObj,'whatsapp_number'),
					national_id     		= getJval(pjReqObj,'national_id'),
					customer_json   		= v_customer_json,
					row_metadata    		= v_row_metadata
				WHERE customer_rec_id		= v_customer_rec_id;
				
				SELECT  row_metadata, auth_json
				INTO 	v_row_metadata, v_auth_json
				FROM    auth
				WHERE 	parent_table_rec_id = v_customer_rec_id;
				
				SET v_row_metadata	  	= JSON_SET( v_row_metadata,
													'$.updated_by', 	'SYSTEM',
													'$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
												);
												   
				SET v_auth_json 		= fillTemplate(pjReqObj, v_auth_json);
				
				/* ---------- Prepare Auth JSON ---------- */
				SET v_auth_json = JSON_SET( v_auth_json,
											'$.user_name',							v_user_name,
											'$.login_credentials.password',			v_password_hashed,
											'$.password_history[0].password',		v_password_hashed
										  );

				/* ---------- Update Auth table with  ---------- */
				UPDATE auth
				SET user_name        = v_user_name,
					auth_json        = v_auth_json,
					row_metadata     = v_row_metadata
				WHERE parent_table_rec_id = v_customer_rec_id;
                    
				IF ROW_COUNT() = 0 THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'Update failed: no rows affected';
				END IF;
        COMMIT;
        END IF;
        
        

         
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



