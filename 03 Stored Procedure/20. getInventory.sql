-- ==================================================================================================
-- Procedure:   getInventory
-- Purpose:     get inventory records with optional item_type filter + pagination
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getInventory;

DELIMITER $$

CREATE PROCEDURE getInventory(
								IN    pjReqObj JSON,
								INOUT pjRespObj JSON
							)
BEGIN

    DECLARE v_inventory_json   	JSON;
	DECLARE v_item_type         VARCHAR(50);
	DECLARE v_page              INT;
	DECLARE v_limit             INT;
	DECLARE v_offset            INT;
	DECLARE v_total             INT;

	main_block: BEGIN
    
	-- =========================
        -- Extract Inputs
    -- =========================
        SET v_item_type 	= getJval(pjReqObj, 'jData.P_ITEM_TYPE');
        SET v_page      	= getJval(pjReqObj, 'jMetaData.page');
        SET v_limit     	= getJval(   pjReqObj, 'jMetaData.limit');
        SET v_offset 		= (v_page - 1) * v_limit;

		-- =========================
        -- Validation
        -- =========================
        IF v_page <= 0 THEN
            SET v_page = 1;
        END IF;

		IF v_limit <= 0 THEN
            SET v_limit = 10;
        END IF;

		 -- =========================
        -- Count total records
        -- =========================
        IF v_item_type IS NULL OR v_item_type = 'all' THEN

            SELECT COUNT(*)
            INTO v_total
            FROM inventory;

        ELSE

            SELECT COUNT(*)
            INTO v_total
            FROM inventory
            WHERE item_type = v_item_type;

        END IF;

		-- =========================
        -- Fetch Data (ARRAYAGG + PAGINATION)
        -- =========================
        IF v_item_type IS NULL OR v_item_type = 'all' THEN

            SELECT JSON_ARRAYAGG(inventory_json)
            INTO   v_inventory_json
            FROM (
                SELECT 		  inventory_json
                FROM 		  inventory
                ORDER BY 	  inventory_rec_id DESC
                LIMIT v_limit OFFSET v_offset
            ) t;

        ELSE

            SELECT JSON_ARRAYAGG(inventory_json)
            INTO   v_inventory_json
            FROM (
                SELECT 		  inventory_json
                FROM 		  inventory
                WHERE 		  item_type = v_item_type
                ORDER BY 	  inventory_rec_id DESC
                LIMIT v_limit OFFSET v_offset
            ) t;

        END IF;

		-- =========================
        -- Handle empty result
        -- =========================
        IF v_inventory_json IS NULL THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Record does not exist for given item type');

			LEAVE main_block;
        END IF;
    
            -- =========================
        -- Response
        -- =========================

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Inventory records fetched successfully');
        	SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', v_inventory_json);
		

	END main_block;
    
    -- logging
    

END $$

DELIMITER ;
