-- ==================================================================================================
-- Procedure:   documentManagment
-- Purpose:     manage document uploads for customers and employees
-- ==================================================================================================

DROP PROCEDURE IF EXISTS documentManagment;


DELIMITER $$

CREATE PROCEDURE documentManagment(
									IN pjReqObj JSON,
                                    OUT pjResObj JSON
								  )
BEGIN
	
    DECLARE v_document_management_rec_id		INT;
    DECLARE v_login_id							VARCHAR(255);
    DECLARE v_doc_type	     					VARCHAR(150);
    DECLARE v_notes	        					TEXT;
    DECLARE v_attachment_url   					VARCHAR(255);
    DECLARE v_user_type             			VARCHAR(50);
    
    DECLARE v_customer_rec_id					INT;
    DECLARE v_org_employee_rec_id				INT;
    
    DECLARE v_document_mng_json					JSON;
    DECLARE v_row_metadata          			JSON DEFAULT getTemplate('row_metadata');
    
    DECLARE v_errors              				JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg       					TEXT;
    
    /* ===================== Exception Handler ===================== */
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET pjResObj = JSON_OBJECT(
									'status', 			'error',
									'status_code',		'1',
									'message', 			'Failed to upload document',
									'system_error',		v_err_msg
								   );
    END;
    
    main_block: BEGIN
    
		/* ===================== Extract Scalars ===================== */
		SET v_doc_type   		= getJval(pjReqObj, 'P_DOC_TYPE');
		SET v_notes		 		= getJval(pjReqObj, 'P_NOTES');
		SET v_attachment_url  	= getJval(pjReqObj, 'P_ATTACHMENT_URL');
        SET v_login_id			= getJval(pjReqObj, 'P_LOGIN_ID');
        SET v_user_type			= getJval(pjReqObj, 'P_USER_TYPE'); -- CUSTOMER OR EMPLOYEE
        
        /* -------- Normalize -------- */
        SET v_user_type			= UPPER(TRIM(v_user_type));
    
    
    
	  /* ===================== Validations ===================== */
        IF isFalsy(v_login_id) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'login_id is required');
        END IF;
        
		IF isFalsy(v_user_type) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'User type is required');
        END IF;

        IF isFalsy(v_doc_type) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'document type is required');
        END IF;

        IF isFalsy(v_attachment_url) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'attachment url is required');
        END IF;
        
          /* Validate allowed user types */
        IF NOT isFalsy(v_user_type)
           AND v_user_type NOT IN ('CUSTOMER','EMPLOYEE') THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'user_type must be CUSTOMER or EMPLOYEE');
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
            SET pjResObj = JSON_OBJECT(
										'status',      'error',
										'status_code', 0,
										'errors',      v_errors
									);
            LEAVE main_block;
        END IF;

        
        /* ===================== Identify User Based on Type ===================== */

        IF v_user_type = 'CUSTOMER' THEN

            SELECT  customer_rec_id
            INTO 	v_customer_rec_id
            FROM    customer
            WHERE   email = v_login_id
               OR  phone = v_login_id
               OR  user_name = v_login_id
            LIMIT 1;

            IF v_customer_rec_id IS NULL THEN
                SET pjResObj = JSON_OBJECT(
											'status',		'error',
											'status_code',	0,
											'message',		'Customer not found'
										);
                LEAVE main_block;
            END IF;
		
        ELSEIF v_user_type = 'EMPLOYEE' THEN

            SELECT  org_employee_rec_id
            INTO 	v_org_employee_rec_id
            FROM 	org_employees
            WHERE 	primary_phone_number 	= v_login_id
               OR 	primary_email_address 	= v_login_id
               OR 	user_name 				= v_login_id
            LIMIT 1;

            IF v_org_employee_rec_id IS NULL THEN
                SET pjResObj = JSON_OBJECT(
											'status',		'error',
											'status_code',	0,
											'message',		'Employee not found'
										);
                LEAVE main_block;
            END IF;

        END IF;
            
        
		/* ===================== Build Template ===================== */
        SET v_document_mng_json 	=  fillTemplate(pjReqObj, getTemplate('document_management'));
        
        SET v_row_metadata			= JSON_SET(v_row_metadata,
												'$.created_at',	 NOW(),
                                                '$.created_by', v_login_id
                                                );
        
      /* ===================== Insert Document  ===================== */
		IF v_user_type = 'CUSTOMER' THEN

            INSERT INTO document_management
            SET customer_rec_id        			= v_customer_rec_id,
                document_management_json 		= v_document_mng_json,
                row_metadata           			= v_row_metadata;
			
            SET v_document_management_rec_id 	= LAST_INSERT_ID();
            SET v_document_mng_json				= JSON_SET(v_document_mng_json,
															'$.document_management_rec_id', v_document_management_rec_id,
															'$.customer_rec_id', v_customer_rec_id);
                                                            
			UPDATE  document_management
			SET 	document_management_json  	= v_document_mng_json
			WHERE   document_management_rec_id = v_document_management_rec_id;

        ELSE

            INSERT INTO document_management
            SET org_employee_rec_id      	= v_org_employee_rec_id,
                document_management_json 	= v_document_mng_json,
                row_metadata             	= v_row_metadata;
                
			SET v_document_management_rec_id 	= LAST_INSERT_ID();
            
            SET v_document_mng_json				= JSON_SET(v_document_mng_json,
															'$.document_management_rec_id', v_document_management_rec_id,
															'$.employee_rec_id', v_org_employee_rec_id);
                                                            
			UPDATE  document_management
			SET 	document_management_json  	= v_document_mng_json
			WHERE   document_management_rec_id 	= v_document_management_rec_id;

        END IF;
        
		 /* ===================== Success Response ===================== */
        SET pjResObj = JSON_OBJECT(
									'status',      	'success',
									'status_code', 	1,
									'message',     	'Document uploaded successfully'
								);
    END main_block;
    
    -- logging

END $$

DELIMITER ;

