DROP PROCEDURE IF EXISTS createRedeemOrder;

DELIMITER $$
CREATE PROCEDURE createRedeemOrder(
                                    IN  pjReqObj    JSON,
                                    OUT psResObj    JSON
                                )
BEGIN

    /* ===================== Variables ===================== */
    DECLARE v_customer_rec_id           INT;
    DECLARE v_account_number            VARCHAR(50);
    DECLARE v_order_rec_id              INT;
    DECLARE v_order_number              VARCHAR(50);
    DECLARE v_receipt_number            VARCHAR(50);
    DECLARE v_order_date                DATETIME;
    DECLARE v_order_status              VARCHAR(20);
    DECLARE v_next_action_required      VARCHAR(20);
    DECLARE v_order_cat                 VARCHAR(10);
    DECLARE v_order_type                VARCHAR(20);
    DECLARE v_metal                     VARCHAR(50);
    DECLARE v_asset_code                VARCHAR(10);
    DECLARE v_product_type              VARCHAR(20);
    DECLARE v_cr_weight                 DECIMAL(18,6);

    DECLARE v_tradable_assets_rec_id    INT;
    DECLARE v_rate_json                 JSON;
    DECLARE v_spot_rate                 DECIMAL(18,6);

    DECLARE v_customer_json             JSON;
    DECLARE v_order_json                JSON;
    DECLARE v_row_metadata              JSON;

    /*  buy_items variables (mirrors createBuyOrder PRODUCT structure exactly)  */
    DECLARE v_inventory_json            JSON;
    DECLARE v_item_code                 VARCHAR(50);
    DECLARE v_item_name                 VARCHAR(100);
    DECLARE v_item_type                 VARCHAR(50);
    DECLARE v_item_weight               DECIMAL(18,6);
    DECLARE v_item_quantity             INT;
    DECLARE v_bought_price              DECIMAL(18,2);
    DECLARE v_buy_items_input           JSON;
    DECLARE v_buy_items_output          JSON;
    DECLARE v_single_item               JSON;
    DECLARE v_loop_idx                  INT DEFAULT 0;
    DECLARE v_items_count               INT DEFAULT 0;

    /* Order Summary Variables */
    DECLARE v_total_redeem_items        INT DEFAULT 0;
    DECLARE v_total_redeem_weight       DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_buy_amount          DECIMAL(20,6) DEFAULT 0;    -- spot reference value (spot_rate * weight)
    DECLARE v_making_charges            DECIMAL(20,6) DEFAULT 0;
    DECLARE v_premium_charged           DECIMAL(20,6) DEFAULT 0;
    DECLARE v_transaction_fee           DECIMAL(20,6) DEFAULT 0;
    DECLARE v_processing_charges        DECIMAL(20,6) DEFAULT 0;
    DECLARE v_taxes                     DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_discounts           DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_charges_amount      DECIMAL(20,6) DEFAULT 0;    -- cash wallet debit amount

    /* Weight cross-check: (item_weight * item_quantity) must equal customer_request.weight */
    DECLARE v_calc_total_weight         DECIMAL(20,6) DEFAULT 0;

    /* Transaction / wallet variables */
    DECLARE v_txn_num_metal_debit       VARCHAR(50);
    DECLARE v_txn_num_cash_debit        VARCHAR(50);
    DECLARE v_transactions_output       JSON;

    DECLARE v_metal_wallet_id           VARCHAR(100);
    DECLARE v_metal_balance_before      DECIMAL(20,6);
    DECLARE v_metal_balance_after       DECIMAL(20,6);
    DECLARE v_metal_txn_amount          DECIMAL(20,6);

    DECLARE v_cash_wallet_id            VARCHAR(100);
    DECLARE v_cash_balance_before       DECIMAL(20,6);
    DECLARE v_cash_balance_after        DECIMAL(20,6);
    DECLARE v_cash_txn_amount           DECIMAL(20,6);

    DECLARE v_wallets_arr               JSON;
    DECLARE v_wallet_loop_idx           INT DEFAULT 0;
    DECLARE v_wallet_count              INT DEFAULT 0;
    DECLARE v_wallet_item               JSON;
    DECLARE v_wallet_asset_code         VARCHAR(20);
    DECLARE v_wallet_type               VARCHAR(20);

    DECLARE v_errors                    JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg                   VARCHAR(500);

    /* ===================== Error Handler ===================== */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        ROLLBACK;
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '1',
                                    'message',      'Insertion failed',
                                    'system_error', v_err_msg
                                );
    END;

