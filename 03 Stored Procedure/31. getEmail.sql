DROP PROCEDURE IF EXISTS queueOutboundMessage;

DELIMITER $$

CREATE PROCEDURE queueOutboundMessage (
										IN  pReqObj JSON,
										OUT pResObj JSON
									)
BEGIN
	DECLARE v_outbound_msgs_rec_id	INT;
    DECLARE v_message_guid 			VARCHAR(100);
    DECLARE v_new_json 				JSON;
    DECLARE v_outbound_msgs_json	JSON;
    DECLARE v_row_metadata			JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET pResObj = JSON_OBJECT(
									'status', 	'error',
									'message', 	'Failed to queue message'
								);
    END;

     -- =========================
    -- Generate message guid number
    -- ========================= 
    SET v_message_guid = CONCAT(
								 'MSG-',
								 DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
								 '-',
								 FLOOR(RAND() * 1000)
							 );

    -- =========================
    -- Get template JSON
    -- =========================                             
	SET v_outbound_msgs_json		 = getTemplate('outbound_msgs');
    
    -- =========================
    -- Set default values to json
    -- =========================    
    SET v_outbound_msgs_json		= JSON_SET( v_outbound_msgs_json,
												'$.message_guid',    					v_message_guid,
												
												'$.delivery_config.channel_number',   	1,
												'$.delivery_config.priority_level',   	'Normal',
												'$.delivery_config.is_need_tracking', 	TRUE,
                                           
												'$.scheduling.scheduled_at', 			NOW(),
												'$.scheduling.retry_interval', 			15,
												
												'$.lifecycle_status.current_status', 	'Queued',
												'$.lifecycle_status.delivery_status', 	'Pending',
												'$.lifecycle_status.send_attempts', 	0,
												'$.lifecycle_status.number_of_retries', 3
											);
	-- =========================
    -- fill remaining data from ReqObj
    -- =========================                                          
                                            
    SET v_outbound_msgs_json	= fillTemplate(pReqObj, v_outbound_msgs_json);
                                            
	
    SET v_row_metadata 			= getTemplate('row_metadata');
    SET v_row_metadata  		= JSON_SET(v_row_metadata,
										   '$.created_at', NOW(),
										   '$.created_by', 'System'
										);

    INSERT INTO outbound_msgs
    SET message_guid					= v_message_guid, 
        parent_message_table_name		= getJval(pReqObj, 'parent_message_table_name'),
        parent_message_table_rec_id		= getJval(pReqObj, 'parent_message_table_rec_id'),
        object_name						= getJval(pReqObj, 'object_name'),
        outbound_msgs_json				= v_outbound_msgs_json,
        row_metadata					= v_row_metadata;
        
	SET v_outbound_msgs_rec_id 			= LAST_INSERT_ID();
        
	SET v_outbound_msgs_json			= JSON_SET(v_outbound_msgs_json,
													'$.outbound_msgs_rec_id', v_outbound_msgs_rec_id
                                                    );
                                                    
	UPDATE  outbound_msgs
			SET 	outbound_msgs_json   = v_outbound_msgs_json
			WHERE   outbound_msgs_rec_id = v_outbound_msgs_rec_id;
    

	SET pResObj 						= JSON_OBJECT(
														'status', 'success',
														'message_guid', v_message_guid,
														'message', 'Message queued successfully'
													);

END $$

DELIMITER ;


-- Test Scripts

-- =============================================
-- Test Case 1: Normal Email Queue
-- =============================================

-- =========================
-- Test Script for queueOutboundMessage
-- =========================

SET @reqObj = JSON_OBJECT(
    "parent_message_table_name", "feedback",
    "parent_message_table_rec_id", 101,
    "object_name", "feedback",

    "business_context", JSON_OBJECT(
        "module_name", "Customer Module",
        "message_name", "Feedback Submission",
        "message_type", "Email",
        "notes", "Customer submitted feedback",
        "login_id", 1001
    ),

    "recipient_info", JSON_OBJECT(
        "to_address", "csr@gft.com",
        "cc_list", JSON_ARRAY(),
        "bcc_list", JSON_ARRAY(),
        "is_email_verified", TRUE
    ),

    "sender_info", JSON_OBJECT(
        "from_name", "GFT Support",
        "from_address", "no-reply@gft.com"
    ),

    "message_content", JSON_OBJECT(
        "message_subject", "New Feedback Received",
        "message_body", JSON_OBJECT(
            "customer_name", "Ali Khan",
            "email", "ali.khan@example.com",
            "phone", "03001234567",
            "feedback_type", "Product Issue",
            "comments", "The product arrived damaged."
        ),
        "attachment_list", JSON_ARRAY()
    )
);

-- Call the procedure
CALL queueOutboundMessage(@reqObj, @resObj);

-- View procedure response
SELECT @resObj AS response;


