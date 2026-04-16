-- ==================================================================================================
-- Procedure:   logActivity
-- Purpose:     log activity events
-- =================================================================================================



DROP PROCEDURE IF EXISTS logActivity;
DELIMITER $$

CREATE PROCEDURE logActivity(
								IN psLoggingObj     VARCHAR(64),
								IN pjlogJson        JSON
							)
BEGIN

    DECLARE v_activity_log_rec_id   INT;
	DECLARE v_activity_log          JSON;
    DECLARE v_row_metadata 		    JSON;


    SET v_activity_log          = getTemplate('activity_log');
    SET v_activity_log          = fillTemplate(pjlogJson, v_activity_log);

    SET v_activity_log          = buildJSONSmart(v_activity_log,   'log_time',      NOW());
    
    SET v_row_metadata 			= getTemplate('row_metadata');

    SET v_row_metadata          = buildJSONSmart(v_row_metadata,   'created_at',      NOW());
    SET v_row_metadata          = buildJSONSmart(v_row_metadata,   'created_by',      getJval(pjlogJson, 'P_CUSTOMER_REC_ID'));


    INSERT INTO user_activity_log
    SET logging_object          = psLoggingObj,
        action_code       		= getJval(pjlogJson, 'action_code'),
        client_ip           	= getJval(pjlogJson, 'client_ip'),
        log_time              	= NOW(),

        user_activity_log_json  = v_activity_log,
        row_meta_data		    = v_row_metadata;
    
    SET v_activity_log_rec_id   = LAST_INSERT_ID();

    SET v_activity_log          = buildJSONSmart(v_activity_log, 'activity_log_rec_id', v_activity_log_rec_id);

    UPDATE  user_activity_log
	SET 	user_activity_log_json    = v_activity_log
	WHERE   activity_log_rec_id       = v_activity_log_rec_id;
        
END$$

DELIMITER ;
