DROP PROCEDURE IF EXISTS insertOrder;

DELIMITER $$
CREATE PROCEDURE insertOrder(
    IN  pjReqObj    JSON,
    OUT psResObj    JSON
)
BEGIN
    /* ===================== Column Variables ===================== */
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

    /* ===================== Exchange Variables ===================== */
    DECLARE v_exchange_from_metal       VARCHAR(50);
    DECLARE v_exchange_to_metal         VARCHAR(50);
    DECLARE v_exchange_from_asset_code  VARCHAR(10);
    DECLARE v_exchange_to_asset_code    VARCHAR(10);
    DECLARE v_exchange_weight           VARCHAR(20);

    /* ===================== Exchange Rate Variables ===================== */
    DECLARE v_from_asset_rate_rec_id    INT;
    DECLARE v_from_rate_json            JSON;
    DECLARE v_to_asset_rate_rec_id      INT;
    DECLARE v_to_rate_json              JSON;

    /* ===================== Rate Variables ===================== */
    DECLARE v_asset_rate_rec_id         INT;
    DECLARE v_rate_json                 JSON;

    /* ===================== Customer Request Variables ===================== */
    DECLARE v_cr_rate                   DECIMAL(18,4);
    DECLARE v_cr_amount                 DECIMAL(18,4);
    DECLARE v_cr_weight                 VARCHAR(20);
    DECLARE v_cr_expiration_time        DATETIME;
    DECLARE v_cr_is_partial_fill        TINYINT(1);
    DECLARE v_cr_qty_to_buy             INT;
    DECLARE v_cr_date_of_purchase       DATETIME;
    DECLARE v_cr_quality                VARCHAR(10);
    DECLARE v_cr_payment_method         VARCHAR(50);
    DECLARE v_cr_additional_notes       TEXT;
    DECLARE v_cr_product_images         JSON;

    /* ===================== JSON Objects ===================== */
    DECLARE v_customer_json             JSON;
    DECLARE v_order_json                JSON;
    DECLARE v_row_metadata              JSON;

    /* ===================== Validation Variables ===================== */
    DECLARE v_errors                    JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg                   TEXT;

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

    /* ===================== Main ===================== */
    main_block: BEGIN

        /* ===================== Step 1: Extract Common Fields from Request Object ===================== */
        SET v_account_number        = getJval(pjReqObj, 'account_number');
        SET v_asset_code            = getJval(pjReqObj, 'asset_code');
        SET v_order_type            = getJval(pjReqObj, 'order_type');
        SET v_order_sub_type        = getJval(pjReqObj, 'order_sub_type');
        SET v_order_cat             = getJval(pjReqObj, 'order_cat');
        SET v_metal                 = getJval(pjReqObj, 'metal');

        SET v_exchange_from_metal   = getJval(pjReqObj, 'exchange.from.metal');
        SET v_exchange_to_metal     = getJval(pjReqObj, 'exchange.to.metal');
        SET v_exchange_from_asset_code = getJval(pjReqObj, 'exchange.from.asset_code');
        SET v_exchange_to_asset_code   = getJval(pjReqObj, 'exchange.to.asset_code');
        SET v_exchange_weight       = getJval(pjReqObj, 'exchange.weight');

        SET v_cr_payment_method     = getJval(pjReqObj, 'customer_request.payment_method');
        SET v_cr_date_of_purchase   = NOW();

        /* ===================== Step 2: Common Validations ===================== */
        IF isFalsy(v_account_number) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
        END IF;

        IF isFalsy(v_order_type) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_type is required');
        END IF;

        IF v_order_type IN ('Buy','Sell') THEN
            IF isFalsy(v_asset_code) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'asset_code is required');
            END IF;

            IF isFalsy(v_order_sub_type) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_sub_type is required');
            END IF;

            IF isFalsy(v_metal) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'metal is required');
            END IF;
        END IF;


        IF v_order_type = 'Exchange' THEN
            IF isFalsy(v_exchange_from_metal) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.from.metal is required');
            END IF;
            IF isFalsy(v_exchange_to_metal) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.to.metal is required');
            END IF;
            IF isFalsy(v_exchange_from_asset_code) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.from.asset_code is required');
            END IF;
            IF isFalsy(v_exchange_to_asset_code) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.to.asset_code is required');
            END IF;
            IF isFalsy(v_exchange_weight) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.weight is required');
            END IF;
        END IF;

        IF isFalsy(v_cr_payment_method) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.payment_method is required');
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
        SELECT customer_rec_id INTO v_customer_rec_id
        FROM   customers
        WHERE  account_number = v_account_number;

        CALL getCustomer(v_customer_rec_id, v_customer_json);

        IF isFalsy(v_customer_json) THEN
            SET psResObj = JSON_OBJECT(
                'status',          'error',
                'status_code',     '3',
                'message',         'Customer not found',
                'customer_rec_id', v_customer_rec_id
            );
            LEAVE main_block;
        END IF;

        /* ===================== Step 4: Fetch Latest Rate for Asset ===================== */
        IF v_order_type IN ('Buy', 'Sell') THEN
            SELECT  asset_rate_rec_id,
                    asset_rate_history_json
            INTO    v_asset_rate_rec_id,
                    v_rate_json
            FROM    asset_rate_history
            WHERE   asset_code   = v_asset_code
            ORDER BY rate_timestamp DESC
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
        ELSE
            SET v_asset_rate_rec_id = NULL;
            SET v_rate_json = JSON_OBJECT();
        END IF;

        /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
        CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_order_number);
        CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_receipt_number);

        /* ===================== Step 6: Set Common Order Header Values ===================== */
        SET v_order_date            = NOW();
        SET v_order_status          = 'Pending';
        SET v_next_action_required  = 'Approval';

        /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
        SET v_order_json    = getTemplate('orders');
        SET v_row_metadata  = getTemplate('row_metadata');

        /* ===================== Step 8: Populate customer_info into order_json ===================== */
        SET v_order_json = JSON_SET(v_order_json,
                                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                                    '$.customer_info.customer_name',            getJval(v_customer_json, 'first_name') + ' ' + getJval(v_customer_json, 'last_name'),
                                    '$.customer_info.customer_account_number',  getJval(v_customer_json, 'main_account_number'),
                                    '$.customer_info.customer_phone',           getJval(v_customer_json, 'phone'),
                                    '$.customer_info.whatsapp',                 getJval(v_customer_json, 'whatsapp'),
                                    '$.customer_info.customer_email',           getJval(v_customer_json, 'email'),
                                    '$.customer_info.customer_address',         getJval(v_customer_json, 'residential_address'),
                                    '$.customer_info.customer_ip_address',      getJval(pjReqObj,        'customer_ip_address'),
                                    '$.customer_info.latitude',                 getJval(pjReqObj,        'latitude'),
                                    '$.customer_info.longitude',                getJval(pjReqObj,         'longitude'),
                                    '$.customer_info.notes',                    getJval(pjReqObj,         'notes')
                                );

        /* ===================== Step 9: Populate rate_info into order_json ===================== */
        SET v_order_json = JSON_SET(v_order_json,
                                    '$.rate_info.rate_rec_id',              v_asset_rate_rec_id,
                                    '$.rate_info.spot_rate',                getJval(v_rate_json, 'spot_rate'),
                                    '$.rate_info.currency_unit',            getJval(v_rate_json, 'currency_unit'),
                                    '$.rate_info.rate_source',              getJval(v_rate_json, 'source_info.rate_source'),
                                    '$.rate_info.foreign_exchange_rate',    getJval(v_rate_json, 'foreign_exchange.foreign_exchange_rate'),
                                    '$.rate_info.foreign_exchange_source',  getJval(v_rate_json, 'foreign_exchange.foreign_exchange_source')
                                );

        /* ===================== Step 10: Populate common order header into order_json ===================== */
        SET v_order_json = JSON_SET(v_order_json,
                                    '$.customer_rec_id',        v_customer_rec_id,
                                    '$.account_number',         v_account_number,
                                    '$.order_number',           v_order_number,
                                    '$.receipt_number',         v_receipt_number,
                                    '$.order_date',             DATE_FORMAT(v_order_date, '%Y-%m-%dT%H:%i:%sZ'),
                                    '$.order_status',           v_order_status,
                                    '$.next_action_required',   v_next_action_required,
                                    '$.order_type',             v_order_type,
                                    '$.order_sub_type',         v_order_sub_type,
                                    '$.metal',                  v_metal
                                );

        /* ===================== Step 11: Branch by order_type ===================== */

        -- =======================================================================
        -- BUY
        -- Sub types: Market, Limit, Products
        -- =======================================================================
        IF v_order_type = 'Buy' THEN

            -- -------------------------------------------------------------------
            -- BUY : Market Order
            -- Required : amount, payment_method
            -- order_cat forced to DO
            -- -------------------------------------------------------------------
            IF v_order_sub_type = 'Market' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.amount')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for Market order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT(
                                                'status', 'error', 
                                                'status_code', '2', 
                                                'message', 'Validation failed',
                                                'errors', v_errors
                                                );
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_cat',                              v_order_cat,
                    '$.buy_items',                              getJval(pjReqObj, 'buy_items'),
                    '$.customer_request.amount',                getJval(pjReqObj, 'customer_request.amount'),
                    '$.customer_request.payment_method',        v_cr_payment_method,
                    '$.customer_request.date_of_purchase',      DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
                );

            -- -------------------------------------------------------------------
            -- BUY : Limit Order
            -- Required : rate, weight, Expiration_time, payment_method
            -- order_cat : GTC or IOC from request
            -- -------------------------------------------------------------------
            ELSEIF v_order_sub_type = 'Limit' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.rate')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.rate is required for Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'customer_request.Expiration_time')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.Expiration_time is required for Limit order');
                END IF;

                IF isFalsy(v_order_cat) OR v_order_cat NOT IN ('GTC', 'IOC') THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_cat must be GTC or IOC for Limit order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_json = JSON_SET(v_order_json,
                                            '$.order_cat',                                  v_order_cat,
                                            '$.buy_items',                                  getJval(pjReqObj, 'buy_items'),
                                            '$.customer_request.rate',                      getJval(pjReqObj, 'customer_request.rate'),
                                            '$.customer_request.weight',                    getJval(pjReqObj, 'customer_request.weight'),
                                            '$.customer_request.amount',                    getJval(pjReqObj, 'customer_request.amount'),
                                            '$.customer_request.Expiration_time',           getJval(pjReqObj, 'customer_request.Expiration_time'),
                                            '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'customer_request.is_partial_fill_allowed'),
                                            '$.customer_request.payment_method',            v_cr_payment_method,
                                            '$.customer_request.date_of_purchase',          DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
                                        );

            -- -------------------------------------------------------------------
            -- BUY : Physical Products
            -- Required : buy_items array, payment_method
            -- order_cat forced to DO
            -- -------------------------------------------------------------------
            ELSEIF v_order_sub_type = 'Products' THEN

                IF isFalsy(getJval(pjReqObj, 'buy_items')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'buy_items are required for Products order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_cat',                          v_order_cat,
                    '$.buy_items',                          getJval(pjReqObj, 'buy_items'),
                    '$.customer_request.payment_method',    v_cr_payment_method,
                    '$.customer_request.date_of_purchase',  DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
                );

            ELSE
                SET psResObj = JSON_OBJECT(
                    'status',       'error',
                    'status_code',  '5',
                    'message',      'Unknown order_sub_type for Buy. Must be Market, Limit or Products'
                );
                LEAVE main_block;
            END IF; -- End Buy sub types
        
        -- =======================================================================
        -- SELL
        -- Sub types: Market, Limit
        -- =======================================================================
        ELSEIF v_order_type = 'Sell' THEN

            -- -------------------------------------------------------------------
            -- SELL : Market Order (sell at current spot rate immediately)
            -- Required : weight, payment_method
            -- order_cat forced to DO
            -- -------------------------------------------------------------------
            IF v_order_sub_type = 'Market' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for Sell Market order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_cat',                              v_order_cat,
                    '$.sell_items',                             getJval(pjReqObj, 'sell_items'),
                    '$.customer_request.weight',                getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.payment_method',        v_cr_payment_method,
                    '$.customer_request.date_of_purchase',      DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
                );

            -- -------------------------------------------------------------------
            -- SELL : Limit Order (sell at customer's target rate)
            -- Required : rate, weight, Expiration_time, payment_method
            -- order_cat : GTC or IOC from request
            -- -------------------------------------------------------------------
            ELSEIF v_order_sub_type = 'Limit' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.rate')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.rate is required for Sell Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for Sell Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'customer_request.Expiration_time')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.Expiration_time is required for Sell Limit order');
                END IF;

                IF isFalsy(v_order_cat) OR v_order_cat NOT IN ('GTC', 'IOC') THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_cat must be GTC or IOC for Sell Limit order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_cat',                                  v_order_cat,
                    '$.sell_items',                                 getJval(pjReqObj, 'sell_items'),
                    '$.customer_request.rate',                      getJval(pjReqObj, 'customer_request.rate'),
                    '$.customer_request.weight',                    getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.amount',                    getJval(pjReqObj, 'customer_request.amount'),
                    '$.customer_request.Expiration_time',           getJval(pjReqObj, 'customer_request.Expiration_time'),
                    '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'customer_request.is_partial_fill_allowed'),
                    '$.customer_request.payment_method',            v_cr_payment_method,
                    '$.customer_request.date_of_purchase',          DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
                );

            ELSE
                SET psResObj = JSON_OBJECT(
                    'status',       'error',
                    'status_code',  '5',
                    'message',      'Unknown order_sub_type for Sell. Must be Market or Limit'
                );
                LEAVE main_block;
            END IF; -- End Sell sub types

        ELSEIF v_order_type = 'Exchange' THEN

            -- Fetch from and to rates for the exchange asset codes
            SELECT asset_rate_rec_id, asset_rate_history_json
            INTO v_from_asset_rate_rec_id, v_from_rate_json
            FROM asset_rate_history
            WHERE asset_code = v_exchange_from_asset_code
            ORDER BY rate_timestamp DESC
            LIMIT 1;

            IF isFalsy(v_from_rate_json) THEN
                SET psResObj = JSON_OBJECT(
                                            'status',       'error',
                                            'status_code',  '4',
                                            'message',      'Rate not found for exchange.from.asset_code',
                                            'asset_code',   v_exchange_from_asset_code
                                        );
                LEAVE main_block;
            END IF;

            SELECT asset_rate_rec_id, asset_rate_history_json
            INTO v_to_asset_rate_rec_id, v_to_rate_json
            FROM asset_rate_history
            WHERE asset_code = v_exchange_to_asset_code
            ORDER BY rate_timestamp DESC
            LIMIT 1;

            IF isFalsy(v_to_rate_json) THEN
                SET psResObj = JSON_OBJECT(
                                            'status',       'error',
                                            'status_code',  '4',
                                            'message',      'Rate not found for exchange.to.asset_code',
                                            'asset_code',   v_exchange_to_asset_code
                                        );
                LEAVE main_block;
            END IF;

            SET v_order_cat = 'DO';

            SET v_order_json = JSON_SET(v_order_json,
                                        '$.order_cat',                           v_order_cat,
                                        '$.order_type',                          v_order_type,
                                        '$.order_sub_type',                      v_order_sub_type,
                                        '$.metal',                               v_exchange_from_metal,
                                        '$.exchange.from.metal',                 v_exchange_from_metal,
                                        '$.exchange.from.asset_code',            v_exchange_from_asset_code,
                                        '$.exchange.to.metal',                   v_exchange_to_metal,
                                        '$.exchange.to.asset_code',              v_exchange_to_asset_code,
                                        '$.exchange.weight',                     v_exchange_weight,
                                        '$.sell_items',                          JSON_ARRAY(JSON_OBJECT('metal', v_exchange_from_metal, 'asset_code', v_exchange_from_asset_code, 'weight', v_exchange_weight)),
                                        '$.buy_items',                           JSON_ARRAY(JSON_OBJECT('metal', v_exchange_to_metal, 'asset_code', v_exchange_to_asset_code, 'weight', v_exchange_weight)),
                                        '$.rate_info.from_rate_rec_id',          v_from_asset_rate_rec_id,
                                        '$.rate_info.from_rate_json',            v_from_rate_json,
                                        '$.rate_info.to_rate_rec_id',            v_to_asset_rate_rec_id,
                                        '$.rate_info.to_rate_json',              v_to_rate_json
                                    );

        ELSEIF v_order_type = 'Redeem' THEN

            IF isFalsy(getJval(pjReqObj, 'buy_items')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'buy_items are required for Redeem order');
            END IF;

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT(
                                            'status', 'error',
                                            'status_code', '2',
                                            'message', 'Validation failed',
                                            'errors', v_errors
                                        );
                LEAVE main_block;
            END IF;

            SET v_order_cat = 'DO';

            SET v_order_json = JSON_SET(v_order_json,
                                        '$.order_cat',                              v_order_cat,
                                        '$.order_type',                             v_order_type,
                                        '$.order_sub_type',                         v_order_sub_type,
                                        '$.metal',                                  v_metal,
                                        '$.buy_items',                              getJval(pjReqObj, 'buy_items'),
                                        '$.customer_request.payment_method',        v_cr_payment_method,
                                        '$.customer_request.date_of_purchase',      DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ'),
                                        '$.rate_info.rate_rec_id',                  v_asset_rate_rec_id,
                                        '$.rate_info.spot_rate',                    getJval(v_rate_json, 'spot_rate'),
                                        '$.rate_info.currency_unit',                getJval(v_rate_json, 'currency_unit'),
                                        '$.rate_info.rate_source',                  getJval(v_rate_json, 'source_info.rate_source'),
                                        '$.rate_info.foreign_exchange_rate',        getJval(v_rate_json, 'foreign_exchange.foreign_exchange_rate'),
                                        '$.rate_info.foreign_exchange_source',      getJval(v_rate_json, 'foreign_exchange.foreign_exchange_source')
                                    );

        ELSE

            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '6',
                                        'message',      'order_type not yet implemented. Currently Buy, Sell and Exchange are supported'
                                    );
            LEAVE main_block;

        END IF; -- End order_type branch

        /* ===================== Step 12: INSERT into orders table ===================== */
        START TRANSACTION;

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
                    metal                   = v_metal,
                    order_json              = v_order_json,
                    row_metadata            = v_row_metadata;

            SET v_order_rec_id = LAST_INSERT_ID();

        COMMIT;

        /* ===================== Success Response ===================== */
        SET psResObj = JSON_OBJECT(
                                    'status',           'success',
                                    'status_code',      '0',
                                    'message',          'Order inserted successfully',
                                    'order_rec_id',     v_order_rec_id,
                                    'order_number',     v_order_number,
                                    'receipt_number',   v_receipt_number,
                                    'order_type',       v_order_type,
                                    'order_sub_type',   v_order_sub_type,
                                    'order_cat',        v_order_cat,
                                    'order_json',       v_order_json
                                );

    END; -- main_block

END$$
DELIMITER ;
