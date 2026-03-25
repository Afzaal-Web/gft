-- ==================================================================================================
-- Procedure:          insertOrder
-- Purpose:            Handle all order types: Buy (Market/Manual/Products), Sell (Auto/Manual),
--                     Exchange, Redeem, Sell Physical Gold
-- Functions used:
--                      isFalsy()       : validate values from reqObj
--                      getJval()       : get value from request object
--                      getTemplate()   : get json column template
--                      getSequence()   : generate order/receipt numbers
-- ==================================================================================================
DROP PROCEDURE IF EXISTS insertOrder;
DELIMITER $$
CREATE PROCEDURE insertOrder(
                                IN  pjReqObj    JSON,
                                OUT psResObj    JSON
                            )
BEGIN
    /* ===================== Column Variables ===================== */
    DECLARE v_order_rec_id              INT;
    DECLARE v_linked_order_rec_id       INT;
    DECLARE v_customer_rec_id           INT;
    DECLARE v_account_number            VARCHAR(50);
    DECLARE v_order_number              VARCHAR(50);
    DECLARE v_receipt_number            VARCHAR(50);
    DECLARE v_order_date                DATETIME;
    DECLARE v_order_status              VARCHAR(20);
    DECLARE v_next_action_required      VARCHAR(20);
    DECLARE v_order_cat                 VARCHAR(10);
    DECLARE v_order_type                VARCHAR(20);
    DECLARE v_metal                     VARCHAR(50);
    DECLARE v_order_sub_type            VARCHAR(50);  -- Market, Manual, Products, PhysicalGold

    /* ===================== Rate Variables ===================== */
    DECLARE v_rate_rec_id               INT;
    DECLARE v_spot_rate                 DECIMAL(18,4);
    DECLARE v_currency_unit             VARCHAR(10);
    DECLARE v_rate_source               VARCHAR(100);
    DECLARE v_fx_rate                   DECIMAL(18,4);
    DECLARE v_fx_source                 VARCHAR(100);

    /* ===================== Exchange Variables ===================== */
    DECLARE v_exchange_sell_rec_id      INT;
    DECLARE v_exchange_buy_rec_id       INT;
    DECLARE v_exchange_order_number     VARCHAR(50);
    DECLARE v_exchange_receipt_number   VARCHAR(50);

    /* ===================== Exchange Rate Variables (from_metal / to_metal) ===================== */
    DECLARE v_from_rate_rec_id          INT;
    DECLARE v_from_spot_rate            DECIMAL(18,4);
    DECLARE v_from_currency_unit        VARCHAR(10);
    DECLARE v_from_rate_source          VARCHAR(100);
    DECLARE v_from_fx_rate              DECIMAL(18,4);
    DECLARE v_from_fx_source            VARCHAR(100);

    DECLARE v_to_rate_rec_id            INT;
    DECLARE v_to_spot_rate              DECIMAL(18,4);
    DECLARE v_to_currency_unit          VARCHAR(10);
    DECLARE v_to_rate_source            VARCHAR(100);
    DECLARE v_to_fx_rate                DECIMAL(18,4);
    DECLARE v_to_fx_source              VARCHAR(100);

    /* ===================== JSON Objects ===================== */
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

        /* ===================== Extract Common Fields from Request Object ===================== */
        SET v_customer_rec_id   = getJval(pjReqObj, 'customer_rec_id');
        SET v_account_number    = getJval(pjReqObj, 'account_number');
        SET v_order_type        = getJval(pjReqObj, 'order_type');      -- Buy, Sell, Exchange, Redeem
        SET v_order_sub_type    = getJval(pjReqObj, 'order_sub_type');  -- Market, Manual, Products, PhysicalGold
        SET v_order_cat         = getJval(pjReqObj, 'order_cat');       -- DO, IOC, GTC
        SET v_metal             = getJval(pjReqObj, 'metal');           -- Gold, Silver, Platinum
        SET v_order_date        = NOW();

        /* ===================== Common Validation ===================== */
        IF isFalsy(v_customer_rec_id) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_rec_id is required');
        END IF;

        IF isFalsy(v_order_type) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_type is required');
        END IF;

        IF isFalsy(v_metal) AND v_order_type != 'Exchange' THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'metal is required');
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

        /* ===================== Fetch Latest Rate from Rates Table ===================== */
        /* FIX #2: Skip rate fetch for Exchange — rates fetched per leg inside Exchange block */
        IF v_order_type != 'Exchange' THEN
            SELECT  rate_rec_id,    spot_rate,      currency_unit,      rate_source,    foreign_exchange_rate,  foreign_exchange_source
            INTO    v_rate_rec_id,  v_spot_rate,    v_currency_unit,    v_rate_source,  v_fx_rate,              v_fx_source
            FROM    rates
            WHERE   metal       = v_metal
            AND     is_active   = 1
            ORDER BY created_at DESC
            LIMIT 1;
        END IF;

        /* ===================== Get Templates ===================== */
        SET v_order_json    = getTemplate('orders');
        SET v_row_metadata  = getTemplate('row_metadata');

        /* ===================== Branch by Order Type ===================== */

        -- -----------------------------------------------------------------------
        -- BUY
        -- Sub types: Market, Manual, Products
        -- -----------------------------------------------------------------------
        IF v_order_type = 'Buy' THEN

            SET v_order_status          = 'pending';
            SET v_next_action_required  = 'approved';

            -- Buy Market Order (Reserve Gold Slice - Auto Select)
            IF v_order_sub_type = 'Market' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.amount')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'amount is required for Market order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';  -- Market orders are Day Orders

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_order_number,
                    '$.receipt_number',                         v_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             v_order_type,
                    '$.metal',                                  v_metal,
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.amount',                getJval(pjReqObj, 'customer_request.amount'),
                    '$.customer_request.date_of_purchase',      v_order_date,
                    '$.customer_request.payment_method',        getJval(pjReqObj, 'customer_request.payment_method'),
                    '$.rate_info.rate_rec_id',                  v_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_spot_rate,
                    '$.rate_info.currency_unit',                v_currency_unit,
                    '$.rate_info.rate_source',                  v_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_fx_source
                );

            -- Buy Manual Price
            ELSEIF v_order_sub_type = 'Manual' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.rate')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'rate is required for Manual order');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'weight is required for Manual order');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.Expiration_time')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'Expiration_time is required for Manual order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                               v_order_number,
                    '$.receipt_number',                             v_receipt_number,
                    '$.order_date',                                 v_order_date,
                    '$.order_status',                               v_order_status,
                    '$.next_action_required',                       v_next_action_required,
                    '$.order_cat',                                  v_order_cat,
                    '$.order_type',                                 v_order_type,
                    '$.metal',                                      v_metal,
                    '$.customer_info.customer_rec_id',              v_customer_rec_id,
                    '$.customer_info.customer_name',                getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',      v_account_number,
                    '$.customer_info.customer_phone',               getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                     getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',               getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',             getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',          getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                     getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                    getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.rate',                      getJval(pjReqObj, 'customer_request.rate'),
                    '$.customer_request.weight',                    getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.amount',                    getJval(pjReqObj, 'customer_request.amount'),
                    '$.customer_request.Expiration_time',           getJval(pjReqObj, 'customer_request.Expiration_time'),
                    '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'customer_request.is_partial_fill_allowed'),
                    '$.customer_request.payment_method',            getJval(pjReqObj, 'customer_request.payment_method'),
                    '$.customer_request.date_of_purchase',          v_order_date,
                    '$.rate_info.rate_rec_id',                      v_rate_rec_id,
                    '$.rate_info.spot_rate',                        v_spot_rate,
                    '$.rate_info.currency_unit',                    v_currency_unit,
                    '$.rate_info.rate_source',                      v_rate_source,
                    '$.rate_info.foreign_exchange_rate',            v_fx_rate,
                    '$.rate_info.foreign_exchange_source',          v_fx_source
                );

            -- Buy Gold Products
            ELSEIF v_order_sub_type = 'Products' THEN

                IF isFalsy(getJval(pjReqObj, 'buy_items')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'buy_items are required for Products order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_order_number,
                    '$.receipt_number',                         v_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             v_order_type,
                    '$.metal',                                  v_metal,
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.buy_items',                              getJval(pjReqObj, 'buy_items'),
                    '$.customer_request.payment_method',        getJval(pjReqObj, 'customer_request.payment_method'),
                    '$.customer_request.date_of_purchase',      v_order_date,
                    '$.rate_info.rate_rec_id',                  v_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_spot_rate,
                    '$.rate_info.currency_unit',                v_currency_unit,
                    '$.rate_info.rate_source',                  v_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_fx_source
                );

            END IF; -- End Buy sub types

            START TRANSACTION;
                CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_order_number);
                CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_receipt_number);

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

        -- -----------------------------------------------------------------------
        -- SELL
        -- Sub types: Market / Auto-Select, Manual, Physical Gold
        -- -----------------------------------------------------------------------
        ELSEIF v_order_type = 'Sell' THEN

            SET v_order_status          = 'pending';
            SET v_next_action_required  = 'approved';

            -- Sell Market / Auto Select
            IF v_order_sub_type = 'Market' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'weight is required for Market Sell order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_order_number,
                    '$.receipt_number',                         v_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             v_order_type,
                    '$.metal',                                  v_metal,
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.weight',                getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.date_of_purchase',      v_order_date,
                    '$.rate_info.rate_rec_id',                  v_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_spot_rate,
                    '$.rate_info.currency_unit',                v_currency_unit,
                    '$.rate_info.rate_source',                  v_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_fx_source
                );

            -- Sell Manual
            ELSEIF v_order_sub_type = 'Manual' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.rate')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'rate is required for Manual Sell order');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'weight is required for Manual Sell order');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.Expiration_time')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'Expiration_time is required for Manual Sell order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                               v_order_number,
                    '$.receipt_number',                             v_receipt_number,
                    '$.order_date',                                 v_order_date,
                    '$.order_status',                               v_order_status,
                    '$.next_action_required',                       v_next_action_required,
                    '$.order_cat',                                  v_order_cat,
                    '$.order_type',                                 v_order_type,
                    '$.metal',                                      v_metal,
                    '$.customer_info.customer_rec_id',              v_customer_rec_id,
                    '$.customer_info.customer_name',                getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',      v_account_number,
                    '$.customer_info.customer_phone',               getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                     getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',               getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',             getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',          getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                     getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                    getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.rate',                      getJval(pjReqObj, 'customer_request.rate'),
                    '$.customer_request.weight',                    getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.amount',                    getJval(pjReqObj, 'customer_request.amount'),
                    '$.customer_request.Expiration_time',           getJval(pjReqObj, 'customer_request.Expiration_time'),
                    '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'customer_request.is_partial_fill_allowed'),
                    '$.customer_request.date_of_purchase',          v_order_date,
                    '$.rate_info.rate_rec_id',                      v_rate_rec_id,
                    '$.rate_info.spot_rate',                        v_spot_rate,
                    '$.rate_info.currency_unit',                    v_currency_unit,
                    '$.rate_info.rate_source',                      v_rate_source,
                    '$.rate_info.foreign_exchange_rate',            v_fx_rate,
                    '$.rate_info.foreign_exchange_source',          v_fx_source
                );

            -- Sell Physical Gold
            ELSEIF v_order_sub_type = 'PhysicalGold' THEN

                IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'weight is required for Physical Gold');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.quality')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'karat/quality is required for Physical Gold');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.date_of_purchase')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'date_of_purchase is required for Physical Gold');
                END IF;
                IF isFalsy(getJval(pjReqObj, 'customer_request.payment_method')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'payment_method is required for Physical Gold');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                    LEAVE main_block;
                END IF;

                SET v_order_cat = 'DO';

                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_order_number,
                    '$.receipt_number',                         v_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             v_order_type,
                    '$.metal',                                  v_metal,
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.weight',                getJval(pjReqObj, 'customer_request.weight'),
                    '$.customer_request.quality',               getJval(pjReqObj, 'customer_request.quality'),
                    '$.customer_request.date_of_purchase',      getJval(pjReqObj, 'customer_request.date_of_purchase'),
                    '$.customer_request.payment_method',        getJval(pjReqObj, 'customer_request.payment_method'),
                    '$.customer_request.additional_notes',      getJval(pjReqObj, 'customer_request.additional_notes'),
                    '$.customer_request.product_images',        getJval(pjReqObj, 'customer_request.product_images'),
                    '$.rate_info.rate_rec_id',                  v_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_spot_rate,
                    '$.rate_info.currency_unit',                v_currency_unit,
                    '$.rate_info.rate_source',                  v_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_fx_source
                );

            END IF; -- End Sell sub types

            START TRANSACTION;
                CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_order_number);
                CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_receipt_number);

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

        -- -----------------------------------------------------------------------
        -- EXCHANGE
        -- Two linked orders: one Sell (from_metal) + one Buy (to_metal)
        -- -----------------------------------------------------------------------
        ELSEIF v_order_type = 'Exchange' THEN

            IF isFalsy(getJval(pjReqObj, 'exchange.from_metal')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'from_metal is required for Exchange');
            END IF;
            IF isFalsy(getJval(pjReqObj, 'exchange.to_metal')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'to_metal is required for Exchange');
            END IF;
            IF isFalsy(getJval(pjReqObj, 'exchange.weight')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'weight is required for Exchange');
            END IF;

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                LEAVE main_block;
            END IF;

            SET v_order_status          = 'pending';
            SET v_next_action_required  = 'approved';
            SET v_order_cat             = 'DO';

            /* FIX #2: Fetch rates separately for from_metal and to_metal */
            SELECT  rate_rec_id,        spot_rate,          currency_unit,          rate_source,        foreign_exchange_rate,  foreign_exchange_source
            INTO    v_from_rate_rec_id, v_from_spot_rate,   v_from_currency_unit,   v_from_rate_source, v_from_fx_rate,         v_from_fx_source
            FROM    rates
            WHERE   metal       = getJval(pjReqObj, 'exchange.from_metal')
            AND     is_active   = 1
            ORDER BY created_at DESC
            LIMIT 1;

            SELECT  rate_rec_id,        spot_rate,          currency_unit,          rate_source,        foreign_exchange_rate,  foreign_exchange_source
            INTO    v_to_rate_rec_id,   v_to_spot_rate,     v_to_currency_unit,     v_to_rate_source,   v_to_fx_rate,           v_to_fx_source
            FROM    rates
            WHERE   metal       = getJval(pjReqObj, 'exchange.to_metal')
            AND     is_active   = 1
            ORDER BY created_at DESC
            LIMIT 1;

            /* FIX #1 & #3: Sequences generated INSIDE transaction */
            START TRANSACTION;

                CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_order_number);
                CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_receipt_number);
                CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_exchange_order_number);
                CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_exchange_receipt_number);

                -- Leg 1: SELL order (from_metal)
                SET v_order_json = getTemplate('orders');
                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_order_number,
                    '$.receipt_number',                         v_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             'Sell',
                    '$.metal',                                  getJval(pjReqObj, 'exchange.from_metal'),
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.weight',                getJval(pjReqObj, 'exchange.weight'),
                    '$.customer_request.date_of_purchase',      v_order_date,
                    '$.rate_info.rate_rec_id',                  v_from_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_from_spot_rate,
                    '$.rate_info.currency_unit',                v_from_currency_unit,
                    '$.rate_info.rate_source',                  v_from_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_from_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_from_fx_source
                );

                INSERT INTO orders
                    SET customer_rec_id         = v_customer_rec_id,
                        account_number          = v_account_number,
                        order_number            = v_order_number,
                        receipt_number          = v_receipt_number,
                        order_date              = v_order_date,
                        order_status            = v_order_status,
                        next_action_required    = v_next_action_required,
                        order_cat               = v_order_cat,
                        order_type              = 'Sell',
                        metal                   = getJval(pjReqObj, 'exchange.from_metal'),
                        order_json              = v_order_json,
                        row_metadata            = v_row_metadata;

                SET v_exchange_sell_rec_id = LAST_INSERT_ID();

                -- Leg 2: BUY order (to_metal)
                SET v_order_json = getTemplate('orders');
                SET v_order_json = JSON_SET(v_order_json,
                    '$.order_number',                           v_exchange_order_number,
                    '$.receipt_number',                         v_exchange_receipt_number,
                    '$.order_date',                             v_order_date,
                    '$.order_status',                           v_order_status,
                    '$.next_action_required',                   v_next_action_required,
                    '$.order_cat',                              v_order_cat,
                    '$.order_type',                             'Buy',
                    '$.metal',                                  getJval(pjReqObj, 'exchange.to_metal'),
                    '$.customer_info.customer_rec_id',          v_customer_rec_id,
                    '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                    '$.customer_info.customer_account_number',  v_account_number,
                    '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                    '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                    '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                    '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                    '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                    '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                    '$.customer_request.weight',                getJval(pjReqObj, 'exchange.to_weight'),
                    '$.customer_request.date_of_purchase',      v_order_date,
                    '$.rate_info.rate_rec_id',                  v_to_rate_rec_id,
                    '$.rate_info.spot_rate',                    v_to_spot_rate,
                    '$.rate_info.currency_unit',                v_to_currency_unit,
                    '$.rate_info.rate_source',                  v_to_rate_source,
                    '$.rate_info.foreign_exchange_rate',        v_to_fx_rate,
                    '$.rate_info.foreign_exchange_source',      v_to_fx_source
                );

                INSERT INTO orders
                    SET customer_rec_id         = v_customer_rec_id,
                        account_number          = v_account_number,
                        order_number            = v_exchange_order_number,
                        receipt_number          = v_exchange_receipt_number,
                        order_date              = v_order_date,
                        order_status            = v_order_status,
                        next_action_required    = v_next_action_required,
                        order_cat               = v_order_cat,
                        order_type              = 'Buy',
                        metal                   = getJval(pjReqObj, 'exchange.to_metal'),
                        order_json              = v_order_json,
                        row_metadata            = v_row_metadata;

                SET v_exchange_buy_rec_id = LAST_INSERT_ID();

                UPDATE orders SET linked_order_rec_id = v_exchange_buy_rec_id  WHERE order_rec_id = v_exchange_sell_rec_id;
                UPDATE orders SET linked_order_rec_id = v_exchange_sell_rec_id WHERE order_rec_id = v_exchange_buy_rec_id;

                SET v_order_rec_id = v_exchange_sell_rec_id;

            COMMIT;

        -- -----------------------------------------------------------------------
        -- REDEEM
        -- Multiple products as array in buy_items, single order row
        -- -----------------------------------------------------------------------
        ELSEIF v_order_type = 'Redeem' THEN

            IF isFalsy(getJval(pjReqObj, 'buy_items')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'buy_items are required for Redeem order');
            END IF;

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT('status', 'error', 'status_code', '2', 'message', 'Validation failed', 'errors', v_errors);
                LEAVE main_block;
            END IF;

            SET v_order_status          = 'pending';
            SET v_next_action_required  = 'approved';
            SET v_order_cat             = 'DO';

            SET v_order_json = JSON_SET(v_order_json,
                '$.order_number',                           v_order_number,
                '$.receipt_number',                         v_receipt_number,
                '$.order_date',                             v_order_date,
                '$.order_status',                           v_order_status,
                '$.next_action_required',                   v_next_action_required,
                '$.order_cat',                              v_order_cat,
                '$.order_type',                             v_order_type,
                '$.metal',                                  v_metal,
                '$.customer_info.customer_rec_id',          v_customer_rec_id,
                '$.customer_info.customer_name',            getJval(pjReqObj, 'customer_info.customer_name'),
                '$.customer_info.customer_account_number',  v_account_number,
                '$.customer_info.customer_phone',           getJval(pjReqObj, 'customer_info.customer_phone'),
                '$.customer_info.whatsapp',                 getJval(pjReqObj, 'customer_info.whatsapp'),
                '$.customer_info.customer_email',           getJval(pjReqObj, 'customer_info.customer_email'),
                '$.customer_info.customer_address',         getJval(pjReqObj, 'customer_info.customer_address'),
                '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_info.customer_ip_address'),
                '$.customer_info.latitude',                 getJval(pjReqObj, 'customer_info.latitude'),
                '$.customer_info.longitude',                getJval(pjReqObj, 'customer_info.longitude'),
                '$.buy_items',                              getJval(pjReqObj, 'buy_items'),
                '$.order_pickup_info.pickup_required',      TRUE,
                '$.order_pickup_info.pickup_status',        'Pending',
                '$.rate_info.rate_rec_id',                  v_rate_rec_id,
                '$.rate_info.spot_rate',                    v_spot_rate,
                '$.rate_info.currency_unit',                v_currency_unit,
                '$.rate_info.rate_source',                  v_rate_source,
                '$.rate_info.foreign_exchange_rate',        v_fx_rate,
                '$.rate_info.foreign_exchange_source',      v_fx_source
            );

            START TRANSACTION;
                CALL getSequence('ORDER.ORDER_NUM',   NULL, NULL, 'insertOrder sp', v_order_number);
                CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'insertOrder sp', v_receipt_number);

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

        ELSE
            -- Unknown order type
            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '3',
                                        'message',      'Unknown order_type. Must be Buy, Sell, Exchange or Redeem'
                                      );
            LEAVE main_block;
        END IF;

        /* ===================== Success Response ===================== */
        SET psResObj = JSON_OBJECT(
                                    'status',           'success',
                                    'status_code',      '0',
                                    'message',          'Order inserted successfully',
                                    'order_rec_id',     v_order_rec_id,
                                    'order_number',     v_order_number,
                                    'receipt_number',   v_receipt_number,
                                    'order_type',       v_order_type,
                                    'order_sub_type',   v_order_sub_type
                                  );

    END; -- main_block

END$$
DELIMITER ;