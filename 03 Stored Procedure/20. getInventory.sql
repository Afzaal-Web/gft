DROP PROCEDURE IF EXISTS getInventory;

DELIMITER $$

CREATE PROCEDURE getInventory(
								IN  pReqObj JSON,
								OUT pResObj JSON
							)
BEGIN

	DECLARE v_inventory_rec_id 	INT;
    DECLARE v_inventory_json   	JSON;
    
	-- =========================
    -- Extract Inventory ID
    -- =========================
    SET v_inventory_rec_id = getJval(pReqObj, 'P_INVENTORY_REC_ID');
    
    main_block: BEGIN
    
		-- Validation
		IF v_inventory_rec_id IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Missing inventory_rec_id'
			);
			LEAVE main_block;
		END IF;
        
		-- Fetch inventory JSON
		SELECT  inventory_json
		INTO 	v_inventory_json
		FROM 	inventory
		WHERE inventory_rec_id = v_inventory_rec_id
		LIMIT 1;

		-- =========================
		-- Response Handling
		-- =========================
		IF v_inventory_json IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Inventory record does not exist',
				'inventory_rec_id', v_inventory_rec_id
			);
		ELSE
			SET pResObj = JSON_OBJECT(
				'status', 'success',
				'data', v_inventory_json
			);
		END IF;
	END main_block;
    
    -- logging
    

END $$

DELIMITER ;
