DROP PROCEDURE IF EXISTS createExchangeOrder;

DELIMITER $$
CREATE PROCEDURE createExchangeOrder(
                                        IN      pjReqObj     JSON,
                                        INOUT   pjRespObj    JSON
                                    )
BEGIN

    /* ===================== Variables ===================== */
    DECLARE v_customer_rec_id               INT;
    DECLARE v_account_number                VARCHAR(50);
    DECLARE v_order_rec_id                  INT;
    DECLARE v_order_number                  VARCHAR(50);
    DECLARE v_receipt_number                VARCHAR(50);
    DECLARE v_order_date                    DATETIME;
    DECLARE v_order_status                  VARCHAR(20);
    DECLARE v_next_action_required          VARCHAR(20);
    DECLARE v_order_cat                     VARCHAR(10);
    DECLARE v_order_type                    VARCHAR(20);

    /* From (Sell) side */
    DECLARE v_from_asset_code               VARCHAR(10);
    DECLARE v_from_metal                    VARCHAR(50);
    DECLARE v_from_item_code                VARCHAR(50);
    DECLARE v_from_item_name                VARCHAR(100);
    DECLARE v_from_item_type                VARCHAR(50);
    DECLARE v_from_weight                   DECIMAL(18,6);
    DECLARE v_from_spot_rate                DECIMAL(18,6);
    DECLARE v_sold_price                    DECIMAL(18,2);
    DECLARE v_from_tradable_assets_rec_id   INT;
    DECLARE v_from_rate_json                JSON;
    DECLARE v_from_inventory_json           JSON;
    DECLARE v_sell_items_output             JSON;

    /* To (Buy) side */
    DECLARE v_to_asset_code                 VARCHAR(10);
    DECLARE v_to_metal                      VARCHAR(50);
    DECLARE v_to_item_code                  VARCHAR(50);
    DECLARE v_to_item_name                  VARCHAR(100);
    DECLARE v_to_item_type                  VARCHAR(50);
    DECLARE v_to_weight                     DECIMAL(18,6);
    DECLARE v_to_spot_rate                  DECIMAL(18,6);
    DECLARE v_bought_price                  DECIMAL(18,2);
    DECLARE v_to_tradable_assets_rec_id     INT;
    DECLARE v_to_rate_json                  JSON;
    DECLARE v_to_inventory_json             JSON;
    DECLARE v_buy_items_output              JSON;

    /* Customer & order JSON */
    DECLARE v_customer_json                 JSON;
    DECLARE v_order_json                    JSON;
    DECLARE v_row_metadata                  JSON;

    /* Order Summary */
    DECLARE v_total_sell_items              INT DEFAULT 0;
    DECLARE v_total_sell_amount             DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_sell_weight             DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_buy_items               INT DEFAULT 0;
    DECLARE v_total_buy_amount              DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_buy_weight              DECIMAL(20,6) DEFAULT 0;
    DECLARE v_making_charges                DECIMAL(20,6) DEFAULT 0;
    DECLARE v_premium_charged               DECIMAL(20,6) DEFAULT 0;
    DECLARE v_transaction_fee               DECIMAL(20,6) DEFAULT 0;
    DECLARE v_processing_charges            DECIMAL(20,6) DEFAULT 0;
    DECLARE v_taxes                         DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_discounts               DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_order_amount            DECIMAL(20,6) DEFAULT 0;
    DECLARE v_items_total_amount            DECIMAL(20,6) DEFAULT 0;

    /* Wallet variables */
    DECLARE v_txn_num_debit                 VARCHAR(50);
    DECLARE v_txn_num_credit                VARCHAR(50);
    DECLARE v_txn_num_cash_debit            VARCHAR(50);
    DECLARE v_txn_num_cash_credit           VARCHAR(50);   /* Sell leg cash credit txn number  */
    DECLARE v_transactions_output           JSON;

    DECLARE v_from_wallet_id                VARCHAR(100);
    DECLARE v_from_balance_before           DECIMAL(20,6);
    DECLARE v_from_balance_after            DECIMAL(20,6);
    DECLARE v_from_txn_amount               DECIMAL(20,6);

    DECLARE v_to_wallet_id                  VARCHAR(100);
    DECLARE v_to_balance_before             DECIMAL(20,6);
    DECLARE v_to_balance_after              DECIMAL(20,6);
    DECLARE v_to_txn_amount                 DECIMAL(20,6);

    DECLARE v_cash_wallet_id                VARCHAR(100);
    DECLARE v_cash_balance_before           DECIMAL(20,6);
    DECLARE v_cash_balance_after            DECIMAL(20,6);
    DECLARE v_cash_txn_amount               DECIMAL(20,6);
    DECLARE v_cash_credit_txn_amount        DECIMAL(20,6);  /* NEW: Sell leg cash credit amount = v_sold_price     */
    DECLARE v_cash_after_sell_credit        DECIMAL(20,6);  /* NEW: Intermediate balance after sell credit leg     */

    DECLARE v_wallets_arr                   JSON;
    DECLARE v_wallet_loop_idx               INT DEFAULT 0;
    DECLARE v_wallet_count                  INT DEFAULT 0;
    DECLARE v_wallet_item                   JSON;
    DECLARE v_wallet_asset_code             VARCHAR(20);
    DECLARE v_wallet_type                   VARCHAR(20);

    DECLARE v_errors                        JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg                       VARCHAR(500);

    /* ===================== Error Handler ===================== */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        ROLLBACK;

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Insertion failed: ', v_err_msg));

    END;

