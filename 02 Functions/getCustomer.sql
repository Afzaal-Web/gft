
DROP PROCEDURE IF EXISTS getCustomer;


DELIMITER $$

CREATE FUNCTION getCustomer(pCustomerRecId INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_customer_json JSON;

    SELECT customer_json
    INTO v_customer_json
    FROM customer
    WHERE customer_rec_id = pCustomerRecId
    LIMIT 1;

    IF v_customer_json IS NULL THEN
        SET v_customer_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Customer does not exist',
            'customer_rec_id', pCustomerRecId
        );
    END IF;

    RETURN v_customer_json;
END $$

DELIMITER ;


 
 SELECT getCustomer(2);