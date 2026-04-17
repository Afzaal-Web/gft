-- ==================================================================================================
-- Procedure:   queueOutboundMessage
-- Purpose:     queue an outbound message for delivery
-- ==================================================================================================

DROP PROCEDURE IF EXISTS queueOutboundMessage;

DELIMITER $$

CREATE PROCEDURE queueOutboundMessage (
										IN  pjReqObj JSON,
										OUT pResObj JSON
									)
BEGIN
	DECLARE v_outbound_msgs_rec_id		INT;
    DECLARE v_message_guid 				VARCHAR(100);
    DECLARE v_new_json 					JSON;
    DECLARE v_outbound_msgs_json		JSON;
    DECLARE v_row_metadata				JSON;

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
                                            
    SET v_outbound_msgs_json	= fillTemplate(pjReqObj, v_outbound_msgs_json);
                                            
	
    SET v_row_metadata 			= getTemplate('row_metadata');
    SET v_row_metadata  		= JSON_SET(v_row_metadata,
										   '$.created_at', NOW(),
										   '$.created_by', 'System'
										);

    INSERT INTO outbound_msgs
    SET message_guid					= v_message_guid, 
        parent_message_table_name		= getJval(pjReqObj, 'parent_message_table_name'),
        parent_message_table_rec_id		= getJval(pjReqObj, 'parent_message_table_rec_id'),
        object_name						= getJval(pjReqObj, 'object_name'),
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