main_block: BEGIN

    /* ===================== Step 1: Extract Request Values ===================== */
    SET v_order_type        = 'Exchange';
    SET v_account_number    = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');
    SET v_from_asset_code   = getJval(pjReqObj, 'jData.P_FROM_ASSET_CODE');
    SET v_to_asset_code     = getJval(pjReqObj, 'jData.P_TO_ASSET_CODE');
    SET v_from_metal        = getJval(pjReqObj, 'jData.P_FROM_METAL');
    SET v_to_metal          = getJval(pjReqObj, 'jData.P_TO_METAL');
    SET v_from_item_code    = getJval(pjReqObj, 'jData.P_FROM_ITEM_CODE');
    SET v_to_item_code      = getJval(pjReqObj, 'jData.P_TO_ITEM_CODE');
    SET v_from_weight       = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_FROM_WEIGHT');
    SET v_to_weight         = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_TO_WEIGHT');

    /* ===================== Step 2: Validations ===================== */
    IF isFalsy(v_account_number) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
    END IF;

    IF isFalsy(v_from_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'from_asset_code is required');
    END IF;

    IF isFalsy(v_to_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'to_asset_code is required');
    END IF;

    IF isFalsy(v_from_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'from_metal is required');
    END IF;

    IF isFalsy(v_to_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'to_metal is required');
    END IF;

    IF isFalsy(v_from_item_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'from_item_code is required');
    END IF;

    IF isFalsy(v_to_item_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'to_item_code is required');
    END IF;

    IF isFalsy(v_from_weight) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.from_weight is required');
    END IF;

    IF isFalsy(v_to_weight) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.to_weight is required');
    END IF;

    /* Guard: cannot exchange same asset into itself */
    IF v_from_asset_code = v_to_asset_code THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'from_asset_code and to_asset_code must be different');
    END IF;

    IF JSON_LENGTH(v_errors) > 0 THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   'Validations failed');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.errors',     v_errors);

        LEAVE main_block;
    END IF;

    /* ===================== Step 3: Fetch Customer Record ===================== */
    SELECT  customer_rec_id
    INTO    v_customer_rec_id
    FROM    customer
    WHERE   account_num = v_account_number
    LIMIT 1;

    IF isFalsy(v_customer_rec_id) THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   'Customer not found');

        LEAVE main_block;
    END IF;

    SET v_customer_json = getCustomer(v_customer_rec_id);

    IF isFalsy(v_customer_json) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Customer not found for account number: ', v_account_number));

        LEAVE main_block;
    END IF;

    /* ===================== Step 4: Fetch Rates for Both Assets ===================== */

    /* --- FROM asset rate --- */
    SELECT   tradable_assets_rec_id,         tradable_assets_json
    INTO     v_from_tradable_assets_rec_id,  v_from_rate_json
    FROM     tradable_assets
    WHERE    asset_code = v_from_asset_code
    ORDER BY tradable_assets_rec_id DESC
    LIMIT 1;

    IF isFalsy(v_from_rate_json) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Rate not found for from_asset_code: ', v_from_asset_code));

        LEAVE main_block;
    END IF;

    SET v_from_spot_rate = getJval(v_from_rate_json, 'spot_rate.current_rate');

    /* --- TO asset rate --- */
    SELECT   tradable_assets_rec_id,         tradable_assets_json
    INTO     v_to_tradable_assets_rec_id,    v_to_rate_json
    FROM     tradable_assets
    WHERE    asset_code = v_to_asset_code
    ORDER BY tradable_assets_rec_id DESC
    LIMIT 1;

    IF isFalsy(v_to_rate_json) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Rate not found for to_asset_code: ', v_to_asset_code));

        LEAVE main_block;
    END IF;

    SET v_to_spot_rate = getJval(v_to_rate_json, 'spot_rate.current_rate');

    /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
    CALL getSequence('ORDERS.ORDER_NUM',   NULL,    3000, 'createExchangeOrder', v_order_number);
    CALL getSequence('ORDERS.RECEIPT_NUM', 'RECP-', 3000, 'createExchangeOrder', v_receipt_number);

    /* ===================== Step 6: Set Common Order Header Values ===================== */
    SET v_order_date            = NOW();
    SET v_order_status          = 'Pending';
    SET v_next_action_required  = 'approval';
    SET v_order_cat             = 'DO';

    /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
    SET v_order_json            = getTemplate('orders');
    SET v_row_metadata          = getTemplate('row_metadata');

    SET v_row_metadata = JSON_SET(v_row_metadata,
                                    '$.status',     v_order_status,
                                    '$.created_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
                                    '$.created_by', CONCAT(
                                                            getJval(v_customer_json, 'first_name'),
                                                            ' ',
                                                            getJval(v_customer_json, 'last_name'),
                                                            ' Customer Self-Service'
                                                        )
                                );

    /* ===================== Step 8: Populate Customer, Rate Info & Top-Level Fields ===================== */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_info.customer_rec_id',          v_customer_rec_id,
                                '$.customer_info.customer_name',            CONCAT(getJval(v_customer_json, 'first_name'), ' ', getJval(v_customer_json, 'last_name')),
                                '$.customer_info.customer_account_number',  getJval(v_customer_json, 'main_account_number'),
                                '$.customer_info.customer_phone',           getJval(v_customer_json, 'phone'),
                                '$.customer_info.whatsapp',                 getJval(v_customer_json, 'whatsapp'),
                                '$.customer_info.customer_email',           getJval(v_customer_json, 'email'),
                                '$.customer_info.customer_address',         getJval(v_customer_json, 'residential_address'),
                                '$.customer_info.customer_ip_address',      getJval(pjReqObj,        'jData.P_CUSTOMER_IP_ADDRESS'),
                                '$.customer_info.latitude',                 getJval(pjReqObj,        'jData.P_LATITUDE'),
                                '$.customer_info.longitude',                getJval(pjReqObj,        'jData.P_LONGITUDE'),
                                '$.customer_info.notes',                    getJval(pjReqObj,        'jData.P_NOTES'),

                                /* Store both rate records - from and to */
                                '$.rate_info.from_rate_rec_id',             v_from_tradable_assets_rec_id,
                                '$.rate_info.from_spot_rate',               v_from_spot_rate,
                                '$.rate_info.from_currency_unit',           getJval(v_from_rate_json, 'spot_rate.currency'),
                                '$.rate_info.from_rate_source',             getJval(v_from_rate_json, 'spot_rate.url'),
                                '$.rate_info.from_foreign_exchange_rate',   getJval(v_from_rate_json, 'spot_rate.foreign_exchange_rate'),
                                '$.rate_info.from_foreign_exchange_source', getJval(v_from_rate_json, 'spot_rate.foreign_exchange_source'),

                                '$.rate_info.to_rate_rec_id',               v_to_tradable_assets_rec_id,
                                '$.rate_info.to_spot_rate',                 v_to_spot_rate,
                                '$.rate_info.to_currency_unit',             getJval(v_to_rate_json, 'spot_rate.currency'),
                                '$.rate_info.to_rate_source',               getJval(v_to_rate_json, 'spot_rate.url'),
                                '$.rate_info.to_foreign_exchange_rate',     getJval(v_to_rate_json, 'spot_rate.foreign_exchange_rate'),
                                '$.rate_info.to_foreign_exchange_source',   getJval(v_to_rate_json, 'spot_rate.foreign_exchange_source'),

                                '$.customer_rec_id',                        v_customer_rec_id,
                                '$.account_number',                         v_account_number,
                                '$.order_number',                           v_order_number,
                                '$.receipt_number',                         v_receipt_number,
                                '$.order_date',                             DATE_FORMAT(v_order_date, '%Y-%m-%dT%H:%i:%sZ'),
                                '$.order_status',                           v_order_status,
                                '$.next_action_required',                   v_next_action_required,
                                '$.order_type',                             v_order_type,
                                '$.order_cat',                              v_order_cat,
                                '$.limit_or_market',                        NULL,
                                '$.metal',                                  CONCAT(v_from_metal, ' to ', v_to_metal)
                            );

    /* ===================== Step 9: Lookup Inventory & Build sell_items / buy_items ===================== */

    /* --- FROM side: inventory lookup for sell_items --- */
    SELECT  inventory_json
    INTO    v_from_inventory_json
    FROM    inventory
    WHERE   item_code = v_from_item_code
    LIMIT 1;

    IF isFalsy(v_from_inventory_json) THEN
       
       SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
       SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Inventory item not found for from_item_code: ', v_from_item_code));
    
        LEAVE main_block;
    END IF;

    SET v_from_item_name    = getJval(v_from_inventory_json, 'item_name');
    SET v_from_item_type    = getJval(v_from_inventory_json, 'item_type');
    SET v_sold_price        = v_from_spot_rate * v_from_weight;

    SET v_sell_items_output = JSON_ARRAY(
                                            JSON_OBJECT(
                                                        'item_code',        v_from_item_code,
                                                        'item_name',        v_from_item_name,
                                                        'item_type',        v_from_item_type,
                                                        'item_quantity',    1,
                                                        'item_weight',      v_from_weight,
                                                        'sold_price',       v_sold_price
                                                    )
                                        );

    /* --- TO side: inventory lookup for buy_items --- */
    SELECT  inventory_json
    INTO    v_to_inventory_json
    FROM    inventory
    WHERE   item_code = v_to_item_code
    LIMIT 1;

    IF isFalsy(v_to_inventory_json) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Inventory item not found for to_item_code: ', v_to_item_code));

        LEAVE main_block;
    END IF;

    SET v_to_item_name  = getJval(v_to_inventory_json, 'item_name');
    SET v_to_item_type  = getJval(v_to_inventory_json, 'item_type');
    SET v_bought_price  = v_to_spot_rate * v_to_weight;

    SET v_buy_items_output = JSON_ARRAY(
                                            JSON_OBJECT(
                                                        'item_code',        v_to_item_code,
                                                        'item_name',        v_to_item_name,
                                                        'item_type',        v_to_item_type,
                                                        'item_quantity',    1,
                                                        'item_weight',      v_to_weight,
                                                        'bought_price',     v_bought_price
                                                    )
                                        );

    /* Merge both item arrays into order_json */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.sell_items',                             v_sell_items_output,
                                '$.buy_items',                              v_buy_items_output,
                                '$.customer_request.from_weight',           v_from_weight,
                                '$.customer_request.to_weight',             v_to_weight,
                                '$.customer_request.date_of_purchase',      DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                            );

    /* ===================== Step 9.5: Calculate Order Summary ===================== */

    /* Sell side totals (single item, quantity = 1) */
    SET v_total_sell_items  = 1;
    SET v_total_sell_weight = v_from_weight;
    SET v_total_sell_amount = v_sold_price;

    /* Buy side totals (single item, quantity = 1) */
    SET v_total_buy_items   = 1;
    SET v_total_buy_weight  = v_to_weight;
    SET v_total_buy_amount  = v_bought_price;

    /* items_total_amount: value of what is being received (to side) */
    SET v_items_total_amount = v_total_buy_amount;

    /* Charges - mirroring createBuyOrder structure */
    SET v_transaction_fee    = 100.00;
    SET v_processing_charges = 50.00;
    SET v_making_charges     = v_items_total_amount * 0.02;
    SET v_premium_charged    = v_total_buy_weight   * 50;
    SET v_taxes              = v_items_total_amount * 0.05;
    SET v_total_discounts    = COALESCE(getJval(pjReqObj, 'jData.P_DISCOUNT_AMOUNT'), 0);

    /* Total charges only (fees + taxes - discounts) */
    SET v_total_order_amount =   v_making_charges
                               + v_premium_charged
                               + v_transaction_fee
                               + v_processing_charges
                               + v_taxes
                               - v_total_discounts;

    IF v_total_order_amount < 0 THEN
        SET pjRespObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '10',
                                    'message',      'Net exchange amount cannot be negative'
                                );
        LEAVE main_block;
    END IF;

    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_request.total_qty_to_sell', v_total_sell_items,
                                '$.customer_request.total_qty_to_buy',  v_total_buy_items,
                                '$.order_summary.total_sell_items',     v_total_sell_items,
                                '$.order_summary.total_sell_amount',    v_total_sell_amount,
                                '$.order_summary.total_sell_weight',    v_total_sell_weight,
                                '$.order_summary.total_buy_items',      v_total_buy_items,
                                '$.order_summary.total_buy_amount',     v_total_buy_amount,
                                '$.order_summary.total_buy_weight',     v_total_buy_weight,
                                '$.order_summary.items_total_amount',   v_items_total_amount,
                                '$.order_summary.making_charges',       v_making_charges,
                                '$.order_summary.premium_charged',      v_premium_charged,
                                '$.order_summary.transaction_fee',      v_transaction_fee,
                                '$.order_summary.processing_charges',   v_processing_charges,
                                '$.order_summary.taxes',                v_taxes,
                                '$.order_summary.taxes_description',    'GST @ 5%',
                                '$.order_summary.total_discounts',      v_total_discounts,
                                '$.order_summary.total_order_amount',   v_total_order_amount
                            );

    /* ===================== Step 11: Wallet Processing ===================== */

    /* 11.1: Read customer_wallets array */
    SET v_wallets_arr = getJval(v_customer_json, 'customer_wallets');
     CALL debugLog('customer_wallets', v_wallets_arr);

    IF v_wallets_arr IS NULL OR JSON_LENGTH(v_wallets_arr) = 0 THEN
       
       SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
       SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   'Customer wallets not found');

        LEAVE main_block;
    END IF;

    SET v_wallet_count      = JSON_LENGTH(v_wallets_arr);
    SET v_from_wallet_id    = NULL;
    SET v_to_wallet_id      = NULL;
    SET v_wallet_loop_idx   = 0;

    WHILE v_wallet_loop_idx < v_wallet_count DO

        SET v_wallet_item       = JSON_EXTRACT(v_wallets_arr, CONCAT('$[', v_wallet_loop_idx, ']'));
        SET v_wallet_asset_code = getJval(v_wallet_item, 'asset_code');
        SET v_wallet_type       = getJval(v_wallet_item, 'wallet_type');

        /* Match FROM metal wallet */
        IF v_wallet_asset_code = v_from_asset_code AND v_wallet_type = 'METAL' THEN
            SET v_from_wallet_id        = getJval(v_wallet_item, 'wallet_id');
            SET v_from_balance_before   = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);
        END IF;

        /* Match TO metal wallet */
        IF v_wallet_asset_code = v_to_asset_code AND v_wallet_type = 'METAL' THEN
            SET v_to_wallet_id          = getJval(v_wallet_item, 'wallet_id');
            SET v_to_balance_before     = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);
        END IF;

        /* Match CASH wallet */
        IF v_wallet_type = 'CASH' THEN
            SET v_cash_wallet_id        = getJval(v_wallet_item, 'wallet_id');
            SET v_cash_balance_before   = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);
        END IF;

        SET v_wallet_loop_idx = v_wallet_loop_idx + 1;

    END WHILE;

    /* 11.2: Guard - both metal wallets and cash wallet must exist */
    IF isFalsy(v_from_wallet_id) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Metal wallet not found for from_asset_code: ', v_from_asset_code));

        LEAVE main_block;
    END IF;

    IF isFalsy(v_to_wallet_id) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Metal wallet not found for to_asset_code: ', v_to_asset_code));

        LEAVE main_block;
    END IF;

    IF isFalsy(v_cash_wallet_id) THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Cash wallet not found for customer: ', v_account_number));

        LEAVE main_block;
    END IF;

    /* 11.3: Transaction amounts
       ─────────────────────────────────────────────────────────────────
       TXN-A  FROM metal DEBIT   : weight leaving from_metal wallet
       TXN-B  Cash     CREDIT    : sell proceeds (sold_price) entering cash wallet
       TXN-C  TO metal CREDIT    : weight entering to_metal wallet
       TXN-D  Cash     DEBIT     : buy cost (bought_price) + charges leaving cash wallet
       ───────────────────────────────────────────────────────────────── */
    SET v_from_txn_amount        = v_from_weight;                          /* metal weight out            */
    SET v_to_txn_amount          = v_to_weight;                            /* metal weight in             */
    SET v_cash_credit_txn_amount = v_sold_price;                           /* cash in  (sell proceeds)    */
    SET v_cash_txn_amount        = v_bought_price + v_total_order_amount;  /* cash out (buy cost+charges) */

    /* 11.4: Compute all balances after
       Intermediate state after sell-credit is stored in v_cash_after_sell_credit
       so TXN-D can use it as its balance_before, giving a clean audit trail. */
    SET v_from_balance_after     = v_from_balance_before  - v_from_txn_amount;
    SET v_to_balance_after       = v_to_balance_before    + v_to_txn_amount;
    SET v_cash_after_sell_credit = v_cash_balance_before  + v_cash_credit_txn_amount;  /* after TXN-B */
    SET v_cash_balance_after     = v_cash_after_sell_credit - v_cash_txn_amount;        /* after TXN-D */

    /* 11.4b: Guard - insufficient from_metal balance */
    IF v_from_balance_after < 0 THEN
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Insufficient metal balance for exchange. balance: ', v_from_balance_before, ', required: ', v_from_txn_amount));

        LEAVE main_block;
    END IF;

    /* 11.4c: Guard - insufficient cash balance after netting sell credit against buy debit */
    IF v_cash_balance_after < 0 THEN
      
      SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '1');
      SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',   CONCAT('Insufficient cash balance to cover exchange. balance: ', v_cash_balance_before, ', sell credit: ', v_cash_credit_txn_amount, ', buy debit: ', v_cash_txn_amount));

      LEAVE main_block;
    END IF;

    /* 11.5: Generate transaction numbers - one per leg */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createExchangeOrder', v_txn_num_debit);        /* TXN-A */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createExchangeOrder', v_txn_num_cash_credit);  /* TXN-B */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createExchangeOrder', v_txn_num_credit);       /* TXN-C */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createExchangeOrder', v_txn_num_cash_debit);   /* TXN-D */

    /* 11.6: Build transactions array - four legs in execution order */
    SET v_transactions_output = JSON_ARRAY(

        /* TXN-A : FROM metal DEBIT (Sell leg - metal out) */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num_debit,
                    'transaction_type',     'Debit',
                    'wallet_type',          'Metal',
                    'asset_code',           v_from_asset_code,
                    'wallet_id',            v_from_wallet_id,
                    'balance_before',       v_from_balance_before,
                    'transaction_amount',   v_from_txn_amount,
                    'balance_after',        v_from_balance_after
                ),

        /* TXN-B : Cash CREDIT (Sell leg - proceeds in) */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num_cash_credit,
                    'transaction_type',     'Credit',
                    'wallet_type',          'Cash',
                    'asset_code',           'CSH',
                    'wallet_id',            v_cash_wallet_id,
                    'balance_before',       v_cash_balance_before,
                    'transaction_amount',   v_cash_credit_txn_amount,
                    'balance_after',        v_cash_after_sell_credit
                ),

        /* TXN-C : TO metal CREDIT (Buy leg - metal in) */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num_credit,
                    'transaction_type',     'Credit',
                    'wallet_type',          'Metal',
                    'asset_code',           v_to_asset_code,
                    'wallet_id',            v_to_wallet_id,
                    'balance_before',       v_to_balance_before,
                    'transaction_amount',   v_to_txn_amount,
                    'balance_after',        v_to_balance_after
                ),

        /* TXN-D : Cash DEBIT (Buy leg - bought_price + charges out) */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num_cash_debit,
                    'transaction_type',     'Debit',
                    'wallet_type',          'Cash',
                    'asset_code',           'CSH',
                    'wallet_id',            v_cash_wallet_id,
                    'balance_before',       v_cash_after_sell_credit,
                    'transaction_amount',   v_cash_txn_amount,
                    'balance_after',        v_cash_balance_after
                )
    );

    /* ===================== Step 10: INSERT into orders table ===================== */
    INSERT INTO orders
        SET customer_rec_id         = v_customer_rec_id,
            account_number          = v_account_number,
            order_number            = v_order_number,
            receipt_number          = v_receipt_number,
            order_date              = v_order_date,
            order_status            = v_order_status,
            next_action_required    = v_next_action_required,
            order_cat               = v_order_cat,
            order_type              = v_order_type,
            limit_or_market         = NULL,
            metal                   = CONCAT(v_from_metal, ' to ', v_to_metal),
            order_json              = v_order_json,
            row_metadata            = v_row_metadata;

    SET     v_order_rec_id          = LAST_INSERT_ID();

    SET v_order_json = JSON_SET(v_order_json, '$.order_rec_id', v_order_rec_id);

    /* 11.7: Write transactions into order_json and persist */
    SET v_order_json = JSON_SET(v_order_json, '$.transactions', v_transactions_output);

    UPDATE  orders
    SET     order_json   = v_order_json
    WHERE   order_rec_id = v_order_rec_id;

    /* 11.8: wallet_activity - TXN-A: FROM metal DEBIT (Sell leg) */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_from_wallet_id,
                            'DEBIT',
                            v_from_txn_amount,
                            CONCAT('Exchange sell leg metal debited (', v_from_asset_code, '): ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_debit
                        );

    /* 11.9: wallet_activity - TXN-B: Cash CREDIT (Sell leg proceeds) */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_cash_wallet_id,
                            'CREDIT',
                            v_cash_credit_txn_amount,
                            CONCAT('Exchange sell leg cash credited (', v_from_asset_code, '): ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_cash_credit
                        );

    /* 11.10: wallet_activity - TXN-C: TO metal CREDIT (Buy leg) */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_to_wallet_id,
                            'CREDIT',
                            v_to_txn_amount,
                            CONCAT('Exchange buy leg metal credited (', v_to_asset_code, '): ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_credit
                        );

    /* 11.11: wallet_activity - TXN-D: Cash DEBIT (Buy leg cost + charges) */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_cash_wallet_id,
                            'DEBIT',
                            v_cash_txn_amount,
                            CONCAT('Exchange buy leg cash debited (', v_to_asset_code, '): ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_cash_debit
                        );

    /* ===================== Step 12: Success Response ===================== */
    
    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',       CONCAT('Exchange order created successfully for order number: ', v_order_number));

END main_block;

END$$
DELIMITER ;