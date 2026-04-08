DROP PRCEDURE IF EXISTS debugLog;

DELIMITER ##
CREATE PROCEDURE debugLog 
                        (
                            psObjectName TEXT,
                            psMessage    TEXT 
                         )
BEGIN
	insert into debug_tbl	
    SET         logging_object      = psObjectName, 	
                desc_msg            = psMessage;
END##

DELIMITER ;