-- ==================================================================================================
-- Procedure: 					updateMoneyTransaction
-- Purpose:   					update the money manager and credit card
-- Functions used in this Pro:
								-- isFalsy(): 					validate the values come from reqObj
								-- getJval(): 					get value of req object
								-- getTemplate(): 				template of json column used in tables
								-- fillTemplate(): 				used to insert values from reqObj in template json
-- ===================================================================================================




DROP PROCEDURE IF EXISTS updateMoneyTransaction;
DELIMITER $$

CREATE PROCEDURE updateMoneyTransaction(
										IN  pjReqObj JSON,
										OUT psResObj JSON
									  )
BEGIN
    DECLARE v_mm_rec_id        INT;
    DECLARE v_new_status       VARCHAR(50);
    DECLARE v_mm_json          JSON;
    DECLARE v_cc_json          JSON;
    DECLARE v_row_metadata     JSON;
    DECLARE v_life_cycle       JSON;
    
    
    DECLARE v_errors           JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg          VARCHAR(1000);

    /* ================= Exception Handler ================= */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
									'status','error',
									'message','Money transaction update failed',
									'system_error', v_err_msg
								);
    END;

    main_block: BEGIN

        /* =============== Extract Inputs =============== */
        SET v_mm_rec_id  		= CAST(getJval(pjReqObj,'money_manager_rec_id') AS UNSIGNED);
        SET v_new_status 		= getJval(pjReqObj,'status');

        /* =============== Validations =============== */
        IF isFalsy(v_mm_rec_id) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','money_manager_rec_id is required');
        END IF;

        IF isFalsy(v_new_status) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','new_status is required');
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT('status','validation_error','errors',v_errors);
            LEAVE main_block;
        END IF;

        /* =============== Fetch Existing Record =============== */
        SET v_mm_json = getMoneyManager(v_mm_rec_id);

        IF getJval(v_mm_json,'status') IS NULL THEN
            SET psResObj = JSON_OBJECT(
                'status','error',
                'message','Transaction not found'
            );
            LEAVE main_block;
        END IF;

        /* =============== Status Transition Rules =============== */
        IF getJval(v_mm_json,'status') = 'POSTED' THEN
            SET psResObj = JSON_OBJECT(
                'status','error',
                'message','Posted transaction cannot be modified'
            );
            LEAVE main_block;
        END IF;
        
     

       
           /* =============== get existed json of money manager and update with req obj  =============== */
        SET v_mm_json	 = getMoneyManager(v_mm_rec_id);

         /* =============== Prepare Lifecycle Entry =============== */
        SET v_life_cycle = getTemplate('transaction_life_cycle');
        
        SET v_life_cycle 		= JSON_SET( v_life_cycle,
											'$.status',     v_new_status,
											'$.user_name',  getJval(pjReqObj,'user_name'),
											'$.action_by',  getJval(pjReqObj,'action_by'),
											'$.action_at',  COALESCE(getJval(pjReqObj,'action_at'), NOW()),
											'$.notes',      getJval(pjReqObj,'notes')
                                    );

	   /* ================ APPEND OBJ in life cycle array in money manager ============ */
        SET v_mm_json 			= JSON_ARRAY_APPEND(
													v_mm_json,
													'$.life_cycle',
													v_life_cycle
												);

        /* =============== Update Row Metadata =============== */
        SET v_row_metadata = getTemplate('row_metadata');
        SET v_row_metadata = JSON_SET( v_row_metadata,
									   '$.status',       v_new_status,
									    '$.updated_at',   NOW(),
										'$.updated_by',   getJval(v_mm_json,'action_by')
									);

        /* =============== Start Transaction =============== */
        START TRANSACTION;

        UPDATE money_manager
        SET	  status             			= v_new_status,
              backoffice_post_number		= getJval(pjReqObj,'backoffice_post_number'),
              trans_posted_at				= getJval(pjReqObj,'trans_posted_at'),
              money_manager_json 			= v_mm_json,
			  row_metadata       			= v_row_metadata
        WHERE money_manager_rec_id = v_mm_rec_id;

        /* =============== Credit Card Update (If Exists) =============== */
        IF JSON_EXTRACT(v_mm_json,'$.transaction_type') = 'credit card' THEN
        
	  /* =============== get existed json of credit card and update with req obj  =============== */
        SET v_cc_json	 = fillTemplate(pjReqObj, getCreditCard(v_mm_rec_id));
        
     /* ================ APPEND OBJ in life cycle array in credit card ============ */
		SET v_cc_json	 		= JSON_ARRAY_APPEND( v_cc_json,
													'$.life_cycle',
													v_life_cycle
												  );		
        
            UPDATE credit_card
            SET	  status     				= v_new_status,
                  backoffice_post_number	= getJval(pjReqObj,'backoffice_post_number'),
				  trans_posted_at			= COALESCE(getJval(pjReqObj,'trans_posted_at'), NOW()),
                  card_json  				= v_cc_json,
                  row_metadata 				= v_row_metadata
            WHERE money_manager_rec_id = v_mm_rec_id;

        END IF;

        COMMIT;

        /* =============== Success Response =============== */
        SET psResObj = JSON_OBJECT(
            'status','success',
            'message','Transaction updated successfully'
        );

    END main_block;
END$$
DELIMITER ;
