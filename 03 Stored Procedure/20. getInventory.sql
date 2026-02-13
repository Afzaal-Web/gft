DROP PROCEDURE IF EXISTS getInventory;

DELIMITER $$

CREATE PROCEDURE getInventory(
    IN  pInventoryRecId   INT,
    OUT p_inventory_json  JSON
)
BEGIN
    -- Fetch inventory JSON
    SELECT inventory_json
    INTO p_inventory_json
    FROM inventory
    WHERE inventory_rec_id = pInventoryRecId
    LIMIT 1;

    -- If not found
    IF p_inventory_json IS NULL THEN
        SET p_inventory_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Inventory record does not exist',
            'inventory_rec_id', pInventoryRecId
        );
    END IF;

END $$

DELIMITER ;
