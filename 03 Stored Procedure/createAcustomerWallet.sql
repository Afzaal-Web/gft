-- ==================================================================================================
-- Procedure: 			createAcustomerWallet
-- Purpose:   			create a wallet from tradable_assets table and insert activity walled ledger
-- ===================================================================================================


DROP PROCEDURE IF EXISTS createAcustomerWallet;

DELIMITER $$

CREATE PROCEDURE createAcustomerWallet (
										IN p_customer_rec_id         INT,
										IN p_tradable_assets_rec_id  INT
									   )
BEGIN
    DECLARE v_customer_json     JSON;
    DECLARE v_asset_json        JSON;
    DECLARE v_wallet            JSON;
    DECLARE v_wallet_path       VARCHAR(100);
    DECLARE v_wallet_id         VARCHAR(100);

    /* ================= VALIDATE + LOAD CUSTOMER ================= */
    SELECT 	customer_json 
    INTO   	v_customer_json
    FROM   	customer
    WHERE  	customer_rec_id = p_customer_rec_id;

    IF v_customer_json IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer not found';
    END IF;

    /* ================= VALIDATE + LOAD ASSET ================= */
	SELECT 	tradable_assets_json
    INTO   	v_asset_json
    FROM   	tradable_assets
    WHERE  	tradable_assets_rec_id = p_tradable_assets_rec_id;
    

	IF v_asset_json IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tradable asset not found or unavailable';
    END IF;

    /* ============== CHECK WALLET EXISTS =============== */
    SET v_wallet_path = JSON_SEARCH(
                            v_customer_json,
                            'one',
                            JSON_UNQUOTE(JSON_EXTRACT(v_asset_json, '$.asset_code')),
                            NULL,
                            '$.customer_wallets[*].asset_code'
                        );

    IF v_wallet_path IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer wallet already exists for this asset';
    END IF;

    /* =============== GENERATE WALLET ID ============== */
    CALL getSequence(
					   'CUSTOMER.WALLET_ID',
					   'WID-',
						1122,
						'createCustomerWallet',
						@wallet_id
					);
    SET v_wallet_id = @wallet_id;

    /* =============== BUILD WALLET JSON ============= */
    SET v_wallet = fillTemplate(
								 v_asset_json,
								 getTemplate('customer_wallets')
								);

    SET v_wallet = JSON_SET( v_wallet,
							'$.wallet_id', 					v_wallet_id,
							'$.wallet_status', 				'OPEN',
							'$.wallet_balance', 			0,
							'$.balance_unit',  				'UNIT',
							'$.balance_last_updated_at', 	NOW()
						 );

    /* ================ APPEND WALLET ============ */
    SET v_customer_json = JSON_ARRAY_APPEND( v_customer_json,
											 '$.customer_wallets',
											  v_wallet
										   );

    /* =============== UPDATE CUSTOMER ============ */
    UPDATE customer
    SET customer_json 	= v_customer_json
    WHERE customer_rec_id = p_customer_rec_id;
    
	/* ================= Wallet_activity ============= */
	CALL wallet_activity(
						  p_customer_rec_id,     -- customer_rec_id
						  v_wallet_id,           -- wallet_id
						  'CREATE',              -- activity type
						  0,                     -- amount
						  'Wallet created'       -- reason
					    );

END $$

DELIMITER ;
