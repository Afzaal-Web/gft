-- ==================================================================================================
-- Procedure:   getProduct
-- Purpose:     get the json of product with queried rec id
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getProduct;

DELIMITER $$

CREATE PROCEDURE getProduct(
								IN   	pjReqObj JSON,
								INOUT   pResObj  JSON
							)
BEGIN

    DECLARE v_product_json   	JSON;
	DECLARE v_product_type      VARCHAR(255);

	DECLARE v_page              INT;
	DECLARE v_limit             INT;
	DECLARE v_offset            INT;
	DECLARE v_total             INT;
    
    main_block: BEGIN
    
	-- =========================
        -- Extract Inputs
    -- =========================
        SET v_product_type 	= getJval(pjReqObj, 'jData.P_PRODUCT_TYPE');
        SET v_page      	= COALESCE(getJval(   pjReqObj, 'jMetaData.page'), 1);

        SET v_limit     	= COALESCE(getJval(   pjReqObj, 'jMetaData.limit'), 10);
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
        IF v_product_type IS NULL OR v_item_type = 'all' THEN

            SELECT COUNT(*)
            INTO v_total
            FROM products;

        ELSE

            SELECT COUNT(*)
            INTO v_total
            FROM inventory
            WHERE item_type = v_item_type;

        END IF;

		-- =========================
        -- Fetch Data (ARRAYAGG + PAGINATION)
        -- =========================
        IF v_product_type IS NULL OR v_product_type = 'all' THEN

            SELECT JSON_ARRAYAGG(product_json)
            INTO   v_product_json
            FROM (
                SELECT 		  product_json
                FROM 		  products
                ORDER BY 	  product_rec_id DESC
                LIMIT v_limit OFFSET v_offset
            ) t;

        ELSE

            SELECT JSON_ARRAYAGG(product_json)
            INTO   v_product_json
            FROM (
                SELECT 		  product_json
                FROM 		  products
				WHERE 		  product_type = v_product_type		
                ORDER BY 	  product_rec_id DESC
                LIMIT v_limit OFFSET v_offset
            ) t;

        END IF;

		-- =========================
        -- Handle empty result
        -- =========================
        IF v_product_json IS NULL THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Record does not exist for given product type');

			LEAVE main_block;
        END IF;
    
            -- =========================
        -- Response
        -- =========================

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Product records fetched successfully');
        	SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', v_product_json);
		

	END main_block;
    
    -- logging
    

END $$

DELIMITER ;

