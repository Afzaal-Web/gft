DROP PROCEDURE IF EXISTS getAuth;

DELIMITER $$

CREATE PROCEDURE getAuth(
    IN  pCustomerRecId INT,
    OUT p_auth_json    JSON
)
BEGIN
    -- Fetch auth JSON
    SELECT auth_json
    INTO p_auth_json
    FROM auth
    WHERE parent_table_rec_id = pCustomerRecId
    LIMIT 1;

    -- If not found
    IF p_auth_json IS NULL THEN
        SET p_auth_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Customer does not exist',
            'customer_rec_id', pCustomerRecId
        );
    END IF;

END $$

DELIMITER ;
