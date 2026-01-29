DELIMITER $$

CREATE FUNCTION updateJsonByKeyaf (
    json_obj JSON,
    simple_key VARCHAR(255),
    key_value TEXT
) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE root_keys JSON;
    DECLARE key_count INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE this_root VARCHAR(255);
    DECLARE target_path VARCHAR(500);
    DECLARE result_json JSON DEFAULT json_obj;

    -- get array of top-level keys
    SET root_keys = JSON_KEYS(json_obj);
    IF root_keys IS NULL THEN
        RETURN json_obj;
    END IF;

    SET key_count = JSON_LENGTH(root_keys);

    SET i = 0;
    SCAN: WHILE i < key_count DO
        -- get root name at index i
        SET this_root = JSON_UNQUOTE(JSON_EXTRACT(root_keys, CONCAT('$[', i, ']')));

        -- build the path like $.customer.customer_last_location
        SET target_path = CONCAT('$.', this_root, '.', simple_key);

        -- check whether the path exists
        IF JSON_CONTAINS_PATH(json_obj, 'one', target_path) THEN
            SET result_json = JSON_SET(json_obj, target_path, key_value);
            LEAVE SCAN;
        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN result_json;
END $$
DELIMITER ;
