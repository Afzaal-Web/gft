
DROP FUNCTION IF EXISTS getCreditCard;

DELIMITER $$

CREATE FUNCTION getCreditCard(pMmRecId INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_cc_json JSON;

    SELECT credit_card_json
    INTO   v_cc_json
    FROM  credit_card
    WHERE money_manager_rec_id = pMmRecId
    LIMIT 1;

    IF v_cc_json IS NULL THEN
        SET v_cc_json = JSON_OBJECT(
									'status', 'error',
									'message', 'Record does not exist',
									'money_manager_rec_id', pMmRecId
									);
    END IF;

    RETURN v_cc_json;
END $$

DELIMITER ;


 
 SELECT getCreditCard(4);