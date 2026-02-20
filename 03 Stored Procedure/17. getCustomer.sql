DROP PROCEDURE IF EXISTS getCustomer;

DELIMITER $$

CREATE PROCEDURE getCustomer(
							 IN  pReqObj JSON,
							 OUT pResObj JSON
							)
BEGIN

	DECLARE v_customer_rec_id 	INT;
    DECLARE v_customer_json 	JSON;
    
    SET v_customer_rec_id = getJval(pReqObj, 'P_CUSTOMER_REC_ID');
    
    -- Get customer JSON
    SELECT 	customer_json
    INTO 	v_customer_json
    FROM 	customer
    WHERE customer_rec_id = v_customer_rec_id
    LIMIT 1;

    -- If not found
    IF v_customer_json IS NULL THEN
        SET pResObj = JSON_OBJECT(
									'status', 'error',
									'message', 'Customer does not exist',
									'customer_rec_id', v_customer_rec_id
								);
    ELSE
        SET pResObj = JSON_OBJECT(
									'status', 'success',
									'message', 'Customer found',
									'customer_data', v_customer_json
								);
    END IF;

END $$

DELIMITER ;
