-- ==================================================================================================
-- Procedure: 					upsertInventory
-- Purpose:   					get inventory data and insert into inventory table
-- Functions used in this SP:
								-- isFalsy(): validate the values come from reqObj
								-- getJval(): get value from req object
								-- getTemplate(): template of JSON column used in tables
								-- fillTemplate(): used to insert values from reqObj in template json
                                -- getInventory(): gets the existed json of the inventory table row
                                -- getProduct();  gets the existed json of the prodcuts table row
-- ===================================================================================================

DROP PROCEDURE IF EXISTS upsertInventory;

DELIMITER $$

CREATE PROCEDURE upsertInventory(
								IN    pjReqObj JSON,
								INOUT pjRespObj JSON
							  )
BEGIN
    /* ================ VARIABLE DECLARATIONS ================ */
    
	DECLARE v_inventory_rec_id      INT;
    DECLARE v_mode 					VARCHAR(20);
    
    DECLARE v_inventory_json        JSON;
    DECLARE v_row_metadata          JSON;
	DECLARE v_product_json			JSON;

    DECLARE v_errors                JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg               VARCHAR(1000);

    /* =============== GLOBAL ERROR HANDLER ============ */

    -- EXIT HANDLER for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET pjRespObj       = buildJSONSmart( pjRespObj,  'jHeader.responseCode',   '1');
		SET pjRespObj 	   = buildJSONSmart( pjRespObj,
													'jHeader.message', CONCAT('Unexpected Error - Inventory creation failed ', v_err_msg)
													);                                
    END;

    main_block: BEGIN
    
    SET v_mode =
                CASE
                    WHEN isFalsy(getJval(pjReqObj, 'jData.P_')) THEN
                    'INSERT'
                    ELSE
                    'UPDATE'
				END;
                    
	CASE v_mode
    
    WHEN 'INSERT' THEN

    /* =============== INVENTORTY Insert VALIDATIONS : If required fields are missing in reqObj ================ */

		IF isFalsy(getJval(pjReqObj, 'jData.P_')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_rec_id is required');
		END IF;

		IF isFalsy(getJval(pjReqObj, 'jData.P_')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_name is required');
		END IF;

		IF isFalsy(getJval(pjReqObj, 'jData.P_')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_type is required');
		END IF;

		IF isFalsy(getJval(pjReqObj, 'jData.P_')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','availability_status is required');
		END IF;

		IF JSON_LENGTH(v_errors) > 0 THEN
            SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.responseCode',   '1');
			SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.message',        v_errors);                                    
        LEAVE main_block;
        END IF;

        /* =============== CREATE INVENTORY: Inventory Insertation started ================ */

        /* ============= JSON PREPARATION =========== */

        SET v_inventory_json 	= getTemplate('inventory');

            -- fill template from reqJson
    
        SET v_inventory_json 	= fillTemplate(pjReqObj, v_inventory_json);
        
        SET v_row_metadata   	= getTemplate('row_metadata');

        SET v_row_metadata      = JSON_SET(v_row_metadata,
                                            '$.created_by', 'SYSTEM',
											'$.created_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                         );

        INSERT INTO inventory
        SET product_rec_id       = getJval(pjReqObj, 'jData.P_'),
            item_name            = getJval(pjReqObj, 'jData.P_'),
            item_type            = getJval(pjReqObj, 'jData.P_'),
            asset_type           = getJval(pjReqObj, 'jData.P_'),
            availability_status  = getJval(pjReqObj, 'jData.P_'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata;

        SET v_inventory_rec_id   = LAST_INSERT_ID();

        -- Sync REC ID back into Inventory JSON
        SET v_inventory_json = JSON_SET(v_inventory_json,'$.inventory_rec_id', v_inventory_rec_id);

        -- get json of existed product from product table
        
         SET v_product_json     = getProduct(getJval(pjReqObj, 'jData.P_'));

		-- fill the inventory json from product json
		SET v_inventory_json 	= mergeIfMissing( v_inventory_json,
													JSON_ARRAY(
																'product_quality',
																'approximate_weight',
																'weight_unit',
																'is_physical',
																'is_SliceAble',
																'standard_price',
																'standard_premium',
																'price_currency',
																'applicable_taxes',
																'quantity_on_hand',
																'minimum_order_quantity',
																'total_sold',
																'offer_to_customer',
																'display_order',
																'Alert_on_low_stock',
																'transaction_fee'
																),
													v_product_json
												);

        UPDATE  inventory
        SET 	inventory_json = v_inventory_json
        WHERE  inventory_rec_id = v_inventory_rec_id; 


    /* =============== UPDATE Inventory: Product UPDATION started ================ */

    WHEN 'UPDATE' THEN
        
        /* =============== Inventory Insert VALIDATIONS: UPDATE must target existing record ================ */
        SET v_inventory_rec_id = getJval(pjReqObj, 'jData.P_');
     
		IF v_inventory_rec_id IS NOT NULL
		AND NOT EXISTS (
                          SELECT 1
                          FROM   inventory
                          WHERE  inventory_rec_id = getJval(pjReqObj, 'jData.P_')
                        ) THEN
                                                              
			   SET v_errors = JSON_ARRAY_APPEND( v_errors,'$','Invalid inventory_rec_id: record does not exist');
		END IF;

    
    IF JSON_LENGTH(v_errors) > 0 THEN

			SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.responseCode',   '1');
			SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.message', 		v_errors);   

        LEAVE main_block;
    END IF;

             /* =============== Update started: update the existed row ================ */   

        SET v_inventory_json = getInventory(v_inventory_rec_id);

        SET v_inventory_json = fillTemplate(pjReqObj,v_inventory_json);

        SELECT  row_metadata
        INTO 	v_row_metadata
        FROM 	inventory
        WHERE 	inventory_rec_id = v_inventory_rec_id;

        SET v_row_metadata = JSON_SET( v_row_metadata,
										'$.updated_by', 'SYSTEM',
										'$.updated_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                  );

        UPDATE inventory
        SET product_rec_id       = getJval(v_inventory_json,'product_rec_id'),	
            item_name            = getJval(v_inventory_json,'item_name'), 		
            item_type            = getJval(v_inventory_json,'item_type'), 		
            asset_type           = getJval(v_inventory_json,'asset_type'), 		
            availability_status  = getJval(v_inventory_json,'availability_status'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata
        WHERE inventory_rec_id   = v_inventory_rec_id;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: no rows affected';
        END IF;
	END CASE;

     /* =============== Final response preparation: success response with updated/created inventory json ================ */
   
    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);

	SET pjRespObj = buildJSONSmart( pjRespObj,
							   'jHeader.message', IF( isFalsy(getJval(pjReqObj, 'jData.P_INVENTORY_REC_ID')),
														  'Success - Inventory saved successfully',
														  'Success - Inventory updated successfully'
														)
								);                              

    END main_block;

    -- inert general code here like LOG
	-- call log proc
END $$

DELIMITER ;

