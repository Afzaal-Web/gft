DROP PROCEDURE IF EXISTS logActivity;
DELIMITER $$

CREATE PROCEDURE logActivity(
								IN p_logging_object     VARCHAR(64),
								IN p_parent_table_name  VARCHAR(64),
								IN p_parent_table_id    INT,
								IN p_user_info          JSON,
								IN p_web_request        JSON,
								IN p_internal_call      JSON
							)
BEGIN

	DECLARE v_row_metadata 		JSON;
    
    SET v_row_metadata 			= getTemplate('row_metadata');
    SET v_row_metadata			= JSON_SET(v_row_metadata, 
										   '$.created_at', NOW(),
                                           '$.created_by', p_parent_table_id
										 );
    
    INSERT INTO activity_log
    SET logging_object			= p_logging_object,
        parent_table_name 		= p_parent_table_name,
        parent_table_id 		= p_parent_table_id,
        log_time				= NOW(),
        user_info				= p_user_info,
        web_request				= p_web_request,
        internal_call			= p_internal_call,
        row_meta_data			= v_row_metadata;
        
END$$

DELIMITER ;
