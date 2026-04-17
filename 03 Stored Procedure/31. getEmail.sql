-- ==================================================================================================
-- Procedure:   queueOutboundMessage
-- Purpose:     queue an outbound message for delivery
-- ==================================================================================================

DROP PROCEDURE IF EXISTS queueOutboundMessage;

DELIMITER $$

CREATE PROCEDURE queueOutboundMessage (
										IN  	pjReqObj JSON,
										INOUT 	pjRespObj JSON
									)
BEGIN
	DECLARE v_outbound_msgs_rec_id		INT;
    DECLARE v_message_guid 				VARCHAR(100);
    DECLARE v_new_json 					JSON;
    DECLARE v_outbound_msgs_json		JSON;
    DECLARE v_row_metadata				JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
 
		SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 	1);
    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 		'Failed to queue message');

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
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'message_guid', 						v_message_guid);   
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'delivery_config.channel_number',   	1);
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'delivery_config.priority_level',   	'Normal');

	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'delivery_config.is_need_tracking',   'TRUE');
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'scheduling.scheduled_at',   NOW());
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'scheduling.retry_interval',   15);

	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'lifecycle_status.current_status',   'Queued');
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'lifecycle_status.delivery_status',   'Pending');
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'lifecycle_status.send_attempts',   	  0);
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'lifecycle_status.number_of_retries',  3);
	-- =========================
    -- fill remaining data from ReqObj
    -- =========================                                          
                                            
    SET v_outbound_msgs_json	= fillTemplate(pjReqObj, v_outbound_msgs_json);
                                            
	
    SET v_row_metadata 			= getTemplate('row_metadata');

	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'created_at',   	  NOW());
	SET v_outbound_msgs_json   = buildJSONSmart( v_outbound_msgs_json, 'created_by',  	 'System');

    INSERT INTO outbound_msgs
    SET message_guid					= v_message_guid, 
        parent_message_table_name		= getJval(pjReqObj, 'parent_message_table_name'),
        parent_message_table_rec_id		= getJval(pjReqObj, 'parent_message_table_rec_id'),
        object_name						= getJval(pjReqObj, 'object_name'),
        outbound_msgs_json				= v_outbound_msgs_json,
        row_metadata					= v_row_metadata;
        
	SET v_outbound_msgs_rec_id 			= LAST_INSERT_ID();

	SET v_outbound_msgs_json   			= buildJSONSmart( v_outbound_msgs_json, 'outbound_msgs_rec_id',   v_outbound_msgs_rec_id);
                                                    
	UPDATE  outbound_msgs
			SET 	outbound_msgs_json   = v_outbound_msgs_json
			WHERE   outbound_msgs_rec_id = v_outbound_msgs_rec_id;
    

	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 			0);
    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.queuedMessage', 	   'Message queued successfully');

END $$

DELIMITER ;






