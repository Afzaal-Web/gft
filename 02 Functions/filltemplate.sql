-- ==================================================================================================
-- Procedure: 			fillTemplate
-- Purpose:   			fill the template json using buildjson function
-- ===================================================================================================

DELIMITER $$

CREATE FUNCTION fillTemplate(
    pjReqObj     JSON,
    pjTemplateObj JSON
) 
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_result 			JSON DEFAULT pjTemplateObj;
    DECLARE v_req_keys 			JSON;
    DECLARE v_key 				VARCHAR(255);
    DECLARE v_value 			JSON;
    DECLARE i 					INT DEFAULT 0;
    DECLARE v_count 			INT;

    -- Get all keys of the request JSON
    SET v_req_keys 		= JSON_KEYS(pjReqObj);
    SET v_count 		= JSON_LENGTH(v_req_keys);

    WHILE i < v_count DO
        SET v_key 		= JSON_UNQUOTE(JSON_EXTRACT(v_req_keys, CONCAT('$[', i, ']')));
        SET v_value 	= JSON_EXTRACT(pjReqObj, CONCAT('$.', v_key));

        SET v_result = 	  buildJSONSmart(v_result, v_key, v_value);

        SET i = i + 1;
    END WHILE;

    RETURN v_result;
END $$

DELIMITER ;

