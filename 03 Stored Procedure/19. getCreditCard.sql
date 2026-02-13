DROP PROCEDURE IF EXISTS getCreditCard;

DELIMITER $$

CREATE PROCEDURE getCreditCard(
    IN  pMmRecId        INT,
    OUT p_cc_json       JSON
)
BEGIN
    -- Fetch credit card JSON
    SELECT credit_card_json
    INTO p_cc_json
    FROM credit_card
    WHERE money_manager_rec_id = pMmRecId
    LIMIT 1;

    -- If not found
    IF p_cc_json IS NULL THEN
        SET p_cc_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Record does not exist',
            'money_manager_rec_id', pMmRecId
        );
    END IF;

END $$

DELIMITER ;
