-- ==================================================================================================
-- Procedure: 					createInventory
-- Purpose:   					get inventory data and insert into inventory table
-- Functions used in this SP:
								-- isFalsy(): validate the values come from reqObj
								-- getJval(): get value from req object
								-- getTemplate(): template of JSON column used in tables
								-- fillTemplate(): used to insert values from reqObj in template json
                                -- mergeIfMissing(): merge missing keys in inventory from products 
-- ===================================================================================================

DROP PROCEDURE IF EXISTS createInventory;

DELIMITER $$

CREATE PROCEDURE createInventory(
								IN  pjReqObj JSON,
								OUT psResObj JSON
							  )
BEGIN
    /* ================ VARIABLE DECLARATIONS ================ */

    DECLARE v_inventory_rec_id      INT;
    DECLARE v_inventory_json        JSON;
    DECLARE v_product_json			JSON;
    DECLARE v_row_metadata          JSON;

    DECLARE v_errors                JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg               VARCHAR(1000);

    /* =============== GLOBAL ERROR HANDLER ============ */

    -- EXIT HANDLER for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
                                'status', 'error',
                                'message', 'Inventory creation failed',
                                'system_error', v_err_msg
                                );
    END;

    main_block: BEGIN

    /* ============== VALIDATIONS ============== */

    IF isFalsy(getJval(pjReqObj,'product_rec_id')) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_rec_id is required');
    END IF;

    IF isFalsy(getJval(pjReqObj,'item_name')) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_name is required');
    END IF;

    IF isFalsy(getJval(pjReqObj,'item_type')) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_type is required');
    END IF;

    IF isFalsy(getJval(pjReqObj,'availability_status')) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','availability_status is required');
    END IF;
    
	 /* ============== UPDATE must target existing record ============== */
     
    IF getJval(pjReqObj,'inventory_rec_id') IS NOT NULL
			   AND NOT EXISTS (
								SELECT 1
								FROM inventory
								WHERE inventory_rec_id = getJval(pjReqObj,'inventory_rec_id')
							  ) THEN
			   SET v_errors = JSON_ARRAY_APPEND(
				   v_errors,'$','Invalid inventory_rec_id: record does not exist'
			);
    END IF;
    
    IF JSON_LENGTH(v_errors) > 0 THEN
        SET psResObj = JSON_OBJECT(
								   'status',      'error',
								   'status_code', '1',
								   'errors',      v_errors
                                );
        LEAVE main_block;
    END IF;

    /* ============= JSON PREPARATION =========== */

    SET v_inventory_json = getTemplate('inventory');
    SET v_inventory_json = fillTemplate(pjReqObj, v_inventory_json);

    SET v_row_metadata = getTemplate('row_metadata');

    /* =============== TRANSACTION ============= */
       
	START TRANSACTION;

    /* =============== INSERT NEW ROW IF REC ID NOT EXISTS ============= */
    
    IF isFalsy(getJval(pjReqObj,'inventory_rec_id')) THEN

        SET v_row_metadata = JSON_SET(v_row_metadata,
                                        '$.created_by', 'SYSTEM',
                                        '$.created_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                      );
	
     
        INSERT INTO inventory
        SET product_rec_id       = getJval(pjReqObj,'product_rec_id'),
            item_name            = getJval(pjReqObj,'item_name'),
            item_type            = getJval(pjReqObj,'item_type'),
            asset_type           = getJval(pjReqObj,'asset_type'),
            availability_status  = getJval(pjReqObj,'availability_status'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata;

        SET v_inventory_rec_id = LAST_INSERT_ID();

        -- Sync ID back into JSON
        SET v_inventory_json = JSON_SET(v_inventory_json,'$.inventory_rec_id', v_inventory_rec_id);
        
        SELECT  products_json
        INTO    v_product_json
        FROM    products
        WHERE   product_rec_id = getJval(pjReqObj, 'product_rec_id');
        
		SET v_inventory_json = mergeIfMissing( v_inventory_json,
												JSON_ARRAY(
															'product_quality',
															'approximate_weight',
															'weight_unit',
															'dimensions',
															'is_physical',
															'is_SliceAble'
															),
												v_product_json
											);

        UPDATE inventory
        SET inventory_json = v_inventory_json
        WHERE inventory_rec_id = v_inventory_rec_id;

    
    /* =============== UPDATE EXISITING ROW ============= */
    
    ELSE
        SET v_inventory_rec_id = getJval(pjReqObj,'inventory_rec_id');

        SELECT  row_metadata, inventory_json
        INTO 	v_row_metadata, v_inventory_json
        FROM 	inventory
        WHERE 	inventory_rec_id = v_inventory_rec_id
        FOR UPDATE;

        SET v_row_metadata = JSON_SET( v_row_metadata,
										'$.updated_by', 'SYSTEM',
										'$.updated_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                  );

        SET v_inventory_json = fillTemplate(pjReqObj, v_inventory_json);

        UPDATE inventory
        SET product_rec_id       = getJval(pjReqObj,'product_rec_id'),
            item_name            = getJval(pjReqObj,'item_name'),
            item_type            = getJval(pjReqObj,'item_type'),
            asset_type           = getJval(pjReqObj,'asset_type'),
            availability_status  = getJval(pjReqObj,'availability_status'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata
        WHERE inventory_rec_id = v_inventory_rec_id;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: no rows affected';
        END IF;

    END IF;

    COMMIT;

    SET psResObj = JSON_OBJECT(
                                'status',      'success',
                                'status_code', '0',
                                'message',     'Inventory saved successfully'
                              );

    END main_block;

END $$

DELIMITER ;
