DROP FUNCTION IF EXISTS getInventory;

DELIMITER $$

CREATE FUNCTION getInventory(pInventoryRecId INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_inventory_json JSON;

    SELECT inventory_json
    INTO v_inventory_json
    FROM inventory
    WHERE inventory_rec_id = pInventoryRecId
    LIMIT 1;

    IF v_inventory_json IS NULL THEN
        SET v_inventory_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Inventory record does not exist',
            'inventory_rec_id', pInventoryRecId
        );
    END IF;

    RETURN v_inventory_json;
END $$

DELIMITER ;

SELECT getInventory(5);
