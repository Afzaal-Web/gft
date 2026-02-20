DROP PROCEDURE IF EXISTS getProduct;

DELIMITER $$

CREATE PROCEDURE getProduct(
								IN  pReqObj JSON,
								OUT pResObj JSON
							)
BEGIN

	DECLARE v_product_rec_id 	INT;
    DECLARE v_product_json   	JSON;
    
	-- =========================
    -- Extract Product ID
    -- =========================
    SET v_product_rec_id = getJval(pReqObj, 'P_PRODUCT_REC_ID');
    
    main_block: BEGIN
    
		-- Validation
		IF v_product_rec_id IS NULL THEN
			SET pResObj = JSON_OBJECT(
										'status', 'error',
										'message', 'Missing product_rec_id'
									);
			LEAVE main_block;
		END IF;
        
		-- Fetch product JSON
		SELECT  products_json
		INTO 	v_product_json
		FROM 	products
		WHERE 	product_rec_id = v_product_rec_id
		LIMIT 1;

		-- =========================
		-- Response Handling
		-- =========================
		IF v_product_json IS NULL THEN
			SET pResObj = JSON_OBJECT(
				'status', 'error',
				'message', 'Product does not exist',
				'product_rec_id', v_product_rec_id
			);
		ELSE
			SET pResObj = JSON_OBJECT(
				'status', 'success',
				'data', v_product_json
			);
		END IF;

	END main_block;
    
    -- logging
    

END $$

DELIMITER ;
