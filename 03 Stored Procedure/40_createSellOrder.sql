DROP PROCEDURE IF EXISTS createSellOrder;

DELIMITER $$
CREATE PROCEDURE createSellOrder(
                                    IN  pjReqObj    JSON,
                                    OUT pjRespObj    JSON
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
    DECLARE v_order_sub_type            VARCHAR(20);
    DECLARE v_metal                     VARCHAR(50);
    DECLARE v_asset_code                VARCHAR(10);
    DECLARE v_product_type              VARCHAR(20);
    DECLARE v_cr_payment_method         VARCHAR(50);
    DECLARE v_cr_rate                   DECIMAL(18,6);
    DECLARE v_cr_weight                 DECIMAL(18,6);
    DECLARE v_cr_amount                 DECIMAL(18,6);
    DECLARE v_cr_expiration_time        DATETIME;
    DECLARE v_is_partial_fill_allowed   VARCHAR(20);

    DECLARE v_tradable_assets_rec_id    INT;
    DECLARE v_rate_json                 JSON;
    DECLARE v_spot_rate                 DECIMAL(18,6);

    DECLARE v_customer_json             JSON;
    DECLARE v_order_json                JSON;
    DECLARE v_row_metadata              JSON;

    /* sell_items variables */
    DECLARE v_inventory_json            JSON;
    DECLARE v_item_code                 VARCHAR(50);
    DECLARE v_item_name                 VARCHAR(100);
    DECLARE v_item_type                 VARCHAR(50);
    DECLARE v_item_quantity             INT;
    DECLARE v_sold_price                DECIMAL(20,6);
    DECLARE v_sell_items_output         JSON;

    /* Order Summary Variables */
    DECLARE v_total_sell_items          INT DEFAULT 0;
    DECLARE v_total_sell_amount         DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_sell_weight         DECIMAL(20,6) DEFAULT 0;
    DECLARE v_making_charges            DECIMAL(20,6) DEFAULT 0;
    DECLARE v_premium_charged           DECIMAL(20,6) DEFAULT 0;
    DECLARE v_transaction_fee           DECIMAL(20,6) DEFAULT 0;
    DECLARE v_processing_charges        DECIMAL(20,6) DEFAULT 0;
    DECLARE v_taxes                     DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_discounts           DECIMAL(20,6) DEFAULT 0;

    /* Transaction / wallet variables */
    DECLARE v_txn_num_debit             VARCHAR(50);
    DECLARE v_txn_num_credit            VARCHAR(50);
    DECLARE v_transactions_output       JSON;

    DECLARE v_metal_wallet_id           VARCHAR(100);
    DECLARE v_metal_balance_before      DECIMAL(20,6);
    DECLARE v_metal_balance_after       DECIMAL(20,6);
    DECLARE v_metal_txn_amount          DECIMAL(20,6);

    DECLARE v_cash_wallet_id            VARCHAR(100);
    DECLARE v_cash_balance_before       DECIMAL(20,6);
    DECLARE v_cash_balance_after        DECIMAL(20,6);
    DECLARE v_cash_txn_amount           DECIMAL(20,6);

    DECLARE v_total_order_amount        DECIMAL(20,6) DEFAULT 0;
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
        
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Insertion failed ', v_err_msg));
    END;

main_block: BEGIN

    /* ===================== Step 1: Extract Request Values ===================== */
    SET v_order_type        = 'Sell';
    SET v_product_type      = 'SLICE';          -- Sell only supports SLICE
    SET v_account_number    = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');
    SET v_asset_code        = getJval(pjReqObj, 'jData.P_ASSET_CODE');
    SET v_order_sub_type    = getJval(pjReqObj, 'jData.P_ORDER_SUB_TYPE');
    SET v_order_cat         = getJval(pjReqObj, 'jData.P_ORDER_CAT');
    SET v_metal             = getJval(pjReqObj, 'jData.P_METAL');
    SET v_cr_payment_method = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_PAYMENT_METHOD');

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

    IF isFalsy(v_cr_payment_method) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.payment_method is required');
    END IF;

    IF isFalsy(v_order_sub_type) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_sub_type is required (Market or Limit)');
    END IF;

    IF JSON_LENGTH(v_errors) > 0 THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Validation failed: ', JSON_UNQUOTE(v_errors)));
        LEAVE main_block;
    END IF;

    /* ===================== Step 3: Fetch Customer Record ===================== */
    SELECT  customer_rec_id
    INTO    v_customer_rec_id
    FROM    customer
    WHERE   account_num = v_account_number
    LIMIT 1;

    IF v_customer_rec_id IS NULL THEN
        SET pjRespObj = JSON_OBJECT('jHeader', JSON_OBJECT('respCode', NULL, 'message', NULL));
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer not found');
        LEAVE main_block;
    END IF;

    CALL getCustomer(JSON_OBJECT('P_CUSTOMER_REC_ID', v_customer_rec_id), v_customer_json);

    IF getJval(v_customer_json, 'status') != 'success' THEN
        SET pjRespObj = JSON_OBJECT('jHeader', JSON_OBJECT('respCode', NULL, 'message', NULL));
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Customer not found for customer_rec_id: ', v_customer_rec_id));
        LEAVE main_block;
    END IF;



    SET v_customer_json = getJval(v_customer_json, 'customer_data');

    /* ===================== Step 4: Fetch Latest Rate for Asset ===================== */
    SELECT    tradable_assets_rec_id,     tradable_assets_json
    INTO      v_tradable_assets_rec_id,   v_rate_json
    FROM      tradable_assets
    WHERE     asset_code = v_asset_code
    ORDER BY  tradable_assets_rec_id DESC
    LIMIT 1;

    IF isFalsy(v_rate_json) THEN
       
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Rate not found for asset_code: ', v_asset_code));
        LEAVE main_block;
    END IF;

    SET v_spot_rate = getJval(v_rate_json, 'spot_rate.current_rate');

    /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
    CALL getSequence('ORDERS.ORDER_NUM',    NULL,   3000, 'createSellOrder', v_order_number);
    CALL getSequence('ORDERS.RECEIPT_NUM', 'RECP-', 3000, 'createSellOrder', v_receipt_number);

    /* ===================== Step 6: Set Common Order Header Values ===================== */
    SET v_order_date            = NOW();
    SET v_order_status          = 'Pending';
    SET v_next_action_required  = 'approval';

    /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
    SET v_order_json    = getTemplate('orders');
    SET v_row_metadata  = getTemplate('row_metadata');

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

    /* ===================== Step 8: Populate Customer & Rate Info ===================== */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_info.customer_rec_id',          v_customer_rec_id,
                                '$.customer_info.customer_name',            CONCAT(getJval(v_customer_json,     'first_name'), ' ', getJval(v_customer_json,    'last_name')),
                                '$.customer_info.customer_account_number',  getJval(v_customer_json,            'main_account_number'),
                                '$.customer_info.customer_phone',           getJval(v_customer_json,            'phone'),
                                '$.customer_info.whatsapp',                 getJval(v_customer_json,            'whatsapp'),
                                '$.customer_info.customer_email',           getJval(v_customer_json,            'email'),
                                '$.customer_info.customer_address',         CAST(getJval(v_customer_json,       'residential_address') AS JSON),
                                '$.customer_info.customer_ip_address',      getJval(pjReqObj,                   'jData.P_CUSTOMER_IP_ADDRESS'),
                                '$.customer_info.latitude',                 getJval(pjReqObj,                   'jData.P_LATITUDE'),
                                '$.customer_info.longitude',                getJval(pjReqObj,                   'jData.P_LONGITUDE'),
                                '$.customer_info.notes',                    getJval(pjReqObj,                   'jData.P_NOTES'),

                                '$.rate_info.rate_rec_id',                  v_tradable_assets_rec_id,
                                '$.rate_info.spot_rate',                    getJval(v_rate_json,                'spot_rate.current_rate'),
                                '$.rate_info.currency_unit',                getJval(v_rate_json,                'spot_rate.currency'),
                                '$.rate_info.rate_source',                  getJval(v_rate_json,                'spot_rate.url'),
                                '$.rate_info.foreign_exchange_rate',        getJval(v_rate_json,                'spot_rate.foreign_exchange_rate'),
                                '$.rate_info.foreign_exchange_source',      getJval(v_rate_json,                'spot_rate.foreign_exchange_source'),

                                '$.customer_rec_id',                        v_customer_rec_id,
                                '$.account_number',                         v_account_number,
                                '$.order_number',                           v_order_number,
                                '$.receipt_number',                         v_receipt_number,
                                '$.order_date',                             DATE_FORMAT(v_order_date, '%Y-%m-%dT%H:%i:%sZ'),
                                '$.order_status',                           v_order_status,
                                '$.next_action_required',                   v_next_action_required,
                                '$.order_type',                             v_order_type,
                                '$.limit_or_market',                        v_order_sub_type,
                                '$.metal',                                  v_metal
                            );

    /* ===================== Step 9: SLICE - Validate item_code + item_weight ===================== */

    SET v_item_code     = getJval(pjReqObj, 'jData.P_ITEM_CODE');
    SET v_cr_weight     = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_WEIGHT');

    IF isFalsy(v_item_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'item_code is required for SLICE order');
    END IF;

    IF isFalsy(v_cr_weight) OR v_cr_weight <= 0 THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for SLICE order');
    END IF;

    IF JSON_LENGTH(v_errors) > 0 THEN
       
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Validation failed: ', JSON_UNQUOTE(v_errors)));
        LEAVE main_block;
    END IF;

    /* ===================== Step 9.1: Lookup inventory ===================== */

    SELECT  inventory_json
    INTO    v_inventory_json
    FROM    inventory
    WHERE   item_code = v_item_code
    LIMIT   1;

    IF v_inventory_json IS NULL THEN
        SET pjRespObj = JSON_OBJECT('jHeader', JSON_OBJECT('respCode', NULL, 'message', NULL));
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Inventory item not found for item_code: ', v_item_code));
        LEAVE main_block;
    END IF;

    SET v_item_name = getJval(v_inventory_json, 'item_name');
    SET v_item_type = getJval(v_inventory_json, 'item_type');

    /* ===================== Step 9.2: Branch by order_sub_type ===================== */
    IF v_order_sub_type = 'Market' THEN

        SET v_sold_price = v_spot_rate * v_cr_weight;

        SET v_order_cat  = 'DO';

        SET v_sell_items_output = JSON_ARRAY(
                                            JSON_OBJECT(
                                                        'item_code',        v_item_code,
                                                        'item_name',        v_item_name,
                                                        'item_type',        v_item_type,
                                                        'item_quantity',    1,
                                                        'item_weight',      v_cr_weight,
                                                        'sold_price',       v_sold_price
                                                    )
                                            );

        SET v_order_json = JSON_SET(v_order_json,
                                    '$.order_cat',                              v_order_cat,
                                    '$.sell_items',                             v_sell_items_output,
                                    '$.customer_request.weight',                v_cr_weight,
                                    '$.customer_request.payment_method',        v_cr_payment_method,
                                    '$.customer_request.date_of_purchase',      DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                );

    ELSEIF v_order_sub_type = 'Limit' THEN

        SET v_cr_rate                  = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_RATE');
        SET v_cr_amount                 = v_cr_rate * v_cr_weight;
        SET v_cr_expiration_time       = STR_TO_DATE(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_EXPIRATION_TIME'),'%Y-%m-%d %H:%i:%s');
        SET v_is_partial_fill_allowed  = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_IS_PARTIAL_FILL_ALLOWED');

        IF isFalsy(v_cr_rate) OR v_cr_rate <= 0 THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.rate is required for Limit Sell order');
        END IF;

        IF v_cr_expiration_time IS NULL THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.expiration_time is required for Limit Sell order');
        END IF;

        /* Default order_cat to GTC if not provided */
        IF isFalsy(v_order_cat) THEN
            SET v_order_cat = 'GTC';
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
           
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Validation failed: ', JSON_UNQUOTE(v_errors)));
            LEAVE main_block;
        END IF;

        
        SET v_sold_price    = v_cr_rate * v_cr_weight;

        SET v_sell_items_output = JSON_ARRAY(
                                            JSON_OBJECT(
                                                        'item_code',        v_item_code,
                                                        'item_name',        v_item_name,
                                                        'item_type',        v_item_type,
                                                        'item_quantity',    1,
                                                        'item_weight',      v_cr_weight,
                                                        'sold_price',       v_sold_price
                                                    )
                                            );

        SET v_order_json = JSON_SET(v_order_json,
                                    '$.order_cat',                                  v_order_cat,
                                    '$.sell_items',                                 v_sell_items_output,
                                    '$.customer_request.rate',                      v_cr_rate,
                                    '$.customer_request.weight',                    v_cr_weight,
                                    '$.customer_request.amount',                    v_cr_amount,
                                    '$.customer_request.expiration_time',           v_cr_expiration_time,
                                    '$.customer_request.is_partial_fill_allowed',   v_is_partial_fill_allowed,
                                    '$.customer_request.payment_method',            v_cr_payment_method,
                                    '$.customer_request.date_of_purchase',          DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                );

    ELSE

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Unknown order_sub_type for Sell. Must be Market or Limit');
        LEAVE main_block;
    END IF;
    
       /* ===================== Step 9.5: Calculate Order Summary ===================== */
    SET v_total_sell_items  = CAST(getJval(v_sell_items_output, '$[0].item_quantity') AS UNSIGNED);
    SET v_total_sell_weight = CAST(getJval(v_sell_items_output, '$[0].item_weight') AS DECIMAL(20,6)) * CAST(getJval(v_sell_items_output, '$[0].item_quantity') AS DECIMAL(20,6));
    SET v_total_sell_amount = CAST(getJval(v_sell_items_output, '$[0].sold_price') AS DECIMAL(20,6));

    /* --- Charges & fees (deducted from proceeds on a Sell) --- */
    SET v_transaction_fee    = 100.00;
    SET v_processing_charges = 50.00;
    SET v_making_charges     = v_total_sell_amount * 0.02;
    SET v_premium_charged    = v_total_sell_weight * 50;
    SET v_taxes              = v_total_sell_amount * 0.05;
    SET v_total_discounts    = COALESCE(getJval(pjReqObj, 'jData.P_DISCOUNT_AMOUNT'), 0);

    /* Net cash customer receives = gross proceeds minus charges */
    SET v_total_order_amount =  v_total_sell_amount
                                - v_making_charges
                                - v_premium_charged
                                - v_transaction_fee
                                - v_processing_charges
                                - v_taxes
                                + v_total_discounts;
    /* Now validate */
    IF v_total_order_amount < 0 THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Net sell amount cannot be negative');
        LEAVE main_block;
    END IF;                                

    SET v_order_json        = JSON_SET(v_order_json,
                                        '$.customer_request.total_qty_to_sell', v_total_sell_items,
                                        '$.order_summary.total_sell_items',     v_total_sell_items,
                                        '$.order_summary.total_sell_amount',    v_total_sell_amount,
                                        '$.order_summary.total_sell_weight',    v_total_sell_weight,
                                        '$.order_summary.items_total_amount',   v_total_sell_amount,
                                        '$.order_summary.making_charges',       v_making_charges,
                                        '$.order_summary.premium_charged',      v_premium_charged,
                                        '$.order_summary.transaction_fee',      v_transaction_fee,
                                        '$.order_summary.processing_charges',   v_processing_charges,
                                        '$.order_summary.taxes',                v_taxes,
                                        '$.order_summary.taxes_description',    'GST @ 5%',
                                        '$.order_summary.total_discounts',      v_total_discounts,
                                        '$.order_summary.total_order_amount',   v_total_order_amount
                                    );


    /* ===================== Step 11: Build Transactions, Update Wallets ===================== */

    /* 11.1: Read customer_wallets array */
    SET v_wallets_arr   = getJval(v_customer_json, 'customer_wallets');

    IF v_wallets_arr IS NULL OR JSON_LENGTH(v_wallets_arr) = 0 THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer wallets not found');
        LEAVE main_block;
    END IF;

    SET v_wallet_count  = JSON_LENGTH(v_wallets_arr);

    SET v_metal_wallet_id = NULL;
    SET v_cash_wallet_id  = NULL;
    SET v_wallet_loop_idx = 0;

    WHILE v_wallet_loop_idx < v_wallet_count DO

        SET v_wallet_item       = JSON_EXTRACT(v_wallets_arr, CONCAT('$[', v_wallet_loop_idx, ']'));
        SET v_wallet_asset_code = getJval(v_wallet_item, 'asset_code');
        SET v_wallet_type       = getJval(v_wallet_item, 'wallet_type');

        IF v_wallet_asset_code  = v_asset_code AND v_wallet_type = 'METAL' THEN

            SET v_metal_wallet_id       = getJval(v_wallet_item, 'wallet_id');
            SET v_metal_balance_before  = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);

        END IF;

        IF v_wallet_type = 'CASH' THEN

            SET v_cash_wallet_id      = getJval(v_wallet_item,    'wallet_id');
            SET v_cash_balance_before = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);

        END IF;

        SET v_wallet_loop_idx = v_wallet_loop_idx + 1;

    END WHILE;

    /* 11.2: Guard - both wallets must exist */
    IF isFalsy(v_metal_wallet_id) THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Metal wallet not found for asset_code: ', v_asset_code));
        LEAVE main_block;
    END IF;

    IF isFalsy(v_cash_wallet_id) THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Cash wallet not found for account_number: ', v_account_number));
        LEAVE main_block;
    END IF;

    /* 11.3: Transaction amounts */

    /* Metal DEBIT = total weight being sold */
    SET v_metal_txn_amount = v_total_sell_weight;

    /* Cash CREDIT = net proceeds after charges */
    SET v_cash_txn_amount = v_total_order_amount;

    /* 11.4: Balances after */
    SET v_metal_balance_after = v_metal_balance_before - v_metal_txn_amount;
    SET v_cash_balance_after  = v_cash_balance_before  + v_cash_txn_amount;

    /* 11.4b: Guard - insufficient metal balance */
    IF v_metal_balance_after < 0 THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.respCode', '1');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Insufficient metal balance: ', v_metal_balance_before, ' available, ', v_metal_txn_amount, ' required'));

        LEAVE main_block;
    END IF;

    /* 11.5: Generate transaction numbers */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createSellOrder', v_txn_num_debit);
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createSellOrder', v_txn_num_credit);

    /* 11.6: Build transactions array */
    SET v_transactions_output = JSON_ARRAY(

                                            /* TXN-A : Metal DEBIT */
                                            JSON_OBJECT(
                                                        'transaction_num',      v_txn_num_debit,
                                                        'transaction_type',     'Debit',
                                                        'wallet_type',          'Metal',
                                                        'asset_code',           v_asset_code,
                                                        'wallet_id',            v_metal_wallet_id,
                                                        'balance_before',       v_metal_balance_before,
                                                        'transaction_amount',   v_metal_txn_amount,
                                                        'balance_after',        v_metal_balance_after
                                                    ),

                                            /* TXN-B : Cash CREDIT */
                                            JSON_OBJECT(
                                                        'transaction_num',      v_txn_num_credit,
                                                        'transaction_type',     'Credit',
                                                        'wallet_type',          'Cash',
                                                        'asset_code',           'CSH',
                                                        'wallet_id',            v_cash_wallet_id,
                                                        'balance_before',       v_cash_balance_before,
                                                        'transaction_amount',   v_cash_txn_amount,
                                                        'balance_after',        v_cash_balance_after
                                                    )
    );

    /* ===================== Step 11-A: INSERT into orders table ===================== */
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
            limit_or_market         = v_order_sub_type,
            metal                   = v_metal,
            order_json              = v_order_json,
            row_metadata            = v_row_metadata;

    SET     v_order_rec_id          = LAST_INSERT_ID();

    SET     v_order_json            = JSON_SET(v_order_json, '$.order_rec_id', v_order_rec_id);

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
                            CONCAT('Sell order debited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_debit
                        );

    /* 11.9: Call wallet_activity - CASH CREDIT */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_cash_wallet_id,
                            'CREDIT',
                            v_cash_txn_amount,
                            CONCAT('Sell order credited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num_credit
                        );


    /* ===================== Step 12: Success Response ===================== */
    
    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',       CONCAT('Sell order created successfully for order number: ', v_order_number));

    END main_block;

END$$
DELIMITER ;
