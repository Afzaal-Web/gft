DROP PROCEDURE IF EXISTS createBuyOrder;

DELIMITER $$
CREATE PROCEDURE createBuyOrder(
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
    DECLARE v_order_sub_type            VARCHAR(20);
    DECLARE v_metal                     VARCHAR(50);
    DECLARE v_asset_code                VARCHAR(10);
    DECLARE v_product_type              VARCHAR(20);
    DECLARE v_cr_payment_method         VARCHAR(50);        
    DECLARE v_cr_rate                   DECIMAL(18,6);  
    DECLARE v_cr_weight                 DECIMAL(18,6);       

    DECLARE v_tradable_assets_rec_id    INT;
    DECLARE v_rate_json                 JSON;
    DECLARE v_spot_rate                 DECIMAL(18,6);      

    DECLARE v_customer_json             JSON;
    DECLARE v_order_json                JSON;
    DECLARE v_row_metadata              JSON;

    /*  buy_items variables (shared by SLICE and PRODUCT)  */
    DECLARE v_inventory_json            JSON;
    DECLARE v_item_code                 VARCHAR(50);
    DECLARE v_item_name                 VARCHAR(100);
    DECLARE v_item_type                 VARCHAR(50);
    DECLARE v_item_weight               DECIMAL(18,6);
    DECLARE v_item_quantity             INT;
    DECLARE v_bought_price              DECIMAL(18,2);
    DECLARE v_buy_items_output          JSON;

    /* Order Summary Variables */

    DECLARE v_total_buy_items       INT DEFAULT 0;
    DECLARE v_total_buy_amount      DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_buy_weight      DECIMAL(20,6) DEFAULT 0;
    DECLARE v_making_charges        DECIMAL(20,6) DEFAULT 0;
    DECLARE v_premium_charged       DECIMAL(20,6) DEFAULT 0;
    DECLARE v_transaction_fee       DECIMAL(20,6) DEFAULT 0;
    DECLARE v_processing_charges    DECIMAL(20,6) DEFAULT 0;
    DECLARE v_taxes                 DECIMAL(20,6) DEFAULT 0;
    DECLARE v_total_discounts       DECIMAL(20,6) DEFAULT 0;

    /* --- PRODUCT loop variables --- */
    DECLARE v_buy_items_input           JSON;
    DECLARE v_single_item               JSON;
    DECLARE v_loop_idx                  INT DEFAULT 0;
    DECLARE v_items_count               INT DEFAULT 0;

    /* --- Transaction / wallet variables --- */
    DECLARE v_txn_num                   VARCHAR(50);
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
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '1',
                                    'message',      'Insertion failed',
                                    'system_error', v_err_msg
                                );
    END;

