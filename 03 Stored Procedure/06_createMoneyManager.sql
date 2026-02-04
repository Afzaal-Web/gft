-- ==================================================================================================
-- Procedure: 					createMoneyTransaction
-- Purpose:   					Deposit and withdrawal info
-- Functions used in this Pro:
								-- isFalsy(): 					validate the values come from reqObj
								-- getJval(): 					get value of req object
								-- getTemplate(): 				template of json column used in tables
								-- fillTemplate(): 				used to insert values from reqObj in template json
-- ===================================================================================================

DROP PROCEDURE IF EXISTS createMoneyTransaction;

DELIMITER $$

CREATE PROCEDURE createMoneyTransaction(
										 IN  pjReqObj JSON,
										 OUT psResObj JSON
									   )
BEGIN

	/* =============== Variable Declarations ============= */
    
    DECLARE v_mm_rec_id           		INT;
    DECLARE v_cc_rec_id           		INT;
    DECLARE v_status					VARCHAR(50) 		DEFAULT 'INITIATED';
    DECLARE v_request_type        		VARCHAR(20);							-- deposit | withdraw
    DECLARE v_transaction_type    		VARCHAR(50);							-- Cash Deposit, Bank transfer, Check deposite, e-wallets, credit_card
    DECLARE v_customer_rec_id     		INT;
    
    
    DECLARE v_mm_json          			JSON;
    DECLARE v_cc_json          			JSON;
	DECLARE v_row_metadata           	JSON;
    DECLARE v_customer_json				JSON;
    DECLARE v_trans_life_cycle			JSON;
    
    DECLARE v_errors 					JSON 				DEFAULT JSON_ARRAY();	-- Validation errors
	DECLARE v_err_msg       		    VARCHAR(1000);								-- SQL error message
    
    /* =============== Exception Handler ============= */
    /* Any SQL error will rollback transaction and return error response */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
				ROLLBACK;
				GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
				SET psResObj = JSON_OBJECT(
											'status', 'error',
											'message', 'Money manager creation failed',
											'system_error', v_err_msg
											);
		END;
   
   
    /* =============== Main Logical Block ============= */
	main_block: BEGIN
    
    /* =============== Extract Required Fields ============= */
		SET v_request_type     		= getJval(pjReqObj,'request_type');
		SET v_transaction_type 		= getJval(pjReqObj,'transaction_type');
		SET v_customer_rec_id 		= CAST(getJval(pjReqObj,'customer_rec_id') AS UNSIGNED);

    /* =============== Basic Validations ============= */
		IF isFalsy(v_request_type) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','request_type is required');
		END IF;

		IF v_request_type NOT IN ('deposit','withdraw') THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid request_type');
		END IF;

		IF isFalsy(v_transaction_type) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','transaction_type is required');
		END IF;
        
	 /* =============== Business Rule Validation ============= */
     /* Withdrawal cannot be done via deposit-only transaction types */
		IF v_transaction_type IN ('cash deposit','bank transfer','check deposit','e wallets','credit card') THEN
			
			IF 	v_request_type = 'withdraw' AND 
				v_transaction_type IN ('cash deposit','check deposit','credit card') THEN
			
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid transaction_type for withdrawal');
			END IF;
			
		END IF;

	 /* =============== Amount Validation ============= */
		IF isFalsy(getJval(pjReqObj,'sender_info.amount_sent') AND getJval(pjReqObj,'receiver_info.amount_received')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','amount is required');
			
		ELSEIF CAST(getJval(pjReqObj,'sender_info.amount_sent') AS DECIMAL(18,2)) 	   <= 0  OR 
			   CAST(getJval(pjReqObj,'receiver_info.amount_received') AS DECIMAL(18,2))  <= 0  THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','amount must be greater than zero');
		
		END IF;

	/* =============== Customer & Account Validation ============= */
		IF isFalsy(v_customer_rec_id) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','customer_rec_id is required');
		END IF;
    
   
	/* =============== Credit Card Specific Validation ============= */
    
		IF v_transaction_type = 'card_info.credit card' THEN
		    IF isFalsy(getJval(pjReqObj,'card_number')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','card_number is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'card_info.cvv2')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','cvv2 is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'processor_name')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','processor_name is required');
			END IF;			
		END IF;
    
	/* =============== Return Validation Errors ============= */
    /* Stop execution if any validation failed */
    
		IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
										'status', 'validation_error',
										'errors', v_errors
									);
			LEAVE main_block;
		END IF;
        /* =============== All Validations Done ============= */
    
    /* =============== Prepare JSON Templates ============= */
    
		SET v_customer_json			= getCustomer(v_customer_rec_id);    
		SET v_mm_json 				= fillTemplate(pjReqObj,getTemplate('money_manager'));
		SET v_cc_json 				= fillTemplate(pjReqObj, getTemplate('credit_card'));
        SET v_trans_life_cycle		= getTemplate('transaction_life_cycle');
        
		SET v_trans_life_cycle		= JSON_SET(v_trans_life_cycle,
												 "$.status",              v_status,
												 "$.user_name",           getJval(v_customer_json,'user_name'),
												 "$.action_by",           CONCAT(getJval(v_customer_json,'first_name'),
																				 ' ',
																				  getJval(v_customer_json,'last_name')
																				),
												 "$.action_at",           NOW(),
                                                 "$.notes", 			  'Initial setup'
                                                );
											
        
            /* ================ APPEND OBJ in life cycle array in money manager ============ */
		SET v_mm_json	 		= JSON_ARRAY_APPEND( v_mm_json,
														 '$.life_cycle',
														  v_trans_life_cycle
														);
                                                        
                /* ================ APPEND OBJ in life cycle array in credit card ============ */
		SET v_cc_json	 		= JSON_ARRAY_APPEND( v_cc_json,
														 '$.life_cycle',
														  v_trans_life_cycle
														);																
                                             
        
        SET v_row_metadata 			= getTemplate('row_metadata');		
		SET v_row_metadata 			= JSON_SET( v_row_metadata,
												'$.status', 		v_status,
												'$.created_at',		NOW(),
												'$.created_by', 	'createMoneyManager'
											);

  /* =============== Start Transaction ============= */
		START TRANSACTION;

 /* =============== Insert into money_manager ============= */
 
		INSERT INTO money_manager
		SET customer_rec_id			= v_customer_rec_id,
			status					= v_status,
			account_num				= getJval(v_customer_json,'account_number'),
			request_type			= v_request_type,
			transaction_type		= v_transaction_type,
			money_manager_json		= v_mm_json,
			row_metadata			= v_row_metadata;

		SET v_mm_rec_id 			= LAST_INSERT_ID();
    
  /* =============== Sync Generated ID into JSON ============= */
		SET v_mm_json 				= JSON_SET( v_mm_json,
												'$.money_manager_rec_id',  v_mm_rec_id,
                                                '$.account_num', 		   getJval(v_customer_json,'account_number'),
												'$.status', 			   v_status
												);
		
		UPDATE money_manager
		SET    money_manager_json 		= v_mm_json
		WHERE  money_manager_rec_id 	= v_mm_rec_id;

     /* =============== Credit Card Insert (Conditional) ============= */

	
     
		IF v_transaction_type = 'credit card' THEN
		
			INSERT INTO credit_card
			SET	money_manager_rec_id 	 = v_mm_rec_id,
				status					 = v_status,
				account_num				 = getJval(v_customer_json,'account_number'),
				processor_name			 = getJval(pjReqObj,'processor_name'),
				processor_token			 = getJval(pjReqObj,'processor_token'),
				card_last_4				 = RIGHT(getJval(pjReqObj,'card_info.card_number'),4),
				card_json				 = v_cc_json,
				row_metadata			 = v_row_metadata;
		
			SET v_cc_rec_id 			= LAST_INSERT_ID();
		
	  /* =============== Sync Credit Card ID into JSON ============= */
			SET v_cc_json 				= JSON_SET( v_cc_json,
												'$.credit_card_rec_id', v_cc_rec_id,
                                                '$.money_manager_rec_id', v_mm_rec_id,
												'$.status', v_status,
                                                '$.card_last_4', RIGHT(getJval(pjReqObj,'card_number'),4)
												);
		
			UPDATE credit_card
			SET    card_json 	= v_cc_json
			WHERE  credit_card_rec_id 	= v_cc_rec_id;
    
		END IF;

    COMMIT;
    
    /* =============== Success Response ============= */
    
	SET psResObj = JSON_OBJECT(
								'status', 		 'success',
								'status_code',    0,
								'message',       'Your transaction has been submitted. It will be posted to your wallet within 3 business days.'
							);
						
     END main_block;
     
     -- inert general code here like LOG
	-- call log proc
END$$

DELIMITER ;




