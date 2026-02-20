-- ==================================================================================================
-- Procedure:   metalToCashConverter
-- Purpose:     Convert metal to cash or cash to metal
-- ==================================================================================================

DROP PROCEDURE IF EXISTS metalToCashConverter;

DELIMITER $$

CREATE PROCEDURE metalToCashConverter (
										IN  pReqObj JSON,
										OUT pResObj JSON
									)
BEGIN

    DECLARE v_asset_code    VARCHAR(50);
    DECLARE v_weight        DECIMAL(24,10);
    DECLARE v_amount        DECIMAL(24,10);
    DECLARE v_unit          VARCHAR(10);

    DECLARE v_json          JSON;
    DECLARE v_spot          DECIMAL(24,10);

    main_block: BEGIN

        -- Extract values from JSON
        SET v_asset_code 	= getJval(pReqObj, 'P_METAL_CODE');
        SET v_unit       	= getJval(pReqObj, 'P_UNIT');

        -- Extract either weight or amount
        SET v_weight     = CAST(getJval(pReqObj, 'P_WEIGHT') AS DECIMAL(24,10));
        SET v_amount     = CAST(getJval(pReqObj, 'P_AMOUNT') AS DECIMAL(24,10));

        -- Validate metal code
        IF v_asset_code IS NULL THEN
            SET pResObj = JSON_OBJECT(
										'status',	'error',
										'message',	'Invalid metal selection'
									);
            LEAVE main_block;
        END IF;

        -- Must provide either weight or amount, not both null
        IF (v_weight IS NULL OR v_weight <= 0) AND (v_amount IS NULL OR v_amount <= 0) THEN
            SET pResObj = JSON_OBJECT(
										'status',	'error',
										'message',	'Provide either weight or amount'
									);
            LEAVE main_block;
        END IF;

        -- Convert weight to grams if provided
        IF v_weight IS NOT NULL THEN
            SET v_weight = CASE v_unit
                WHEN 'kg' THEN v_weight * 1000
                WHEN 'oz' THEN v_weight * 28.349523125
                WHEN 'g'  THEN v_weight
                ELSE NULL
            END;

            IF v_weight IS NULL OR v_weight <= 0 THEN
                SET pResObj = JSON_OBJECT(
											'status',	'error',
											'message',	'Invalid or unsupported unit'
										);
                LEAVE main_block;
            END IF;
        END IF;

        -- Get latest rate JSON
        SELECT  asset_rate_history_json
        INTO 	v_json
        FROM 	asset_rate_history
        WHERE	asset_code = v_asset_code
        ORDER BY id DESC
        LIMIT 1;

        IF v_json IS NULL THEN
            SET pResObj = JSON_OBJECT(
									'status','error',
									'message','Rate not found'
								);
            LEAVE main_block;
        END IF;

        -- Extract spot price
        SET v_spot = CAST(getJval(v_json,'spot_rate') AS DECIMAL(24,10));

        IF v_spot IS NULL OR v_spot <= 0 THEN
            SET pResObj = JSON_OBJECT(
										'status','error',
										'message','Invalid spot rate'
									);
            LEAVE main_block;
        END IF;

        -- Calculation
        IF v_weight IS NOT NULL THEN
            -- Weight to cash
            SET v_amount = v_weight * v_spot;
        ELSE
            -- Amount to weight
            SET v_weight = v_amount / v_spot;
        END IF;

        -- Response
        SET pResObj = JSON_OBJECT(
									'status',			'success',
									'metal', 			 v_asset_code,
									'unit',				'g',
									'weight_grams', 	ROUND(v_weight,6),
									'amount', 			ROUND(v_amount,6),
									'spot_rate', 		v_spot,
									'message', 			CONCAT( 'You can buy ',
																 ROUND(v_weight,6), ' g of ',
																 v_asset_code,
																 ' for USD ', FORMAT(ROUND(v_amount,2),0)													)
																);

    END main_block;

END $$

DELIMITER ;