main_block: BEGIN
    /* ===================== Step 1: Extract Request Values ===================== */
    SET v_order_type            = 'Buy';
    SET v_account_number        = getJval(pjReqObj, 'account_number');
    SET v_asset_code            = getJval(pjReqObj, 'asset_code');
    SET v_order_sub_type        = getJval(pjReqObj, 'order_sub_type');
    SET v_order_cat             = getJval(pjReqObj, 'order_cat');
    SET v_metal                 = getJval(pjReqObj, 'metal');
    SET v_product_type          = getJval(pjReqObj, 'product_type');
    SET v_cr_payment_method     = getJval(pjReqObj, 'customer_request.payment_method');

    /* For PRODUCT, order_sub_type is not applicable */
    IF v_product_type = 'PRODUCT' THEN
        SET v_order_sub_type = NULL;
    END IF;

    /* ===================== Step 2: Common Validations ===================== */
    IF isFalsy(v_account_number) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
    END IF;

    IF isFalsy(v_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'asset_code is required');
    END IF;

    IF isFalsy(v_order_type) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_type is required');
    END IF;

    IF isFalsy(v_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'metal is required');
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
    SELECT  customer_rec_id 
    INTO    v_customer_rec_id
    FROM    customer
    WHERE   account_num = v_account_number;

    CALL getCustomer(JSON_OBJECT('P_CUSTOMER_REC_ID', v_customer_rec_id), v_customer_json);

    IF getJval(v_customer_json, 'status') != 'success' THEN
        SET psResObj = JSON_OBJECT(
                                    'status',               'error',
                                    'status_code',          '3',
                                    'message',              'Customer not found',
                                    'customer_rec_id',      v_customer_rec_id
                                    );
        LEAVE main_block;
    END IF;

    SET v_customer_json = getJval(v_customer_json, 'customer_data');

    /* ===================== Step 4: Fetch Latest Rate for Asset rate history ===================== */
    SELECT  tradable_assets_rec_id,      tradable_assets_json
    INTO    v_tradable_assets_rec_id,    v_rate_json
    FROM    tradable_assets
    WHERE   asset_code = v_asset_code;

    IF isFalsy(v_rate_json) THEN
        SET psResObj = JSON_OBJECT(
                                    'status',               'error',
                                    'status_code',          '4',
                                    'message',              'Rate not found for asset_code',
                                    'asset_code',           v_asset_code
                                    );
        LEAVE main_block;
    END IF;

    /* Extract spot_rate once - reused in buy_items price calculation */    
    SET v_spot_rate = getJval(v_rate_json, 'spot_rate.current_rate');         

    /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
    CALL getSequence('ORDERS.ORDER_NUM',    NULL,   3000, 'createBuyOrder', v_order_number);
    CALL getSequence('ORDERS.RECEIPT_NUM', 'RECP-', 3000, 'createBuyOrder', v_receipt_number);

    /* ===================== Step 6: Set Common Order Header Values ===================== */
    SET v_order_date = NOW();
    SET v_order_status = 'Pending';
    SET v_next_action_required = 'approved';

    /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
    SET v_order_json        = getTemplate('orders');
    SET v_row_metadata      = getTemplate('row_metadata');

    SET v_row_metadata	    = JSON_SET( v_row_metadata,
                                        '$.status', 		v_order_status,  
                                        '$.created_at',		DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
                                           '$.created_by',    CONCAT(
                                                                        getJval(v_customer_json, 'first_name'), 
                                                                        ' ', 
                                                                        getJval(v_customer_json, 'last_name'),
                                                                        ' Customer Self-Service'
                                                                    )
                                      );

    /* ===================== Step 8: Populate Customer & Rate Info & top level fields ===================== */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.customer_info.customer_rec_id',          v_customer_rec_id,
                                '$.customer_info.customer_name',            CONCAT(getJval(v_customer_json, 'first_name'), ' ', getJval(v_customer_json, 'last_name')),
                                '$.customer_info.customer_account_number',  getJval(v_customer_json, 'main_account_number'),
                                '$.customer_info.customer_phone',           getJval(v_customer_json, 'phone'),
                                '$.customer_info.whatsapp',                 getJval(v_customer_json, 'whatsapp'),
                                '$.customer_info.customer_email',           getJval(v_customer_json, 'email'),
                                '$.customer_info.customer_address',         CAST(getJval(v_customer_json, 'residential_address') AS JSON),
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
                                '$.limit_or_market',                         v_order_sub_type,
                                '$.metal',                                  v_metal
                            );

    /* ===================== Step 9: Branch by product_type ===================== */
    IF v_product_type = 'SLICE' THEN

        /* Validate order_sub_type for SLICE */
        IF isFalsy(v_order_sub_type) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_sub_type is required for SLICE order');
        END IF;

        /* ---------------------------------------------------------------
           SLICE: validate item_code + item_weight (common to Market & Limit)
           --------------------------------------------------------------- */   /* added block start */
        IF isFalsy(getJval(pjReqObj, 'item_code')) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'item_code is required for SLICE order');
        END IF;

        IF isFalsy(getJval(pjReqObj, 'item_weight')) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'item_weight is required for SLICE order');
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '2',
                                        'message',      'Validation failed',
                                        'errors',        v_errors
                                        );
            LEAVE main_block;
        END IF;

        /* ---------------------------------------------------------------
           SLICE: lookup item_name + item_type from inventory table
           --------------------------------------------------------------- */
        SET v_item_code   = getJval(pjReqObj, 'item_code');
        SET v_item_weight = getJval(pjReqObj, 'item_weight');

        SELECT  inventory_json
        INTO    v_inventory_json
        FROM    inventory
        WHERE   item_code = v_item_code
        LIMIT   1;

        IF isFalsy(v_inventory_json) THEN
            SET psResObj = JSON_OBJECT(
                                        'status',       'error',
                                        'status_code',  '6',
                                        'message',      'Inventory item not found',
                                        'item_code',     v_item_code
                                        );
            LEAVE main_block;
        END IF;

        SET v_item_name        = getJval(v_inventory_json, 'item_name');
        SET v_item_type        = getJval(v_inventory_json, 'item_type');
        SET v_bought_price     = v_spot_rate * v_item_weight;

        /* ---------------------------------------------------------------
           SLICE: build the single-element buy_items array
           --------------------------------------------------------------- */
        SET v_buy_items_output = JSON_ARRAY(
                                            JSON_OBJECT(
                                                        'item_code',        v_item_code,
                                                        'item_name',        v_item_name,
                                                        'item_type',        v_item_type,
                                                        'item_quantity',    1,
                                                        'item_weight',      v_item_weight,
                                                        'bought_price',     v_bought_price
                                                    )
                                            );                                             

        /* ------- sub-branch: Market ------- */
        IF v_order_sub_type = 'Market' THEN
            IF isFalsy(getJval(pjReqObj, 'customer_request.amount')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for Market order');
            END IF;

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT(
                                            'status',           'error',
                                            'status_code',      '2',
                                            'message',          'Validation failed',
                                            'errors',           v_errors
                                        );
                LEAVE main_block;
            END IF;

            SET v_order_cat = 'DO';
            SET v_order_json = JSON_SET(v_order_json,
                                        '$.order_cat',                              v_order_cat,
                                        '$.buy_items',                              v_buy_items_output,             /* changed: was getJval(pjReqObj, 'buy_items') */
                                        '$.customer_request.amount',                getJval(pjReqObj, 'customer_request.amount'),
                                        '$.customer_request.payment_method',        v_cr_payment_method,            /* changed: was getJval(pjReqObj, 'payment_method') */
                                        '$.customer_request.date_of_purchase',      DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                    );

        /* ------- sub-branch: Limit ------- */
        ELSEIF v_order_sub_type = 'Limit' THEN
            /* Set default order_cat to GTC if not provided */
            IF isFalsy(v_order_cat) THEN
                SET v_order_cat = 'GTC';
            END IF;

            IF isFalsy(getJval(pjReqObj, 'customer_request.rate')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.rate is required for Limit order');
            END IF;

             IF isFalsy(getJval(pjReqObj, 'customer_request.amount')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for Limit order');
            END IF;

            IF isFalsy(getJval(pjReqObj, 'customer_request.weight')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for Limit order');
            END IF;

            IF isFalsy(getJval(pjReqObj, 'customer_request.Expiration_time')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.Expiration_time is required for Limit order');
            END IF;

            IF v_order_cat NOT IN ('GTC','IOC') THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_cat must be GTC or IOC for Limit order');
            END IF;

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT(
                                            'status',           'error',
                                            'status_code',      '2',
                                            'message',          'Validation failed',
                                            'errors',           v_errors
                                            );
                LEAVE main_block;
            END IF;

            /* Use customer's requested rate for Limit orders */
            SET v_cr_rate       = getJval(pjReqObj, 'customer_request.rate');
            SET v_cr_weight     = getJval(pjReqObj, 'customer_request.weight');

            SET v_bought_price  = v_cr_rate * v_cr_weight;

            /* Update the bought_price in the already-built array */
            SET v_buy_items_output = JSON_SET(v_buy_items_output, '$[0].bought_price', v_bought_price);

            SET v_order_json = JSON_SET(v_order_json,
                                        '$.order_cat',                                  v_order_cat,
                                        '$.buy_items',                                  v_buy_items_output,             
                                        '$.customer_request.rate',                      v_cr_rate,          
                                        '$.customer_request.weight',                    v_cr_weight,                    
                                        '$.customer_request.amount',                    getJval(pjReqObj, 'customer_request.amount'),
                                        '$.customer_request.Expiration_time',           getJval(pjReqObj, 'customer_request.Expiration_time'),
                                        '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'customer_request.is_partial_fill_allowed'),
                                        '$.customer_request.payment_method',            v_cr_payment_method,            /* changed: was getJval(pjReqObj, 'payment_method') */
                                        '$.customer_request.date_of_purchase',          DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                    );

        ELSE
            SET psResObj = JSON_OBJECT(
                                        'status',           'error',
                                        'status_code',      '5',
                                        'message',          'Unknown order_sub_type for SLICE. Must be Market or Limit'
                                );
            LEAVE main_block;
        END IF;

    ELSEIF v_product_type = 'PRODUCT' THEN  

        /* ---------------------------------------------------------------
           PRODUCT: validate buy_items array is present and non-empty
           --------------------------------------------------------------- */
        SET v_buy_items_input = getJval(pjReqObj, 'buy_items');

        IF isFalsy(v_buy_items_input) OR JSON_LENGTH(v_buy_items_input) = 0 THEN

            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'buy_items array is required and must not be empty for PRODUCT order');
            SET psResObj = JSON_OBJECT('status','error','status_code','2','message','Validation failed','errors',v_errors);
          
            LEAVE main_block;
        END IF;

        /* ---------------------------------------------------------------
           PRODUCT: loop : validate each item, lookup inventory,
                    calculate bought_price = spot_rate * item_quantity
           --------------------------------------------------------------- */
        SET v_items_count      = JSON_LENGTH(v_buy_items_input);
        SET v_loop_idx         = 0;
        SET v_buy_items_output = JSON_ARRAY();

        IF isFalsy(getJval(pjReqObj, 'customer_request.amount')) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for PRODUCT order');
        END IF;

        IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT(
                                            'status',       'error',
                                            'status_code',  '2',
                                            'message',      'Validation failed on buy_items',
                                            'errors',        v_errors
                                            );
                LEAVE main_block;
        END IF;

        WHILE v_loop_idx < v_items_count DO

        /* Extract current item from input array */
            SET v_single_item   = JSON_EXTRACT(v_buy_items_input, CONCAT('$[', v_loop_idx, ']'));
            SET v_item_code     = getJval(v_single_item, 'item_code');
            SET v_item_weight   = getJval(v_single_item, 'item_weight');
            SET v_item_quantity = getJval(v_single_item, 'item_quantity');

            /* Per-item field validation */
            IF isFalsy(v_item_code) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                    CONCAT('buy_items[', v_loop_idx, '].item_code is required'));
            END IF;

            IF isFalsy(v_item_weight) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                    CONCAT('buy_items[', v_loop_idx, '].item_weight is required'));
            END IF;

            IF isFalsy(v_item_quantity) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$',
                    CONCAT('buy_items[', v_loop_idx, '].item_quantity is required'));
            END IF;
            

            IF JSON_LENGTH(v_errors) > 0 THEN
                SET psResObj = JSON_OBJECT(
                                            'status',       'error',
                                            'status_code',  '2',
                                            'message',      'Validation failed on buy_items',
                                            'errors',        v_errors
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
                                            'item_code',     v_item_code,
                                            'item_index',    v_loop_idx
                                            );
                LEAVE main_block;
            END IF;

            SET v_item_name    = getJval(v_inventory_json, 'item_name');
            SET v_item_type    = getJval(v_inventory_json, 'item_type');

            /* bought_price = spot_rate * item_weight * item_quantity */
            SET v_bought_price          = v_spot_rate * v_item_weight * v_item_quantity;

            /* Append fully-populated item into output array */
            SET v_buy_items_output = JSON_ARRAY_APPEND( v_buy_items_output,
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

        /* ---------------------------------------------------------------
           PRODUCT: merge into order_json
           --------------------------------------------------------------- */
        SET v_order_cat = 'DO';
        SET v_order_json = JSON_SET(v_order_json,
                                    '$.order_cat',                          v_order_cat,
                                    '$.buy_items',                          v_buy_items_output,
                                    '$.customer_request.payment_method',    v_cr_payment_method,
                                    '$.customer_request.date_of_purchase',  DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ'),
                                    '$.customer_request.amount',            getJval(pjReqObj, 'customer_request.amount')
                                );

    ELSE
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '5',
                                    'message',          'Unknown product_type for Buy. Must be SLICE or PRODUCT'
                            );
        LEAVE main_block;
    END IF;


    /* ===================== Step 9.5: Calculate Order Summary ===================== */

    /* --- Calculate totals from buy_items array --- */
    SET v_items_count = JSON_LENGTH(v_buy_items_output);
    SET v_loop_idx = 0;

    WHILE v_loop_idx < v_items_count DO

        SET v_single_item = JSON_EXTRACT(v_buy_items_output, CONCAT('$[', v_loop_idx, ']'));
        
        SET v_total_buy_items   = v_total_buy_items + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_quantity')) AS UNSIGNED);
        SET v_total_buy_weight  = v_total_buy_weight + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_weight')) AS DECIMAL(20,6)) * CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_quantity')) AS DECIMAL(20,6));
        SET v_total_buy_amount  = v_total_buy_amount + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.bought_price')) AS DECIMAL(20,6));
    
        SET v_loop_idx = v_loop_idx + 1;

    END WHILE;

    /* --- Apply business logic for charges --- */
    
    /* Option 1: Flat fees from config/parameters */
    SET v_transaction_fee    = 100.00;  -- or getJval(pjReqObj, 'transaction_fee')
    SET v_processing_charges = 50.00;

    /* Option 2: Percentage-based (e.g., 2% making charges) */
    SET v_making_charges = v_total_buy_amount * 0.02;

    /* Option 3: Weight-based premium (e.g., 50 PKR per gram) */
    SET v_premium_charged = v_total_buy_weight * 50;

    /* Option 4: Tax calculation (e.g., 5% GST) */
    SET v_taxes = v_total_buy_amount * 0.05;

    /* Apply discounts if any */
    SET v_total_discounts = COALESCE(getJval(pjReqObj, 'discount_amount'), 0);

    /* --- Final total order amount --- */
    SET v_total_order_amount = v_total_buy_amount 
                                + v_making_charges 
                                + v_premium_charged 
                                + v_transaction_fee 
                                + v_processing_charges 
                                + v_taxes 
                                - v_total_discounts;

    /* --- Populate order_summary in order_json --- */
    SET v_order_json = JSON_SET(v_order_json,
                                '$.order_summary.total_buy_items',      v_total_buy_items,
                                '$.order_summary.total_buy_amount',     v_total_buy_amount,
                                '$.order_summary.total_buy_weight',     v_total_buy_weight,
                                '$.order_summary.items_total_amount',   v_total_buy_amount,
                                '$.order_summary.making_charges',       v_making_charges,
                                '$.order_summary.premium_charged',      v_premium_charged,
                                '$.order_summary.transaction_fee',      v_transaction_fee,
                                '$.order_summary.processing_charges',   v_processing_charges,
                                '$.order_summary.taxes',                v_taxes,
                                '$.order_summary.taxes_description',    'GST @ 5%',
                                '$.order_summary.total_discounts',      v_total_discounts,
                                '$.order_summary.total_order_amount',   v_total_order_amount
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
                limit_or_market         = v_order_sub_type,
                metal                   = v_metal,
                order_json              = v_order_json,
                row_metadata            = v_row_metadata;

        SET v_order_rec_id = LAST_INSERT_ID();

        SET v_order_json = JSON_SET(v_order_json, '$.order_rec_id', v_order_rec_id);

        UPDATE  orders
        SET     order_json   = v_order_json
        WHERE   order_rec_id = v_order_rec_id;
    

    /* ===================== Step 11: Build Transactions, Update Wallets, Call wallet_activity ============== */

    /*  11.1 : Read customer_wallets array  */
    SET v_wallets_arr   = getJval(v_customer_json, 'customer_wallets');
    SET v_wallet_count  = JSON_LENGTH(v_wallets_arr);

    SET v_metal_wallet_id  = NULL;
    SET v_cash_wallet_id   = NULL;
    SET v_wallet_loop_idx  = 0;

    WHILE v_wallet_loop_idx < v_wallet_count DO

        SET v_wallet_item        = JSON_EXTRACT(v_wallets_arr, CONCAT('$[', v_wallet_loop_idx, ']'));
        SET v_wallet_asset_code  = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.asset_code'));
        SET v_wallet_type        = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_type'));

        /* Match METAL wallet by asset_code (e.g. GLD matches v_asset_code) */
        IF v_wallet_asset_code = v_asset_code AND v_wallet_type = 'METAL' THEN
            SET v_metal_wallet_id           = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_id'));
            SET v_metal_balance_before      = COALESCE(JSON_EXTRACT(v_wallet_item, '$.wallet_balance'), 0);
        END IF;

        /* Match CASH wallet by wallet_type */
        IF v_wallet_type = 'CASH' THEN
            SET v_cash_wallet_id            = JSON_UNQUOTE(JSON_EXTRACT(v_wallet_item, '$.wallet_id'));
            SET v_cash_balance_before       = COALESCE(JSON_EXTRACT(v_wallet_item, '$.wallet_balance'), 0); 
        END IF;

        SET v_wallet_loop_idx = v_wallet_loop_idx + 1;

    END WHILE;

    /* ---- 11.2 : Guard - both wallets must exist ---- */
    IF isFalsy(v_metal_wallet_id) THEN
        SET psResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'status_code',  '7',
                                    'message',      'Metal wallet not found for asset_code',
                                    'asset_code',    v_asset_code
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

    /* ---- 11.3 : Calculate transaction amounts ---- */

    /* Metal credit = sum of item_weight * item_quantity across all buy_items */
    -- SET v_metal_txn_amount = 0;
    -- SET v_items_count      = JSON_LENGTH(getJval(v_order_json, 'buy_items'));
    -- SET v_loop_idx         = 0;

    -- WHILE v_loop_idx < v_items_count DO
    --     SET v_single_item = JSON_EXTRACT(getJval(v_order_json, 'buy_items'), CONCAT('$[', v_loop_idx, ']'));
    --     SET v_metal_txn_amount = v_metal_txn_amount
    --                              + CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_weight')) AS DECIMAL(20,6)) * CAST(JSON_UNQUOTE(JSON_EXTRACT(v_single_item, '$.item_quantity')) AS DECIMAL(20,6));
    --     SET v_loop_idx = v_loop_idx + 1;
    -- END WHILE;

    /* Metal credit = already calculated in order summary */
    SET v_metal_txn_amount = v_total_buy_weight;

    /* Cash debit = total_order_amount from order_summary */
    SET v_cash_txn_amount    = v_total_order_amount;

    /* ---- 11.4 : Calculate balances after ---- */
    SET v_metal_balance_after = v_metal_balance_before + v_metal_txn_amount;
    SET v_cash_balance_after  = v_cash_balance_before  - v_cash_txn_amount;

    /* ---- 11.4b : Guard - insufficient cash balance ---- */
    IF v_cash_balance_after < 0 THEN
        SET psResObj = JSON_OBJECT(
                                    'status',           'error',
                                    'status_code',      '9',
                                    'message',          'Insufficient cash balance',
                                    'cash_balance',     v_cash_balance_before,
                                    'required_amount',  v_cash_txn_amount
                                );
        LEAVE main_block;
    END IF;

    /* ---- 11.5 : Generate transaction number (one shared num for both legs) ---- */
    CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createBuyOrder', v_txn_num);

    /* ---- 11.6 : Build transactions array ---- */
    SET v_transactions_output = JSON_ARRAY(

        /* TXN-A : Metal CREDIT */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num,
                    'transaction_type',     'Credit',
                    'wallet_type',          'Metal',
                    "asset_code",           v_asset_code,
                    'wallet_id',            v_metal_wallet_id,
                    'balance_before',       v_metal_balance_before,
                    'transaction_amount',   v_metal_txn_amount,
                    'balance_after',        v_metal_balance_after
                ),

        /* TXN-B : Cash DEBIT */
        JSON_OBJECT(
                    'transaction_num',      v_txn_num,
                    'transaction_type',     'Debit',
                    'wallet_type',          'Cash',
                    "asset_code",           'CSH',
                    'wallet_id',            v_cash_wallet_id,
                    'balance_before',       v_cash_balance_before,
                    'transaction_amount',   v_cash_txn_amount,
                    'balance_after',        v_cash_balance_after
                )
    );

    /* ---- 11.7 : Write transactions into order_json and persist ---- */
    SET v_order_json = JSON_SET(v_order_json, '$.transactions', v_transactions_output);

    UPDATE  orders
    SET     order_json   = v_order_json
    WHERE   order_rec_id = v_order_rec_id;

    /* ---- 11.8 : Call wallet_activity - METAL CREDIT ---- */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_metal_wallet_id,
                            'CREDIT',
                            v_metal_txn_amount,
                            CONCAT('Buy order credited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num
                        );

    /* ---- 11.9 : Call wallet_activity - CASH DEBIT ---- */
    CALL wallet_activity(
                            v_customer_rec_id,
                            v_cash_wallet_id,
                            'DEBIT',
                            v_cash_txn_amount,
                            CONCAT('Buy order debited: ', v_order_number),
                            v_order_rec_id,
                            v_order_number,
                            v_txn_num
                        );


    /* ===================== Step 12: Success Response ===================== */
    SET psResObj = JSON_OBJECT(
                                'status',           'success',
                                'status_code',      '0',
                                'message',          'Buy order inserted successfully',
                                'order_rec_id',     v_order_rec_id,
                                'order_number',     v_order_number
                            );
    END main_block;



END$$
DELIMITER ;