-- ==================================================================================================
-- Function: 					mergeIfMissing
-- Purpose:   					merge the missing keys from target json to a source json
-- Example usage:
							-- mergeIfMissing(inventory_json, '["product_quality","standard_price"]', products_json)
-- ===================================================================================================

-- Example usage:
-- mergeIfMissing(inventory_json, '["product_quality","standard_price"]', products_json)
DELIMITER $$

CREATE FUNCTION mergeIfMissing(
                            pjTarget    JSON,       -- inventory_json
                            pjKeys      JSON,       -- JSON array of key names to copy from product_json
                            pjSource    JSON        -- product_json
)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE i           INT DEFAULT 0;
    DECLARE n           INT;
    DECLARE keyName     VARCHAR(255);
    DECLARE vResult     JSON;

    SET vResult         = pjTarget;
    SET n               = JSON_LENGTH(pjKeys);

    WHILE i < n DO
        SET keyName = JSON_UNQUOTE(JSON_EXTRACT(pjKeys, CONCAT('$[', i, ']')));

        -- If key exists in source
        IF JSON_CONTAINS_PATH(pjSource, 'one', CONCAT('$.', keyName)) THEN

            -- If key is missing in target, copy it
            IF NOT JSON_CONTAINS_PATH(vResult, 'one', CONCAT('$.', keyName)) THEN
                SET vResult = JSON_SET(
                    vResult,
                    CONCAT('$.', keyName),
                    JSON_EXTRACT(pjSource, CONCAT('$.', keyName))
                );
            ELSE
                -- If key exists and is an object, merge recursively
                IF JSON_TYPE(JSON_EXTRACT(vResult, CONCAT('$.', keyName))) = 'OBJECT'
                   AND JSON_TYPE(JSON_EXTRACT(pjSource, CONCAT('$.', keyName))) = 'OBJECT' THEN
                    SET vResult = JSON_MERGE_PATCH(
                        vResult,
                        JSON_OBJECT(keyName, JSON_MERGE_PATCH(
                            JSON_EXTRACT(vResult, CONCAT('$.', keyName)),
                            JSON_EXTRACT(pjSource, CONCAT('$.', keyName))
                        ))
                    );
                END IF;
            END IF;

        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN vResult;
END $$

DELIMITER ;
