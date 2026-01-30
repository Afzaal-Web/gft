
DROP PROCEDURE IF EXISTS getAuth;


DELIMITER $$
CREATE FUNCTION getAuth(pCustomerRecId INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_auth_json JSON;

    SELECT 	auth_json
    INTO 	v_auth_json
    FROM 	auth
    WHERE parent_table_rec_id = pCustomerRecId
    LIMIT 1;

    IF v_auth_json IS NULL THEN
        SET v_auth_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Customer does not exist',
            'customer_rec_id', pCustomerRecId
        );
    END IF;

    RETURN v_auth_json;
END $$
DELIMITER ;


 
 SELECT getAuth(1);