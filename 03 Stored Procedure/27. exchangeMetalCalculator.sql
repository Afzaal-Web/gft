-- ==================================================================================================
-- Procedure:   exchangeMetalCalculator
-- Purpose:     Calculator for exchange metals
-- ==================================================================================================

DROP PROCEDURE IF EXISTS exchangeMetalCalculator;

DELIMITER $$

CREATE PROCEDURE exchangeMetalCalculator (
											IN  pReqObj JSON,
											OUT pResObj JSON
										)
BEGIN
	
    DECLARE v_from_asset_code		VARCHAR(50);
    DECLARE v_to_asset_code			VARCHAR(50);
    DECLARE v_quantity          	DECIMAL(18,6);
    DECLARE v_unit              	VARCHAR(10);
    
	DECLARE v_from_json             JSON;
    DECLARE v_to_json               JSON;
    
	DECLARE v_from_spot           	DECIMAL(18,6);
    DECLARE v_to_spot             	DECIMAL(18,6);
    
    DECLARE v_value			      	DECIMAL(18,6);
    DECLARE v_result_quantity   	DECIMAL(18,6);
    
    
    main_block: BEGIN
    
	-- Extract values from JSON
	SET v_from_asset_code 		=  getJval(pReqObj,        'P_METAL_TO_EXCHANGE');
	SET v_to_asset_code   		=  getJval(pReqObj, 	   'P_METAL_TO_EXCHANGE_ACQUIRE'); 
    SET v_quantity   	  		=  CAST(getJval(pReqObj,   'P_QUANTITY') AS DECIMAL(18,6));
    SET v_unit            		=  getJval(pReqObj,        'P_UNIT');
    
     -- Validate asset codes
        IF v_from_asset_code IS NULL OR v_to_asset_code IS NULL THEN
            SET pResObj = JSON_OBJECT(
										'status','error',
										'message','Invalid metal selection'
									);
            LEAVE main_block;
        END IF;
        
	-- Prevent exchanging same metal
        IF v_from_asset_code = v_to_asset_code THEN
            SET pResObj = JSON_OBJECT(
										'status','error',
										'message','Both metals cannot be same'
									);
            LEAVE main_block;
        END IF;
    

	-- Convert all input to grams
			SET v_quantity = CASE v_unit
				WHEN 'kg' THEN v_quantity * 1000
				WHEN 'oz' THEN v_quantity * 28.349523125
				WHEN 'g'  THEN v_quantity
				ELSE NULL
			END;

    
    IF v_quantity IS NULL OR v_quantity <= 0 THEN
    SET pResObj = JSON_OBJECT(
								'status','error',
								'message','Invalid or unsupported unit/quantity'
							);
    LEAVE main_block;
	END IF;
    
    -- Get rates
    -- Get latest rate for From Metal
    SELECT 		asset_rate_history_json
    INTO 		v_from_json
    FROM 		asset_rate_history
    WHERE 		asset_code = v_from_asset_code
    ORDER BY 	id DESC
    LIMIT 1;
    
	-- Get latest rate for TO metal
    SELECT 		asset_rate_history_json
    INTO 		v_to_json
    FROM 		asset_rate_history
    WHERE 		asset_code = v_to_asset_code
    ORDER BY 	id DESC
    LIMIT 1;
    
      -- Validation
    IF v_from_json IS NULL OR v_to_json IS NULL THEN
        SET pResObj = JSON_OBJECT(
									'status','error',
									'message','Rate not found for selected metals'
								);
        LEAVE main_block;
    END IF;

    
    -- Extract spot price
    SET v_from_spot 	= CAST(getJval(v_from_json,	'spot_rate') AS DECIMAL(18,6));
	SET v_to_spot  		= CAST(getJval(v_to_json,	'spot_rate') AS DECIMAL(18,6));
    
    -- Prevent divide by zero
	IF v_to_spot IS NULL OR v_to_spot <= 0
    OR v_to_spot IS NULL OR v_to_spot <= 0 THEN
		SET pResObj = JSON_OBJECT(
									'status','error',
									'message','Invalid spot rate'
								);
        
		LEAVE main_block;
	END IF;
    
    -- Exchange calculation
    SET v_value 			= v_quantity * v_from_spot;
    SET v_result_quantity 	= v_value / v_to_spot;
    
    -- Response
    SET pResObj = JSON_OBJECT(
								'status', 					'success',
								'exchange_from', 			v_from_asset_code,
								'exchange_to', 				v_to_asset_code,
								'input_quantity_grams', 	v_quantity,
                                'from_spot_rate', 			v_from_spot,
								'to_spot_rate', 			v_to_spot,
								'result_quantity_grams', 	ROUND(v_result_quantity, 6),
								'message', CONCAT(
															'You can exchange ',
															v_quantity, ' g of ',
															v_from_asset_code,
															' with ',
															ROUND(v_result_quantity,6),
															' g of ',
															v_to_asset_code
												)
							);
    
    

    END main_block;

END $$

DELIMITER ;