main_block: BEGIN

    /* ===================== Step 1: Extract Request Values ===================== */
    SET v_order_type        = 'Redeem';
    SET v_product_type      = 'PRODUCT';                -- Redeem is always PRODUCT, no SLICE, no order_sub_type
    SET v_account_number    = getJval(pjReqObj, 'account_number');
    SET v_asset_code        = getJval(pjReqObj, 'asset_code');
    SET v_metal             = getJval(pjReqObj, 'metal');
    SET v_cr_weight         = getJval(pjReqObj, 'customer_request.weight');

    /* ===================== Step 2: Common Validations ===================== */
    IF isFalsy(v_account_number) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
    END IF;

    IF isFalsy(v_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'asset_code is required');
    END IF;

    IF isFalsy(v_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'metal is required');
    END IF;

    IF isFalsy(v_cr_weight) OR v_cr_weight <= 0 THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required and must be greater than 0');
    END IF;

    IF JSON_LENGTH(v_errors) > 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '2',
                                    'message',      'Validation failed',
                                    'errors',       v_errors
                                );
        LEAVE main_block;
    END IF;

    /* ===================== Step 3: Fetch Customer Record ===================== */
    SELECT  customer_rec_id
    INTO    v_customer_rec_id
    FROM    customer
    WHERE   account_num = v_account_number
    LIMIT 1;

    IF v_customer_rec_id IS NULL THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '3',
                                    'message',      'Customer not found'
                                );
        LEAVE main_block;
    END IF;

    CALL getCustomer(JSON_OBJECT('P_CUSTOMER_REC_ID', v_customer_rec_id), v_customer_json);

    IF getJval(v_customer_json, 'status') != 'success' THEN
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '3',
                                    'message',          'Customer not found',
                                    'customer_rec_id',  v_customer_rec_id
                                );
        LEAVE main_block;
    END IF;

    SET v_customer_json = JSON_EXTRACT(v_customer_json, '$.customer_data');

    /* ===================== Step 4: Fetch Latest Rate ===================== */
    SELECT  tradable_assets_rec_id,     tradable_assets_json
    INTO    v_tradable_assets_rec_id,   v_rate_json
    FROM    tradable_assets
    WHERE   asset_code = v_asset_code
    ORDER BY tradable_assets_rec_id DESC
    LIMIT 1;

    IF isFalsy(v_rate_json) THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '4',
                                    'message',      'Rate not found for asset_code',
                                    'asset_code',   v_asset_code
                                );
        LEAVE main_block;
    END IF;

    SET v_spot_rate = getJval(v_rate_json, 'spot_rate.current_rate');

    /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
    CALL getSequence('ORDERS.ORDER_NUM',    NULL,    3000, 'createRedeemOrder', v_order_number);
    CALL getSequence('ORDERS.RECEIPT_NUM', 'RECP-',  3000, 'createRedeemOrder', v_receipt_number);

    /* ===================== Step 6: Set Common Order Header Values ===================== */
    SET v_order_date            = NOW();
    SET v_order_status          = 'Pending';
    SET v_next_action_required  = 'approved';
    SET v_order_cat             = 'DO';

    /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
    SET v_order_json            = getTemplate('orders');
    SET v_row_metadata          = getTemplate('row_metadata');

    SET v_row_metadata = JSON_SET( v_row_metadata,
                                   '$.status',     v_order_status,
                                   '$.created_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
                                   '$.created_by', CONCAT(
                                                            getJval(v_customer_json, 'first_name'),
                                                            ' ',
                                                            getJval(v_customer_json, 'last_name'),
                                                            ' Customer Self-Service'
                                                        )
                                 );

    /* ===================== Step 8: Populate Customer & Rate Info in order json ===================== */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_info.customer_rec_id',          v_customer_rec_id,
                                '$.customer_info.customer_name',            CONCAT(getJval(v_customer_json, 'first_name'), ' ', getJval(v_customer_json, 'last_name')),
                                '$.customer_info.customer_account_number',  getJval(v_customer_json, 'main_account_number'),
                                '$.customer_info.customer_phone',           getJval(v_customer_json, 'phone'),
                                '$.customer_info.whatsapp',                 getJval(v_customer_json, 'whatsapp'),
                                '$.customer_info.customer_email',           getJval(v_customer_json, 'email'),
                                '$.customer_info.customer_address',         JSON_EXTRACT(v_customer_json, '$.residential_address'),
                                '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_ip_address'),
                                '$.customer_info.latitude',                 getJval(pjReqObj, 'latitude'),
                                '$.customer_info.longitude',                getJval(pjReqObj, 'longitude'),
                                '$.customer_info.notes',                    getJval(pjReqObj, 'notes'),

                                '$.rate_info.rate_rec_id',                  v_tradable_assets_rec_id,
                                '$.rate_info.spot_rate',                    getJval(v_rate_json, 'spot_rate.current_rate'),
                                '$.rate_info.currency_unit',                getJval(v_rate_json, 'spot_rate.currency'),
                                '$.rate_info.rate_source',                  getJval(v_rate_json, 'spot_rate.url'),
                                '$.rate_info.foreign_exchange_rate',        getJval(v_rate_json, 'spot_rate.foreign_exchange_rate'),
                                '$.rate_info.foreign_exchange_source',      getJval(v_rate_json, 'spot_rate.foreign_exchange_source'),

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
                                '$.metal',                                  v_metal
                            );

    /* ===================== Step 9: Validate & Process buy_items ===================== */

    /*
        The customer types their weight (e.g. 12g), sees available physical products,
        selects them and submits. The frontend sends the selected products as 'redeem_items'.
        Internally we read from 'redeem_items' but store in order_json as 'buy_items'
        to stay consistent with the orders template used across all order types.
    */
    SET v_buy_items_input = getJval(pjReqObj, 'redeem_items');

    IF isFalsy(v_buy_items_input) OR JSON_LENGTH(v_buy_items_input) = 0 THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'redeem_items array is required and must not be empty');
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '2',
                                    'message',      'Validation failed',
                                    'errors',       v_errors
                                );
        LEAVE main_block;
    END IF;

    SET v_items_count           = JSON_LENGTH(v_buy_items_input);
    SET v_loop_idx              = 0;
    SET v_buy_items_output      = JSON_ARRAY();
    SET v_calc_total_weight     = 0;

    WHILE v_loop_idx < v_items_count DO

        SET v_single_item       = JSON_EXTRACT(v_buy_items_input, CONCAT('$[', v_loop_idx, ']'));
        SET v_item_code         = getJval(v_single_item, 'item_code');
        SET v_item_weight       = getJval(v_single_item, 'item_weight');
        SET v_item_quantity     = getJval(v_single_item, 'item_quantity');

        /* Per-item field validation */
        IF isFalsy(v_item_code) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                CONCAT('redeem_items[', v_loop_idx, '].item_code is required'));
        END IF;

        IF isFalsy(v_item_weight) OR v_item_weight <= 0 THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                CONCAT('redeem_items[', v_loop_idx, '].item_weight is required and must be greater than 0'));
        END IF;

        IF isFalsy(v_item_quantity) OR v_item_quantity <= 0 THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                CONCAT('redeem_items[', v_loop_idx, '].item_quantity is required and must be greater than 0'));
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '2',
                                        'message',      'Validation failed on redeem_items',
                                        'errors',       v_errors
                                    );
            LEAVE main_block;
        END IF;

        /* Lookup item_name + item_type from inventory */
        SET v_inventory_json = NULL;

        SELECT  inventory_json
        INTO    v_inventory_json
        FROM    inventory
        WHERE   item_code = v_item_code
        LIMIT   1;

        IF isFalsy(v_inventory_json) THEN
            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '6',
                                        'message',      CONCAT('Inventory item not found for item_code: ', v_item_code),
                                        'item_code',    v_item_code,
                                        'item_index',   v_loop_idx
                                    );
            LEAVE main_block;
        END IF;

        SET v_item_name    = getJval(v_inventory_json, 'item_name');
        SET v_item_type    = getJval(v_inventory_json, 'item_type');

        /* bought_price = spot_rate * item_weight * item_quantity  (identical to createBuyOrder PRODUCT) */
        SET v_bought_price = v_spot_rate * v_item_weight * v_item_quantity;

        /* Accumulate weight - will be cross-checked against customer_request.weight after loop */
        SET v_calc_total_weight = v_calc_total_weight + (v_item_weight * v_item_quantity);

        /* Append item to buy_items array */
        SET v_buy_items_output = JSON_ARRAY_APPEND(
                                                    v_buy_items_output,
                                                    '$',
                                                    JSON_OBJECT(
                                                                'item_code',        v_item_code,
                                                                'item_name',        v_item_name,
                                                                'item_type',        v_item_type,
                                                                'item_quantity',    v_item_quantity,
                                                                'item_weight',      v_item_weight,
                                                                'bought_price',     v_bought_price
                                                            )
                                                );

        SET v_loop_idx = v_loop_idx + 1;

    END WHILE;

    /* ----
       Critical cross-check: the weight the customer typed at step 1
       must exactly equal the total weight of products they selected.
       Uses epsilon comparison to guard against floating-point drift.
    ---- */
    IF ABS(v_cr_weight - v_calc_total_weight) > 0.000001 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',               'error',
                                    'status_code',          '2',
                                    'message',              'customer_request.weight does not match total weight of selected redeem items',
                                    'requested_weight',     v_cr_weight,
                                    'calculated_weight',    v_calc_total_weight
                                );
        LEAVE main_block;
    END IF;

    /* Stored as 'buy_items' in order_json (consistent with orders template) */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.buy_items',                              v_buy_items_output,
                                '$.customer_request.weight',                v_cr_weight,
                                '$.customer_request.date_of_redemption',    DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                            );

    /* ===================== Step 9.5: Calculate Order Summary ===================== */

    SET v_items_count = JSON_LENGTH(v_buy_items_output);
    SET v_loop_idx    = 0;

    WHILE v_loop_idx < v_items_count DO

        SET v_single_item           = JSON_EXTRACT(v_buy_items_output, CONCAT('$[', v_loop_idx, ']'));

        SET v_total_redeem_items    = v_total_redeem_items  + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_quantity')) AS UNSIGNED);
        SET v_total_redeem_weight   = v_total_redeem_weight + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_weight'))   AS DECIMAL(20,6))
                                                          * CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_quantity')) AS DECIMAL(20,6));
        SET v_total_buy_amount      = v_total_buy_amount    + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.bought_price'))  AS DECIMAL(20,6));

        SET v_loop_idx              = v_loop_idx + 1;

    END WHILE;

    /* --- Charges (deducted from Cash wallet only; no cash credit on redeem) --- */
    SET v_transaction_fee       = 100.00;
    SET v_processing_charges    = 50.00;
    SET v_making_charges        = v_total_buy_amount    * 0.02;    -- 2% of spot reference value
    SET v_premium_charged       = v_total_redeem_weight * 50;      -- 50 PKR per gram
    SET v_taxes                 = v_total_buy_amount    * 0.05;    -- 5% GST on spot reference value
    SET v_total_discounts       = COALESCE(getJval(pjReqObj, 'discount_amount'), 0);

    SET v_total_charges_amount  = v_making_charges
                                  + v_premium_charged
                                  + v_transaction_fee
                                  + v_processing_charges
                                  + v_taxes
                                  - v_total_discounts;

    IF v_total_charges_amount < 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '10',
                                    'message',      'Net charges amount cannot be negative'
                                );
        LEAVE main_block;
    END IF;

    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_request.total_qty_to_buy',      v_total_redeem_items,
                                '$.order_summary.total_redeem_items',       v_total_redeem_items,
                                '$.order_summary.total_redeem_weight',      v_total_redeem_weight,
                                '$.order_summary.total_buy_amount',         v_total_buy_amount,         -- spot_rate * weight (reference, not a wallet movement)
                                '$.order_summary.making_charges',           v_making_charges,
                                '$.order_summary.premium_charged',          v_premium_charged,
                                '$.order_summary.transaction_fee',          v_transaction_fee,
                                '$.order_summary.processing_charges',       v_processing_charges,
                                '$.order_summary.taxes',                    v_taxes,
                                '$.order_summary.taxes_description',        'GST @ 5%',
                                '$.order_summary.total_discounts',          v_total_discounts,
                                '$.order_summary.total_charges_amount',     v_total_charges_amount      -- actual cash wallet debit
                            );

    /* ===================== Step 11: Wallets - Metal DEBIT + Cash DEBIT (charges only) ===================== */

    /* 11.1: Read customer_wallets array */
    SET v_wallets_arr       = getJval(v_customer_json, 'customer_wallets');

    IF v_wallets_arr IS NULL OR JSON_LENGTH(v_wallets_arr) = 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '11',
                                    'message',      'Customer wallets not found'
                                );
        LEAVE main_block;
    END IF;

    SET v_wallet_count      = JSON_LENGTH(v_wallets_arr);
    SET v_metal_wallet_id   = NULL;
    SET v_cash_wallet_id    = NULL;
    SET v_wallet_loop_idx   = 0;

    WHILE v_wallet_loop_idx < v_wallet_count DO

        SET v_wallet_item                = JSON_EXTRACT(v_wallets_arr, CONCAT('$[', v_wallet_loop_idx, ']'));
        SET v_wallet_asset_code          = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.asset_code'));
        SET v_wallet_type                = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_type'));

        IF v_wallet_asset_code = v_asset_code AND v_wallet_type = 'METAL' THEN
            SET v_metal_wallet_id        = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_id'));
            SET v_metal_balance_before   = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_balance')) AS DECIMAL(20,6)), 0);
        END IF;

        IF v_wallet_type = 'CASH' THEN
            SET v_cash_wallet_id        = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_id'));
            SET v_cash_balance_before   = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_balance')) AS DECIMAL(20,6)), 0);
        END IF;

        SET v_wallet_loop_idx = v_wallet_loop_idx + 1;

    END WHILE;

    /* 11.2: Guard - both wallets must exist */
    IF isFalsy(v_metal_wallet_id) THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '7',
                                    'message',      'Metal wallet not found for asset_code',
                                    'asset_code',   v_asset_code
                                );
        LEAVE main_block;
    END IF;

    IF isFalsy(v_cash_wallet_id) THEN
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '8',
                                    'message',          'Cash wallet not found for customer',
                                    'customer_rec_id',  v_customer_rec_id
                                );
        LEAVE main_block;
    END IF;

    /* 11.3: Transaction amounts */
    SET v_metal_txn_amount = v_cr_weight;               -- metal DEBIT = weight customer entered 
    SET v_cash_txn_amount  = v_total_charges_amount;    -- cash  DEBIT = charges only

    /* 11.4: Balances after */
    SET v_metal_balance_after = v_metal_balance_before - v_metal_txn_amount;
    SET v_cash_balance_after  = v_cash_balance_before  - v_cash_txn_amount;

    /* 11.4a: Guard - insufficient metal balance */
    IF v_metal_balance_after < 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '9',
                                    'message',          'Insufficient metal balance',
                                    'metal_balance',    v_metal_balance_before,
                                    'required_weight',  v_metal_txn_amount
                                );
        LEAVE main_block;
    END IF;

    /* 11.4b: Guard - insufficient cash balance for charges */
    IF v_cash_balance_after < 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '12',
                                    'message',          'Insufficient cash balance to cover redemption charges',
                                    'cash_balance',     v_cash_balance_before,
                                    'required_amount',  v_cash_txn_amount
                                );
        LEAVE main_block;
    END IF;

    /* 11.5: Generate transaction numbers */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createRedeemOrder', v_txn_num_metal_debit);
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createRedeemOrder', v_txn_num_cash_debit);

    /* 11.6: Build transactions array */
    SET v_transactions_output = JSON_ARRAY(

                                        /* TXN-A : Metal DEBIT - customer gives up gold weight */
                                        JSON_OBJECT(
                                                    'transaction_num',      v_txn_num_metal_debit,
                                                    'transaction_type',     'Debit',
                                                    'wallet_type',          'Metal',
                                                    'asset_code',           v_asset_code,
                                                    'wallet_id',            v_metal_wallet_id,
                                                    'balance_before',       v_metal_balance_before,
                                                    'transaction_amount',   v_metal_txn_amount,
                                                    'balance_after',        v_metal_balance_after
                                                ),

                                        /* TXN-B : Cash DEBIT - charges only */
                                        JSON_OBJECT(
                                                    'transaction_num',      v_txn_num_cash_debit,
                                                    'transaction_type',     'Debit',
                                                    'wallet_type',          'Cash',
                                                    'asset_code',           'CSH',
                                                    'wallet_id',            v_cash_wallet_id,
                                                    'balance_before',       v_cash_balance_before,
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
            metal                   = v_metal,
            order_json              = v_order_json,
            row_metadata            = v_row_metadata;

    SET v_order_rec_id = LAST_INSERT_ID();

    SET v_order_json = JSON_SET(v_order_json, '$.order_rec_id', v_order_rec_id);

    /* 11.7: Write transactions into order_json and persist */
    SET v_order_json = JSON_SET(v_order_json, '$.transactions', v_transactions_output);

    UPDATE  orders
    SET     order_json   = v_order_json
    WHERE   order_rec_id = v_order_rec_id;

    /* 11.8: Call wallet_activity - METAL DEBIT */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_metal_wallet_id,
                            'DEBIT',
                            v_metal_txn_amount,
                            CONCAT('Redeem order metal debited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_metal_debit
                        );

    /* 11.9: Call wallet_activity - CASH DEBIT (charges) */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_cash_wallet_id,
                            'DEBIT',
                            v_cash_txn_amount,
                            CONCAT('Redeem order charges debited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_cash_debit
                        );

    /* ===================== Step 12: Success Response ===================== */
    SET psResObj = JSON_OBJECT(
                                'status',           'success',
                                'status_code',      '0',
                                'message',          'Redeem order inserted successfully',
                                'order_rec_id',     v_order_rec_id,
                                'order_number',     v_order_number
                            );

    END main_block;

END$$
DELIMITER ;