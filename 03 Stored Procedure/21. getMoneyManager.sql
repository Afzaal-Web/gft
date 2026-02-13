DROP PROCEDURE IF EXISTS getMoneyManager;

DELIMITER $$

CREATE PROCEDURE getMoneyManager(
    IN  pMmRecId      INT,
    OUT p_mm_json     JSON
)
BEGIN
    -- Fetch money manager JSON
    SELECT money_manager_json
    INTO p_mm_json
    FROM money_manager
    WHERE money_manager_rec_id = pMmRecId
    LIMIT 1;

    -- If not found
    IF p_mm_json IS NULL THEN
        SET p_mm_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Record does not exist',
            'money_manager_rec_id', pMmRecId
        );
    END IF;

END $$

DELIMITER ;
