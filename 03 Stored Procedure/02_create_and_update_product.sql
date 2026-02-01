-- ==================================================================================================
-- Procedure: 					upsertProduct
-- Purpose:   					get prodcuts data and insert and update products table 
-- Functions used in this Pro:
								-- isFalsy(): 				validate the values come from reqObj
								-- getJval(): 				get value of req object
								-- getTemplate(): 			template of json column used in tables
								-- fillTemplate(): 			used to insert values from reqObj in template json
                                -- getProduct(): 			gets the existed json of the row
-- ===================================================================================================

DROP PROCEDURE IF EXISTS upsertProduct;

DELIMITER $$

CREATE PROCEDURE upsertProduct(
								IN  pjReqObj JSON,
								OUT psResObj JSON
							  )
BEGIN
		/* ================ VARIABLE DECLARATIONS ================ */

		DECLARE v_product_rec_id         	INT;
        DECLARE v_tradable_assets_rec_id	INT;
        DECLARE v_mode 						VARCHAR(20);
        
		DECLARE v_products_json          	JSON;
		DECLARE v_row_metadata           	JSON;
    
		DECLARE v_errors 					JSON 				DEFAULT JSON_ARRAY();
		DECLARE v_err_msg       		    VARCHAR(1000);

    /* =============== GLOBAL ERROR HANDLER ============ */

		-- EXIT HANDLER for any SQL exception
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
				GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
				SET psResObj = JSON_OBJECT(
											'status', 'error',
											'message', 'Product creation failed',
											'system_error', v_err_msg
											);
		END;

	main_block: BEGIN
     
     	SET v_mode =
					CASE
						WHEN isFalsy(getJval(pjReqObj,'product_rec_id')) THEN
						'INSERT'
						ELSE
						'UPDATE'
					END;
	
    CASE v_mode
    
		WHEN 'INSERT' THEN

			/* =============== Product Insert VALIDATIONS : If required fields are missing in reqObj ================ */

			IF isFalsy(getJval(pjReqObj,'tradable_assets_rec_id')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','tradable_assets_rec_id is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'asset_code')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','asset_code is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'product_code')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_code is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'product_name')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_name is required');
			END IF;
    
			/* =============== Duplicate product code check for INSERT ================ */
		   IF EXISTS (
						SELECT 1
						FROM products
						WHERE product_code = getJval(pjReqObj,'product_code')
					) 	THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$',CONCAT('Product already exists with product_code: ', getJval(pjReqObj,'product_code')));
		   END IF;
       
	   	/* =============== Show errors in array in response Obj ================ */  
		   IF JSON_LENGTH(v_errors) > 0 THEN
		   SET psResObj = JSON_OBJECT(
									   'status', 		 'error',
									   'status_code', 	 '1',
									   'errors',	 	 v_errors
										);
		   LEAVE main_block;
		   END IF;


			/* =============== CREATE PRODUCT: Product Insertation started ================ */
            
                /* ============= JSON PREPARATION ================== */
    
		 SET v_products_json 	= getTemplate('products');
		 SET v_products_json 	= fillTemplate(pjReqObj, v_products_json);
			
		 SET v_row_metadata		= getTemplate('row_metadata');
		 SET v_row_metadata 	= JSON_SET( v_row_metadata,
											'$.created_by', 	'SYSTEM',
											'$.created_at', 	 DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
										  );

		 INSERT INTO products
				SET	tradable_assets_rec_id		= getJval(pjReqObj,	 'tradable_assets_rec_id'),
					asset_code					= getJval(pjReqObj,	  'asset_code'),
					product_code				= getJval(pjReqObj,	  'product_code'),
					product_type				= getJval(pjReqObj,	  'product_type'),
					product_name				= getJval(pjReqObj,	  'product_name'),
					products_json				= v_products_json,
					row_metadata				= v_row_metadata;
					
				SET v_product_rec_id 			= LAST_INSERT_ID();

				-- Sync generated ID back into JSON
				SET v_products_json 			= JSON_SET( v_products_json,
															'$.product_rec_id', v_product_rec_id
														  );

				UPDATE products
				SET    products_json 	= v_products_json
				WHERE  product_rec_id 	= v_product_rec_id;
    
    

    /* =============== UPDATE PRODUCT: Product UPDATION started ================ */

    WHEN 'UPDATE' THEN

      	/* =============== Product Insert VALIDATIONS: UPDATE must target existing record ================ */

		SET v_product_rec_id = getJval(pjReqObj,'product_rec_id');
      
		IF v_product_rec_id IS NOT NULL
		AND NOT EXISTS (
						SELECT 1
						FROM products
						WHERE product_rec_id = v_product_rec_id
					 )  THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid product_rec_id: record does not exist');

		END IF;
        
    /* =============== Duplicate check with other rows except the updated row ================ */  
    
        IF EXISTS (
					SELECT 1
					FROM products
					WHERE product_code = getJval(pjReqObj,'product_code')
					AND product_rec_id <> v_product_rec_id
					) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$',CONCAT('Product already exists with product_code: ', getJval(pjReqObj,'product_code')));
		END IF;	
    
	/* =============== Show errors in array in response Obj ================ */  
		IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
									   'status', 		 'error',
									   'status_code', 	 '1',
									   'errors',	 	 v_errors
										);
		LEAVE main_block;
		END IF;
        
     /* =============== Update started ================ */    


        SET v_products_json 	= getProduct(v_product_rec_id);

		SET v_products_json 	= fillTemplate(pjReqObj, v_products_json);

		SELECT 	row_metadata
		INTO 	v_row_metadata
		FROM 	products
		WHERE 	product_rec_id = v_product_rec_id;

        SET v_row_metadata = JSON_SET(
										v_row_metadata,
										'$.updated_by', 	'SYSTEM',
										'$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
									);
		

        
        UPDATE products
        SET tradable_assets_rec_id		= getJval(v_products_json, 'tradable_assets_rec_id'),
			asset_code					= getJval(v_products_json, 'asset_code'), 			
            product_code				= getJval(v_products_json, 'product_code'),			
            product_type				= getJval(v_products_json, 'product_type'),			
            product_name				= getJval(v_products_json, 'product_name'),			
            products_json				= v_products_json,
			row_metadata				= v_row_metadata
		WHERE product_rec_id			= v_product_rec_id;
        
		IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: no rows affected';
        END IF;
    END CASE;

    SET psResObj = JSON_OBJECT(
								'status', 		 'success',
								'status_code',   '0',
								'message',        IF(isFalsy(getJval(pjReqObj,'product_rec_id')),
												   'Product saved successfully',
												   'Product updated successfully'
													)
							);
    
    
     END main_block;
     
     -- inert general code here like LOG
	-- call log proc
END $$

DELIMITER ;

