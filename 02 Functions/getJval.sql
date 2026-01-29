-- ==================================================================================================
-- Procedure: 			getJval
-- Purpose:   			Extract Value from json object
-- ===================================================================================================

DROP FUNCTION IF EXISTS getJval;

DELIMITER $$
CREATE FUNCTION getJval(
						json_doc JSON,
						key_name TEXT
						)
RETURNS LONGTEXT
DETERMINISTIC
BEGIN

    RETURN JSON_UNQUOTE(JSON_EXTRACT(json_doc, CONCAT('$.', key_name)));
    
END $$
DELIMITER ;

-- Test script

SET @pjReqObj = JSON_OBJECT(
    'last_name', 	'Smith',
    'national_id',  '123445',
    'email', 		'alice.smith@example.com',
    'phone', 		'+19876543210'
);

SELECT getJKeyValue(@pjReqObj, 'first_name');
    

