DELIMITER $$

CREATE FUNCTION buildJSON(
    pjObj JSON,
    psKeyName VARCHAR(255),
    psValue TEXT
) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE new_json JSON;
    DECLARE path_part VARCHAR(255);
    DECLARE path_parts INT;
    DECLARE path_index INT;
    DECLARE json_path VARCHAR(255);
    DECLARE jsonValue JSON;

    -- If base object is NULL, create empty object
    IF pjObj IS NULL THEN
        SET pjObj = JSON_OBJECT();
    END IF;

    -- AUTO-DETECT the actual JSON type of psValue
    CASE
        WHEN psValue IS NULL THEN
            SET jsonValue = CAST(NULL AS JSON);

        -- If psValue is already valid JSON (object or array)
        WHEN JSON_VALID(psValue) THEN
            SET jsonValue = CAST(psValue AS JSON);

        -- If psValue is numeric
        WHEN psValue REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN
            SET jsonValue = CAST(psValue AS DECIMAL(20,6));

        -- If psValue is TRUE/FALSE (case-insensitive)
        WHEN UPPER(psValue) IN ('TRUE','FALSE') THEN
            SET jsonValue = IF(UPPER(psValue)='TRUE', TRUE, FALSE);

        -- ELSE treat as string
        ELSE
            SET jsonValue = JSON_QUOTE(psValue);
    END CASE;

    -- Build the nested JSON path "a.b.c"
    SET path_parts = LENGTH(psKeyName) - LENGTH(REPLACE(psKeyName, '.', '')) + 1;
    SET json_path = '$.';
    SET path_index = 1;

    WHILE path_index <= path_parts DO
        SET path_part = SUBSTRING_INDEX(
                            SUBSTRING_INDEX(psKeyName, '.', path_index),
                            '.',
                            -1
                        );
        SET json_path = CONCAT(json_path, JSON_QUOTE(path_part));

        IF path_index < path_parts THEN
            SET json_path = CONCAT(json_path, '.');
        END IF;

        SET path_index = path_index + 1;
    END WHILE;

    -- Insert JSON value properly (object / array / string / number)
    SET new_json = JSON_SET(pjObj, json_path, jsonValue);

    RETURN new_json;
END $$
DELIMITER ;