-- ==================================================================================================
-- Procedure: 			fillTemplate
-- Purpose:   			fill the template json with values from request object
--                     UPDATED: Now recursively merges nested objects using mergeJsonObjects
--                     Preserves all template structure while updating with request values
--                     Uses buildJSONSmart for proper value type detection and path handling
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
    DECLARE v_template_value	JSON;
    DECLARE v_nested_result  	JSON;
    DECLARE i 					INT DEFAULT 0;
    DECLARE v_count 			INT;
    DECLARE v_nested_keys		JSON;
    DECLARE v_nested_key		VARCHAR(255);
    DECLARE v_nested_count		INT;
    DECLARE j					INT DEFAULT 0;
    DECLARE v_nested_value		JSON;
    DECLARE v_nested_clean_key	VARCHAR(255);

    IF pjReqObj IS NULL OR pjTemplateObj IS NULL THEN
        RETURN pjTemplateObj;
    END IF;

    -- Get all keys from request object
    SET v_req_keys = JSON_KEYS(pjReqObj);
    SET v_count = JSON_LENGTH(v_req_keys);

    WHILE i < v_count DO
        SET v_key = JSON_UNQUOTE(JSON_EXTRACT(v_req_keys, CONCAT('$[', i, ']')));
        SET v_value = JSON_EXTRACT(pjReqObj, CONCAT('$.', v_key));
        
        -- Remove leading 'P_' if present
        IF LEFT(v_key, 2) = 'P_' THEN
            SET v_clean_key = SUBSTRING(v_key, 3);
        ELSE
            SET v_clean_key = v_key;
        END IF;
        
        -- Convert to lowercase
        SET v_clean_key = LOWER(v_clean_key);

        -- Check if this key exists in template
        IF JSON_CONTAINS_PATH(v_result, 'one', CONCAT('$.', v_clean_key)) THEN
            SET v_template_value = JSON_EXTRACT(v_result, CONCAT('$.', v_clean_key));
            
            -- If both are objects, recursively merge nested fields
            IF JSON_TYPE(v_value) = 'OBJECT' AND JSON_TYPE(v_template_value) = 'OBJECT' THEN
                SET v_nested_result = v_template_value;
                SET v_nested_keys = JSON_KEYS(v_value);
                SET v_nested_count = JSON_LENGTH(v_nested_keys);
                SET j = 0;
                
                -- Process each nested key
                WHILE j < v_nested_count DO
                    SET v_nested_key = JSON_UNQUOTE(JSON_EXTRACT(v_nested_keys, CONCAT('$[', j, ']')));
                    SET v_nested_value = JSON_EXTRACT(v_value, CONCAT('$.', v_nested_key));
                    
                    -- Remove P_ prefix from nested key
                    IF LEFT(v_nested_key, 2) = 'P_' THEN
                        SET v_nested_clean_key = SUBSTRING(v_nested_key, 3);
                    ELSE
                        SET v_nested_clean_key = v_nested_key;
                    END IF;
                    
                    -- Convert to lowercase
                    SET v_nested_clean_key = LOWER(v_nested_clean_key);
                    
                    -- Use buildJSONSmart to set nested value
                    IF JSON_CONTAINS_PATH(v_nested_result, 'one', CONCAT('$.', v_nested_clean_key)) THEN
                        SET v_nested_result = buildJSONSmart(v_nested_result, v_nested_clean_key, v_nested_value);
                    END IF;
                    
                    SET j = j + 1;
                END WHILE;
                
                -- Set the merged nested object back into result
                SET v_result = JSON_SET(v_result, CONCAT('$.', v_clean_key), v_nested_result);
            ELSE
                -- For scalar values, use buildJSONSmart directly
                SET v_result = buildJSONSmart(v_result, v_clean_key, v_value);
            END IF;
        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN v_result;
END $$

DELIMITER ;

