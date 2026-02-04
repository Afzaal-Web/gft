
DROP PROCEDURE IF EXISTS getMoneyManager;


DELIMITER $$

CREATE FUNCTION getMoneyManager(pMmRecId INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_mm_json JSON;

    SELECT money_manager_json
    INTO v_mm_json
    FROM money_manager
    WHERE money_manager_rec_id = pMmRecId
    LIMIT 1;

    IF v_mm_json IS NULL THEN
        SET v_mm_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Record does not exist',
            'money_manager_rec_id', pMmRecId
        );
    END IF;

    RETURN v_mm_json;
END $$

DELIMITER ;


 
 SELECT getMoneyManager(2);