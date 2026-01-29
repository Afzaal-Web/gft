-- ==================================================================================================
-- Procedure: 			wallet_activity
-- Purpose:   			Record the activity in customer_wallets array then add this in wallet_ledger table
-- ===================================================================================================



DROP PROCEDURE IF EXISTS wallet_activity;

DELIMITER $$

CREATE PROCEDURE wallet_activity (
									IN p_customer_rec_id  		INT,
									IN p_wallet_id 				VARCHAR(100),
									IN p_activity_type 			ENUM('CREATE','CREDIT','DEBIT'),
									IN p_amount 				DECIMAL(20,6),
									IN p_reason 				VARCHAR(255)
								)
BEGIN
    /* =============== VARIABLE DECLARATIONS ============= */
    DECLARE v_wallet_index 			INT;
    DECLARE v_wallet_path 			VARCHAR(100);

    DECLARE v_wallet_balance 		DECIMAL(20,6);
    DECLARE v_new_balance 			DECIMAL(20,6);

    DECLARE v_asset_code 			VARCHAR(10);
    DECLARE v_asset_name 			VARCHAR(50);
    DECLARE v_wallet_title 			VARCHAR(100);
    DECLARE v_account_number 		VARCHAR(100);

    DECLARE v_wallet_ledger_json 	JSON;
    DECLARE v_row_metadata			JSON;



    START TRANSACTION;

    /* ================ LOCK CUSTOMER ROW =========== */
	SELECT 	account_num
	INTO 	v_account_number
	FROM 	customer
	WHERE 	customer_rec_id = p_customer_rec_id
	FOR UPDATE;

    /* ================ FIND WALLET PATH Example: $.customer_wallets[2].wallet_id============== */
    SELECT JSON_UNQUOTE(
						JSON_SEARCH( customer_json,
										'one',
										p_wallet_id,
										NULL,
										'$.customer_wallets[*].wallet_id'
									)
					  )
						INTO v_wallet_path
						FROM customer
						WHERE customer_rec_id = p_customer_rec_id;

    IF v_wallet_path IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Wallet not found for customer';
    END IF;

    /* ==============================
       EXTRACT WALLET INDEX
    ============================== */
    SET v_wallet_index = CAST(REGEXP_REPLACE(v_wallet_path, '[^0-9]', '') AS UNSIGNED);


    /* ==============================
       READ WALLET DATA
    ============================== */
    SELECT
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].wallet_balance'))),
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].asset_code'))),
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].asset_name')))
    INTO
			v_wallet_balance,
			v_asset_code,
			v_asset_name
    FROM 	customer
    WHERE 	customer_rec_id = p_customer_rec_id
    FOR UPDATE;

    SET v_wallet_balance 	= COALESCE(v_wallet_balance, 0);
    SET v_wallet_title 		= CONCAT(v_asset_name, ' Wallet');

    /* ==============================
       BALANCE CALCULATION
    ============================== */
    IF p_activity_type = 'CREDIT' THEN
        SET v_new_balance = v_wallet_balance + p_amount;
        
    ELSEIF p_activity_type = 'DEBIT' THEN
    
        IF v_wallet_balance < p_amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient wallet balance';
            
        END IF;
        
        SET v_new_balance = v_wallet_balance - p_amount;
    ELSE
    
        SET v_new_balance = v_wallet_balance;
    END IF;

		/* ==============================
			LOAD LEDGER TEMPLATE
		============================== */
	SET v_wallet_ledger_json = getTemplate('wallet_ledger');
    
	SET v_wallet_ledger_json = JSON_SET( v_wallet_ledger_json,
										'$.customer_rec_id',		 					p_customer_rec_id,
										'$.account_number', 							v_account_number,
										'$.wallet_id', 									p_wallet_id,
										'$.wallet_title', 								v_wallet_title,
										'$.asset_code',									v_asset_code,
										'$.asset_name', 								v_asset_name,
										'$.transaction_type', 							p_activity_type,

										'$.ledger_transaction.transaction_at', 			NOW(),
										'$.ledger_transaction.transaction_reason', 		p_reason,
										'$.ledger_transaction.balance_before', 			v_wallet_balance,
										'$.ledger_transaction.debit_amount',			IF(p_activity_type='DEBIT', p_amount, 0),
										'$.ledger_transaction.credit_amount',			IF(p_activity_type='CREDIT', p_amount, 0),
										'$.ledger_transaction.balance_after', 			v_new_balance,
										'$.initiated_by_info.initiated_by', 			'SYSTEM',
										'$.initiated_by_info.initiated_by_name', 		'System Auto'
										);

    /* ==============================
       INSERT LEDGER
    ============================== */
    SET v_row_metadata			= getTemplate('row_metadata');
    
    INSERT INTO wallet_ledger
    SET customer_rec_id 		= p_customer_rec_id,
		account_number			= v_account_number,
        wallet_id				= p_wallet_id,
        wallet_title			= v_wallet_title,
        asset_code				= v_asset_code,
        asset_name				= v_asset_name,
        transaction_type		= CASE p_activity_type WHEN 'CREATE' THEN 'WALLET_CREATE' ELSE p_activity_type END,
        wallet_ledger_json		= v_wallet_ledger_json,
        row_metadata			= JSON_SET(v_row_metadata,
											'$.created_at', NOW(),
											'$.created_by', 'SYSTEM'
											);
                                            
    /* ==============================
       UPDATE WALLET BALANCE
    ============================== */
    UPDATE customer
    SET customer_json = JSON_SET(customer_json,
								  CONCAT('$.customer_wallets[', v_wallet_index, '].wallet_balance'), v_new_balance,
								  CONCAT('$.customer_wallets[', v_wallet_index, '].balance_last_updated_at'), NOW()
								)
    WHERE customer_rec_id = p_customer_rec_id;

    COMMIT;

END $$

DELIMITER ;
