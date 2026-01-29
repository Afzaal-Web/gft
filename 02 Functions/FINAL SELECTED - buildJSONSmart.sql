-- ==================================================================================================
-- Procedure: 	buildJSONSmart
-- Purpose:   	build the json from request object to template object
-- ===================================================================================================


DROP FUNCTION buildJSONSmart;

DELIMITER $$

CREATE  FUNCTION buildJSONSmart(
								json_obj 	JSON,
								simple_key 	VARCHAR(255),
								key_value 	TEXT
								) 
RETURNS json
DETERMINISTIC
BEGIN
			DECLARE roots 		JSON;
			DECLARE r 			INT 			DEFAULT 0;
			DECLARE root_name 	VARCHAR(255);

			DECLARE arr_len 	INT;
			DECLARE a 			INT;

			DECLARE child_keys 	 JSON;
			DECLARE c 			 INT;
			DECLARE child_name   VARCHAR(255);

			DECLARE path 		 VARCHAR(500);
			DECLARE jsonValue 	 JSON;

    /* ===================== VALUE TYPE DETECTION  ===================== */
			IF key_value IS NULL THEN
				SET jsonValue = CAST(NULL AS JSON);
                
			ELSEIF JSON_VALID(key_value) THEN
				SET jsonValue = CAST(key_value AS JSON);
                
			ELSEIF key_value REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN
				SET jsonValue = CAST(key_value AS DECIMAL(20,6));
                
			ELSEIF UPPER(key_value) IN ('TRUE','FALSE') THEN
				SET jsonValue = IF(UPPER(key_value)='TRUE', TRUE, FALSE);
                
			ELSE
				SET jsonValue = JSON_QUOTE(key_value);
			END IF;
    
      /* ===================== TOP-LEVEL KEY SUPPORT   ===================== */
			SET path = CONCAT('$.', simple_key);
			IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
				RETURN JSON_SET(json_obj, path, jsonValue);
			END IF;

			SET roots = JSON_KEYS(json_obj);

			ROOT_LOOP: WHILE r < JSON_LENGTH(roots) DO
				SET root_name = JSON_UNQUOTE(JSON_EXTRACT(roots, CONCAT('$[', r, ']')));

              /* ===================== root.key ===================== */  
				SET path = CONCAT('$.', root_name, '.', simple_key);
				IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
					RETURN JSON_SET(json_obj, path, jsonValue);
				END IF;

                /* ===================== root[index].key (ARRAY SAFE)  ===================== */
				IF JSON_TYPE(JSON_EXTRACT(json_obj, CONCAT('$.', root_name))) = 'ARRAY' THEN
					SET arr_len = JSON_LENGTH(JSON_EXTRACT(json_obj, CONCAT('$.', root_name)));
					SET a = 0;

					ARRAY_LOOP: WHILE a < arr_len DO
						SET path = CONCAT('$.', root_name, '[', a, '].', simple_key);
						IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
							SET json_obj = JSON_SET(json_obj, path, jsonValue);
						END IF;
						SET a = a + 1;
					END WHILE;

                /* ===================== root.child.key (OBJECT ONLY) ===================== */
				ELSEIF JSON_TYPE(JSON_EXTRACT(json_obj, CONCAT('$.', root_name))) = 'OBJECT' THEN
                
					SET child_keys = JSON_KEYS(JSON_EXTRACT(json_obj, CONCAT('$.', root_name)));
					SET c 		   = 0;

					CHILD_LOOP: WHILE c < JSON_LENGTH(child_keys) DO
						SET child_name = JSON_UNQUOTE(JSON_EXTRACT(child_keys, CONCAT('$[', c, ']')));
						SET path	   = CONCAT('$.', root_name, '.', child_name, '.', simple_key);
						IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
							RETURN JSON_SET(json_obj, path, jsonValue);
						END IF;
						SET c = c + 1;
					END WHILE;
				END IF;

				SET r = r + 1;
			END WHILE;

    RETURN json_obj;
END $$
DELIMITER ;