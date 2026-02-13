-- ==================================================================================================
-- Procedure:   getRates
-- Purpose:     Retrieve asset rates for different denominations in USD and requested currency

-- Notes:
--   - Assumes the asset JSON contains a "foreign_exchange" object with a "foreign_exchange_rate".
--   - Currently, only one FX rate is supported per asset.
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getRates;

DELIMITER $$

CREATE PROCEDURE getRates(
							IN  pReqObj JSON,
							OUT pResObj JSON
						)
BEGIN
    DECLARE v_asset_rate_json 		JSON;
    DECLARE v_asset_code 			VARCHAR(20);
    DECLARE v_currency   			VARCHAR(10);
    DECLARE v_spot_rate				DECIMAL(18,4);
    DECLARE v_fx_rate    			DECIMAL(18,4);
    DECLARE v_usd_rate   			DECIMAL(18,4);
    DECLARE v_cur_rate   			DECIMAL(18,4);

    -- Denominations
    DECLARE v_denom_1g 				DECIMAL(18,4) 		DEFAULT 1;
    DECLARE v_denom_10g 			DECIMAL(18,4) 		DEFAULT 10;
    DECLARE v_denom_1t 				DECIMAL(18,4) 		DEFAULT 11.6638; 
    DECLARE v_denom_1oz 			DECIMAL(18,4) 		DEFAULT 31.1035; 

	main_block: BEGIN
    -- Extract request values
    SET v_asset_code 	= getJval(pReqObj, 'P_ASSET_CODE');
    SET v_currency   	= getJval(pReqObj, 'P_CURRENCY');

    -- Get asset JSON from DB
    SELECT asset_rate_history_json
    INTO v_asset_rate_json
    FROM asset_rate_history
    WHERE asset_code = v_asset_code
    LIMIT 1;

    IF v_asset_rate_json IS NULL THEN
        SET pResObj = JSON_OBJECT(
            'code', 1,
            'status', 'error',
            'message', CONCAT('Asset rate not found for ', v_asset_code)
        );
        LEAVE main_block;
    END IF;

    -- Extract USD spot rate
    SET v_spot_rate = getJval(v_asset_rate_json, 'spot_rate');

    -- Extract FX rate for requested currency (default 1 if USD)
    IF v_currency IS NULL OR v_currency = '' OR v_currency = 'USD' THEN
        SET v_fx_rate = 1;
        
    ELSE
		SET v_fx_rate = getJval(v_asset_rate_json, CONCAT('$.foreign_exchange.', v_currency));

		IF v_fx_rate IS NULL THEN
							SET pResObj = JSON_OBJECT(
								'code', 2,
								'status', 'error',
								'message', CONCAT('FX rate not found for currency ', v_currency)
							);
	LEAVE main_block;
END IF;

        
    END IF;

    -- Build JSON array of denominations
    SET pResObj = JSON_ARRAY(
							JSON_OBJECT(
										'denomination', '1g',
										'USD', ROUND(v_spot_rate * v_denom_1g, 2),
										v_currency, ROUND(v_spot_rate * v_fx_rate * v_denom_1g, 2)
									),
							JSON_OBJECT(
										'denomination', '10g',
										'USD', ROUND(v_spot_rate * v_denom_10g, 2),
										v_currency, ROUND(v_spot_rate * v_fx_rate * v_denom_10g, 2)
									),
							JSON_OBJECT(
										'denomination', '11.6638g (1 tola)',
										'USD', ROUND(v_spot_rate * v_denom_1t, 2),
										v_currency, ROUND(v_spot_rate * v_fx_rate * v_denom_1t, 2)
									),
							JSON_OBJECT(
									'denomination', '31.1035g (1 troy oz)',
									'USD', ROUND(v_spot_rate * v_denom_1oz, 2),
									v_currency, ROUND(v_spot_rate * v_fx_rate * v_denom_1oz, 2)
								)
						);
			END main_block;
END $$

DELIMITER ;


SET @req = CAST('{
  "P_ASSET_CODE": "SLV",
  "P_CURRENCY": "EUR"
}' AS JSON);

SET @res = '';
CALL getRates(@req, @res);
SELECT @res;