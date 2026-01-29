-- ==================================================================================================
-- Procedure: 			populateCustomerWallets
-- Purpose:   			populate tradable_assets_json from tradable_assets table into the customer_wallets 
-- 						array in customer_json column of customer table.
-- ===================================================================================================


DROP PROCEDURE IF EXISTS populateCustomerWallets;

DELIMITER $$

CREATE PROCEDURE populateCustomerWallets(
										 IN p_customer_rec_id INT
										)
BEGIN
    DECLARE done 			  INT DEFAULT FALSE;
    DECLARE v_asset_json 	  JSON;
    DECLARE v_wallet_exists   INT;
	DECLARE v_wallet 		  JSON;
    DECLARE wallet_seq 		  VARCHAR(100);
    DECLARE v_customer_json  JSON;

    -- Cursor for all tradable assets available to customers
    DECLARE asset_cursor CURSOR FOR
        SELECT tradable_assets_json
        FROM tradable_assets
        WHERE available_to_customers = TRUE AND tradable_assets_rec_id > 0;

    -- Handler to end the loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT customer_json
    INTO v_customer_json
    FROM customer
    WHERE customer_rec_id = p_customer_rec_id
    FOR UPDATE;

    -- Open cursor
    OPEN asset_cursor;

    read_loop: LOOP
        FETCH asset_cursor INTO v_asset_json;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if wallet already exists for this asset
        SET v_wallet_exists = JSON_LENGTH(
										  JSON_SEARCH( v_customer_json,
													   'one',
														JSON_UNQUOTE(JSON_EXTRACT(v_asset_json, '$.asset_code')),
														NULL,
														'$.customer_wallets[*].asset_code'
														)
										);

        IF v_wallet_exists IS NULL THEN
            -- Generate wallet id
            CALL getSequence('CUSTOMER.WALLET_ID', 'WID-', 1122, 'populateCustomerWallets', @wallet_seq);

            -- Create wallet JSON from template
            SET v_wallet = fillTemplate(v_asset_json, getTemplate('customer_wallets'));

            SET v_wallet = JSON_SET( v_wallet,
									'$.wallet_id', @wallet_seq,
									'$.wallet_status', 'OPEN',
									'$.wallet_balance', 0,
									'$.balance_unit', 'UNIT',
									'$.balance_last_updated_at', NOW()
								);

            -- Append wallet to customer JSON
            SET v_customer_json = JSON_ARRAY_APPEND( v_customer_json,
													'$.customer_wallets',
													CAST(v_wallet AS JSON)
												  );

        END IF;
		
        -- call wallet activity
        
    END LOOP read_loop;

    CLOSE asset_cursor;

    -- Update customer JSON
    UPDATE customer
    SET customer_json = v_customer_json
    WHERE customer_rec_id = p_customer_rec_id;

END $$

DELIMITER ;
