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
    DECLARE v_clean_key     	VARCHAR(255);
    DECLARE v_value 			JSON;
    DECLARE i 					INT DEFAULT 0;
    DECLARE v_count 			INT;

    -- Get all keys of the request JSON
    SET v_req_keys 		= JSON_KEYS(pjReqObj);
    SET v_count 		= JSON_LENGTH(v_req_keys);

    WHILE i < v_count DO
		 -- Original key (example: P_DOC_TYPE)
        SET v_key 		= JSON_UNQUOTE(JSON_EXTRACT(v_req_keys, CONCAT('$[', i, ']')));
         -- Extract value
        SET v_value 	= JSON_EXTRACT(pjReqObj, CONCAT('$.', v_key));
        
        -- Remove leading 'P_' only if present
        IF LEFT(v_key, 2) = 'P_' THEN
            SET v_clean_key = SUBSTRING(v_key, 3);
        ELSE
            SET v_clean_key = v_key;
        END IF;
        
        -- Convert to lowercase
        SET v_clean_key = LOWER(v_clean_key);

        IF JSON_CONTAINS_PATH(v_result, 'one', CONCAT('$.', v_clean_key)) THEN

            SET v_result = buildJSONSmart(v_result, v_clean_key, v_value);

        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN v_result;
END $$

DELIMITER ;

