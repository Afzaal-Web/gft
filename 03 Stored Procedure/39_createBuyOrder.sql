-- ==================================================================================================
-- Procedure: 					createBuyOrder
-- Purpose:   					Creates a new buy order for a customer. Handles SLICE and PRODUCT orders
--								with Market and Limit order subtypes. Validates customer, inventory,
--								rates, and wallet availability. Manages wallet transactions (metal 
--								credit and cash debit). Generates order, receipt, and transaction numbers.
--								Supports multiple items for PRODUCT orders and single item for SLICE.
--
-- Functions used in this Procedure:
								-- isFalsy(): 					Validate the values come from reqObj
								-- getJval(): 					Get value of JSON object using dot notation
								-- getTemplate(): 				Get template of JSON column used in tables
								-- getCustomer():				Retrieve customer information from database
								-- getSequence():				Generate sequence numbers for order/receipt/transaction
								-- wallet_activity():			Create wallet activity records for transactions
-- ===================================================================================================
    


    DROP PROCEDURE IF EXISTS createBuyOrder;

    DELIMITER $$
    CREATE PROCEDURE createBuyOrder(
                                        IN      pjReqObj    JSON,
                                        INOUT  pjRespObj    JSON
                                    )
    BEGIN

    
        /* ===================== Variables ===================== */
        DECLARE vThisObj                    VARCHAR(32)               DEFAULT 'createBuyOrder';
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
        DECLARE v_cr_rate                   DECIMAL(20,6);  
        DECLARE v_cr_weight                 DECIMAL(20,6);       

        DECLARE v_tradable_assets_rec_id    INT;
        DECLARE v_rate_json                 JSON;
        DECLARE v_spot_rate                 DECIMAL(20,6);      

        DECLARE v_customer_json             JSON;
        DECLARE v_order_json                JSON;
        DECLARE v_row_metadata              JSON;

        /*  buy_items variables (shared by SLICE and PRODUCT)  */
        DECLARE v_inventory_json            JSON;
        DECLARE v_item_code                 VARCHAR(50);
        DECLARE v_item_name                 VARCHAR(100);
        DECLARE v_item_type                 VARCHAR(50);
        DECLARE v_item_weight               DECIMAL(20,6);
        DECLARE v_item_quantity             INT;
        DECLARE v_bought_price              DECIMAL(20,6);
        DECLARE v_buy_items_output          JSON;
        DECLARE v_customer_products_json    JSON            DEFAULT JSON_ARRAY();

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
    
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 	 CONCAT('Insertion failed: ', v_err_msg));

        END;

    main_block: BEGIN
        /* ===================== Step 1: Extract Request Values ===================== */
        SET v_order_type            = 'Buy';
        SET v_account_number        = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');
        SET v_order_sub_type        = getJval(pjReqObj, 'jData.P_ORDER_SUB_TYPE');
        SET v_order_cat             = getJval(pjReqObj, 'jData.P_ORDER_CAT');
        SET v_metal                 = getJval(pjReqObj, 'jData.P_METAL');
        SET v_product_type          = getJval(pjReqObj, 'jData.P_PRODUCT_TYPE');
        SET v_cr_payment_method     = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_PAYMENT_METHOD');

        /* For PRODUCT, order_sub_type is not applicable */
        IF v_product_type = 'PRODUCT' THEN
            SET v_order_sub_type = NULL;
        END IF;

        /* ===================== Step 2: Common Validations ===================== */
        IF isFalsy(v_account_number) THEN
            SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
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
        
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'Validation failed: ');
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);

            LEAVE main_block;
        END IF;

        /* ===================== Step 3: Fetch Customer Record ===================== */
        SELECT  customer_rec_id 
        INTO    v_customer_rec_id
        FROM    customer
        WHERE   account_num = v_account_number
        LIMIT 1;

        -- check if customer record exists for the provided account_number
        IF isFalsy(v_customer_rec_id) THEN
            
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer not found');

            LEAVE main_block;
        END IF;

        SET v_customer_json = getCustomer(v_customer_rec_id);

        IF isFalsy(v_customer_json) THEN
           
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Customer not found for account number: ', v_account_number));
            
            LEAVE main_block;
            
        END IF;      

        /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
        CALL getSequence('ORDERS.ORDER_NUM',    NULL,   3000, 'createBuyOrder', v_order_number);
        CALL getSequence('ORDERS.RECEIPT_NUM', 'RECP-', 3000, 'createBuyOrder', v_receipt_number);

        /* ===================== Step 6: Set Common Order Header Values ===================== */
        SET v_order_date                = NOW();
        SET v_order_status              = 'pending';
        SET v_next_action_required      = 'approval';

        /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
        SET v_row_metadata      = getTemplate('row_metadata');
        SET v_order_json        = getTemplate('orders');
        
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
                                    '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'jData.P_CUSTOMER_IP_ADDRESS'),
                                    '$.customer_info.latitude',                 getJval(pjReqObj, 'jData.P_LATITUDE'),
                                    '$.customer_info.longitude',                getJval(pjReqObj, 'jData.P_LONGITUDE'),
                                    '$.customer_info.notes',                    getJval(pjReqObj, 'jData.P_NOTES'),

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

            SET v_item_code         = getJval(pjReqObj, 'jData.P_ITEM_CODE');

            /* Validate order_sub_type for SLICE */
            IF isFalsy(v_order_sub_type) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_sub_type is required for SLICE order');
            END IF;

            /* ---------------------------------------------------------------
            SLICE: validate item_code + customer_request.weight (common to Market & Limit)
            --------------------------------------------------------------- */  
            IF isFalsy(v_item_code) THEN
                SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'item_code is required for SLICE order');
            END IF;


            IF JSON_LENGTH(v_errors) > 0 THEN
                
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Validation failed: ');
                SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);

                LEAVE main_block;
            END IF;

            /* ---------------------------------------------------------------
            SLICE: lookup item_name + item_type from inventory table
            --------------------------------------------------------------- */

            SELECT  inventory_json
            INTO    v_inventory_json
            FROM    inventory
            WHERE   item_code = v_item_code
            LIMIT   1;

            IF isFalsy(v_inventory_json) THEN
                
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Inventory item not found for item code: ', v_item_code));
                
                LEAVE main_block;
            END IF;

            SET v_item_weight      = getJval(pjReqObj,          'jData.P_ITEM_WEIGHT');
            SET v_item_name        = getJval(v_inventory_json,  'item_name');
            SET v_item_type        = getJval(v_inventory_json,  'item_type');
            SET v_asset_code       = getJval(v_inventory_json,  'asset_code');  

                    /* ===================== Fetch Latest Rate for Asset rate history ===================== */
            SELECT   tradable_assets_rec_id,      tradable_assets_json
            INTO     v_tradable_assets_rec_id,    v_rate_json
            FROM     tradable_assets
            WHERE    asset_code = v_asset_code
            ORDER BY tradable_assets_rec_id DESC
            LIMIT 1;
            
            IF isFalsy(v_rate_json) THEN
                
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Rate not found for asset_code: ', v_asset_code));
               
                LEAVE main_block;
            END IF;

              /* Extract spot_rate once - reused in buy_items price calculation */    
            SET v_spot_rate = getJval(v_rate_json, 'spot_rate.current_rate');  

            /*  Populate rate_info in order_json Now we have the rate  */
            SET v_order_json = JSON_SET(v_order_json,
                                        '$.rate_info.rate_rec_id',              v_tradable_assets_rec_id,
                                        '$.rate_info.spot_rate',                v_spot_rate,
                                        '$.rate_info.currency_unit',            getJval(v_rate_json, 'spot_rate.currency'),
                                        '$.rate_info.rate_source',              getJval(v_rate_json, 'spot_rate.url'),
                                        '$.rate_info.foreign_exchange_rate',    getJval(v_rate_json, 'spot_rate.foreign_exchange_rate'),
                                        '$.rate_info.foreign_exchange_source',  getJval(v_rate_json, 'spot_rate.foreign_exchange_source')
                                    );

            /* ---------------------------------------------------------------
            SLICE: build the single-element buy_items array
            --------------------------------------------------------------- */
            SET v_buy_items_output = JSON_ARRAY(
                                                JSON_OBJECT(
                                                            'asset_code',       v_asset_code,
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


                IF isFalsy(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_AMOUNT')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for Market order');
                END IF;

                

                IF isFalsy(getJval(pjReqObj, 'jData.P_ITEM_WEIGHT')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'item_weight is required for Market order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Validation failed');
                    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);

                    LEAVE main_block;
                END IF; 

                SET v_bought_price     = v_spot_rate * v_item_weight;
                
                SET v_buy_items_output = JSON_SET(v_buy_items_output, 
                                                '$[0].bought_price', v_bought_price
                                                );

                SET v_order_cat = 'DO';
                SET v_order_json = JSON_SET(v_order_json,
                                            '$.order_cat',                              v_order_cat,
                                            '$.buy_items',                              v_buy_items_output,            
                                            '$.customer_request.amount',                getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_AMOUNT'),
                                            '$.customer_request.payment_method',        v_cr_payment_method,            
                                            '$.customer_request.date_of_purchase',      DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                        );

            /* ------- sub-branch: Limit ------- */
            ELSEIF v_order_sub_type = 'Limit' THEN
                /* Set default order_cat to GTC if not provided */
                IF isFalsy(v_order_cat) THEN
                    SET v_order_cat = 'GTC';
                END IF;

                IF isFalsy(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_RATE')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.rate is required for Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_AMOUNT')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.amount is required for Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_WEIGHT')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.weight is required for Limit order');
                END IF;

                IF isFalsy(getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_EXPIRATION_TIME')) THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.Expiration_time is required for Limit order');
                END IF;

                IF v_order_cat NOT IN ('GTC','IOC') THEN
                    SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'order_cat must be GTC or IOC for Limit order');
                END IF;

                IF JSON_LENGTH(v_errors) > 0 THEN
                    
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Validation failed');
                    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);
                    
                    LEAVE main_block;
                END IF;

                /* Use customer's requested rate for Limit orders */
                SET v_cr_rate       = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_RATE');
                SET v_cr_weight     = getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_WEIGHT');

                SET v_bought_price  = v_cr_rate * v_cr_weight;

                -- update rate_info after setting v_cr_rate in Limit branch
                SET v_order_json = JSON_SET(v_order_json,
                    '$.rate_info.customer_requested_rate', v_cr_rate
                );

                /* Update the bought_price in the already-built array */
                SET v_buy_items_output = JSON_SET(v_buy_items_output, 
                                                '$[0].bought_price', v_bought_price,
                                                '$[0].item_weight',  v_cr_weight 
                                                );
                

                SET v_order_json = JSON_SET(v_order_json,
                                            '$.order_cat',                                  v_order_cat,
                                            '$.buy_items',                                  v_buy_items_output,             
                                            '$.customer_request.rate',                      v_cr_rate,          
                                            '$.customer_request.weight',                    v_cr_weight,                    
                                            '$.customer_request.amount',                    getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_AMOUNT'),
                                            '$.customer_request.Expiration_time',           getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_EXPIRATION_TIME'),
                                            '$.customer_request.is_partial_fill_allowed',   getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_IS_PARTIAL_FILL_ALLOWED'),
                                            '$.customer_request.payment_method',            v_cr_payment_method,            
                                            '$.customer_request.date_of_purchase',          DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ')
                                        );

            ELSE

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Unknown order_sub_type for SLICE. Must be Market or Limit');
                LEAVE main_block;
            END IF;

        ELSEIF v_product_type = 'PRODUCT' THEN  

            /* ---------------------------------------------------------------
            PRODUCT: validate buy_items array is present and non-empty
            --------------------------------------------------------------- */
            SET v_buy_items_input = getJval(pjReqObj, 'jData.P_BUY_ITEMS');

            IF isFalsy(v_buy_items_input) OR JSON_LENGTH(v_buy_items_input) = 0 THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'buy_items array is required and must not be empty for PRODUCT order');
            
                LEAVE main_block;
            END IF;

            /* ---------------------------------------------------------------
            PRODUCT: loop : validate each item, lookup inventory,
                        calculate bought_price = spot_rate * item_quantity
            --------------------------------------------------------------- */
            SET v_items_count      = JSON_LENGTH(v_buy_items_input);
            SET v_loop_idx         = 0;
            SET v_buy_items_output = JSON_ARRAY();

            IF JSON_LENGTH(v_errors) > 0 THEN
                   
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Validation failed on buy_items');
                    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);
                    LEAVE main_block;
            END IF;

            WHILE v_loop_idx < v_items_count DO

            /* Extract current item from input array */
                SET v_single_item   = JSON_EXTRACT(v_buy_items_input, CONCAT('$[', v_loop_idx, ']'));
                SET v_item_code     = getJval(v_single_item, 'P_ITEM_CODE');
                SET v_item_weight   = getJval(v_single_item, 'P_ITEM_WEIGHT');
                SET v_item_quantity = getJval(v_single_item, 'P_ITEM_QUANTITY');

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
                    
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Validation failed on buy_items');
                    SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.errors', v_errors);

                    LEAVE main_block;
                END IF;

                /* Lookup item_name + item_type from inventory */

                SELECT  inventory_json
                INTO    v_inventory_json
                FROM    inventory
                WHERE   item_code = v_item_code
                LIMIT   1;

                IF isFalsy(v_inventory_json) THEN
                    
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Inventory item not found for item_code: ', v_item_code));
                    
                    LEAVE main_block;
                END IF;

                SET v_item_name    = getJval(v_inventory_json, 'item_name');
                SET v_item_type    = getJval(v_inventory_json, 'item_type');
                SET v_asset_code   = getJval(v_inventory_json, 'asset_code');

            /*  Fetch spot_rate per item based on its own asset_code */
                SELECT   tradable_assets_rec_id,   tradable_assets_json
                INTO     v_tradable_assets_rec_id, v_rate_json
                FROM     tradable_assets
                WHERE    asset_code = v_asset_code
                ORDER BY tradable_assets_rec_id DESC
                LIMIT 1;

                 IF isFalsy(v_rate_json) THEN
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Rate not found for asset_code: ', v_asset_code));
                    LEAVE main_block;
                END IF;

                SET v_spot_rate             = getJval(v_rate_json, 'spot_rate.current_rate');

                /* bought_price = spot_rate * item_weight * item_quantity */
                SET v_bought_price          = v_spot_rate * v_item_weight * v_item_quantity;

                /* Append fully-populated item into output array */
                SET v_buy_items_output = JSON_ARRAY_APPEND( v_buy_items_output,
                                                            '$',
                                                            JSON_OBJECT(
                                                                        'asset_code',       v_asset_code,
                                                                        'item_code',        v_item_code,
                                                                        'item_name',        v_item_name,
                                                                        'item_type',        v_item_type,
                                                                        'item_quantity',    v_item_quantity,
                                                                        'item_weight',      v_item_weight,
                                                                        'spot_rate',        v_spot_rate,
                                                                        'bought_price',     v_bought_price
                                                                        )
                                                        );

                SET v_loop_idx = v_loop_idx + 1;

            END WHILE;

            /*Store a note at order level instead */
            SET v_order_json = JSON_SET(v_order_json,
                                        '$.rate_info',  'See individual buy_items for per-item rate details'
                                        );
            /* ---------------------------------------------------------------
            PRODUCT: merge into order_json
            --------------------------------------------------------------- */
            SET v_order_cat = 'DO';
            SET v_order_json = JSON_SET(v_order_json,
                                        '$.order_cat',                          v_order_cat,
                                        '$.buy_items',                          v_buy_items_output,
                                        '$.customer_request.payment_method',    v_cr_payment_method,
                                        '$.customer_request.date_of_purchase',  DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ'),
                                        '$.customer_request.amount',            getJval(pjReqObj, 'jData.P_CUSTOMER_REQUEST.P_AMOUNT')
                                    );

        ELSE
           
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Unknown product_type for Buy. Must be SLICE or PRODUCT');
            LEAVE main_block;
        END IF;


        /* ===================== Step 9.5: Calculate Order Summary ===================== */

        /* --- Calculate totals from buy_items array --- */
        SET v_items_count = JSON_LENGTH(v_buy_items_output);
        SET v_loop_idx = 0;

        WHILE v_loop_idx < v_items_count DO

            SET v_single_item       = JSON_EXTRACT(v_buy_items_output, CONCAT('$[', v_loop_idx, ']'));
            
            SET v_total_buy_items   = v_total_buy_items +  CAST(getJval(v_single_item, 'item_quantity') AS UNSIGNED);
            SET v_total_buy_weight  = v_total_buy_weight + CAST(getJval(v_single_item, 'item_weight')   AS DECIMAL(20,6)) * CAST(getJval(v_single_item, 'item_quantity') AS DECIMAL(20,6));
            SET v_total_buy_amount  = v_total_buy_amount + CAST(getJval(v_single_item, 'bought_price')  AS DECIMAL(20,6));
        
            SET v_loop_idx = v_loop_idx + 1;

        END WHILE;

        /* --- Apply business logic for charges --- */
        
        /* Option 1: Flat fees from config/parameters */
        SET v_transaction_fee    = 100.00;  -- or getJval(pjReqObj, 'jData.P_TRANSACTION_FEE')
        SET v_processing_charges = 50.00;

        /* Option 2: Percentage-based (e.g., 2% making charges) */
        SET v_making_charges = v_total_buy_amount * 0.02;

        /* Option 3: Weight-based premium (e.g., 50 PKR per gram) */
        SET v_premium_charged = v_total_buy_weight * 50;

        /* Option 4: Tax calculation (e.g., 5% GST) */
        SET v_taxes = v_total_buy_amount * 0.05;

        /* Apply discounts if any */
        SET v_total_discounts = COALESCE(getJval(pjReqObj, 'jData.P_DISCOUNT_AMOUNT'), 0);

        /* --- Final total order amount --- */
        SET v_total_order_amount = v_total_buy_amount 
                                    + v_making_charges 
                                    + v_premium_charged 
                                    + v_transaction_fee 
                                    + v_processing_charges 
                                    + v_taxes 
                                    - v_total_discounts;

        /* Now validate */
        IF v_total_order_amount < 0 THEN
            
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Net Buy amount cannot be negative');
            LEAVE main_block;
        END IF;  
        /* --- Populate order_summary in order_json --- */
        SET v_order_json = JSON_SET(v_order_json,
                                    '$.customer_request.total_qty_to_buy',  v_total_buy_items,
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

        /* ===================== Step 11: Build Transactions, Update Wallets, Call wallet_activity ============== */

        /*  11.1 : Read customer_wallets array  */
        SET v_wallets_arr   = getJval(v_customer_json, 'customer_wallets');

        IF v_wallets_arr IS NULL OR JSON_LENGTH(v_wallets_arr) = 0 THEN
           
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer wallets not found');
            LEAVE main_block;
        END IF;

        SET v_wallet_count  = JSON_LENGTH(v_wallets_arr);

        SET v_metal_wallet_id  = NULL;
        SET v_cash_wallet_id   = NULL;
        SET v_wallet_loop_idx  = 0;

        WHILE v_wallet_loop_idx < v_wallet_count DO

            SET v_wallet_item        = JSON_EXTRACT(v_wallets_arr, CONCAT('$[', v_wallet_loop_idx, ']'));
            SET v_wallet_asset_code  = getJval(v_wallet_item, 'asset_code');
            SET v_wallet_type        = getJval(v_wallet_item, 'wallet_type');

            /* Match METAL wallet by asset_code (e.g. GLD matches v_asset_code) */
            IF v_wallet_asset_code = v_asset_code AND v_wallet_type = 'METAL' THEN
                SET v_metal_wallet_id          = getJval(v_wallet_item, 'wallet_id');
                SET v_metal_balance_before     = COALESCE( CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);
            END IF;

            /* Match CASH wallet by wallet_type */
            IF v_wallet_type = 'CASH' THEN
                SET v_cash_wallet_id            = getJval(v_wallet_item, 'wallet_id');
                SET v_cash_balance_before       = COALESCE(CAST(getJval(v_wallet_item, 'wallet_balance') AS DECIMAL(20,6)), 0);
            END IF;

            SET v_wallet_loop_idx               = v_wallet_loop_idx + 1;

        END WHILE;

        /* ---- 11.2 : Guard - wallets must exist ---- */
        IF v_product_type != 'PRODUCT' AND isFalsy(v_metal_wallet_id) THEN
            
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Metal wallet not found for asset_code', ' ', v_asset_code));

            LEAVE main_block;
        END IF;

        IF isFalsy(v_cash_wallet_id) THEN
            
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Cash wallet not found for customer', ' ', v_account_number));
            
            LEAVE main_block;
        END IF;

        /* ---- 11.3 : Calculate transaction amounts ---- */

        /* Metal credit = already calculated in order summary (only for SLICE) */
        IF v_product_type != 'PRODUCT' THEN
            SET v_metal_txn_amount = v_total_buy_weight;
        ELSE
            SET v_metal_txn_amount = 0;
        END IF;

        /* Cash debit = total_order_amount from order_summary */
        SET v_cash_txn_amount    = v_total_order_amount;

        /* ---- 11.4 : Calculate balances after ---- */
        IF v_product_type != 'PRODUCT' THEN
            SET v_metal_balance_after = v_metal_balance_before + v_metal_txn_amount;
        END IF;
        SET v_cash_balance_after  = v_cash_balance_before  - v_cash_txn_amount;

        /* ---- 11.4b : Guard - insufficient cash balance ---- */
        IF v_cash_balance_after < 0 THEN
           
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Insufficient cash balance', ' ','balance: ', v_cash_balance_before, ', transaction amount: ', v_cash_txn_amount));
            LEAVE main_block;
        END IF;

        /* ---- 11.5 : Generate transaction numbers for each leg ---- */
        CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createBuyOrder', v_txn_num_credit);
        CALL getSequence('ORDERS.TXN_NUM', 'TXN-', 5000, 'createBuyOrder', v_txn_num_debit);

        /* ---- 11.6 : Build transactions array ---- */
        IF v_product_type = 'PRODUCT' THEN
            SET v_transactions_output = JSON_ARRAY(
                /* TXN-B : Cash DEBIT */
                JSON_OBJECT(
                            'transaction_num',      v_txn_num_debit,
                            'transaction_type',     'Debit',
                            'wallet_type',          'Cash',
                            "asset_code",           'CSH',
                            'wallet_id',            v_cash_wallet_id,
                            'balance_before',       v_cash_balance_before,
                            'transaction_amount',   v_cash_txn_amount,
                            'balance_after',        v_cash_balance_after
                        )
            );
        ELSE
            SET v_transactions_output = JSON_ARRAY(
                /* TXN-A : Metal CREDIT */
                JSON_OBJECT(
                            'transaction_num',      v_txn_num_credit,
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
                            'transaction_num',      v_txn_num_debit,
                            'transaction_type',     'Debit',
                            'wallet_type',          'Cash',
                            "asset_code",           'CSH',
                            'wallet_id',            v_cash_wallet_id,
                            'balance_before',       v_cash_balance_before,
                            'transaction_amount',   v_cash_txn_amount,
                            'balance_after',        v_cash_balance_after
                        )
            );
        END IF;

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

            /* ---- 11.7 : Write transactions into order_json and persist ---- */
            SET v_order_json = JSON_SET(v_order_json, '$.transactions', v_transactions_output);

            UPDATE  orders
            SET     order_json   = v_order_json
            WHERE   order_rec_id = v_order_rec_id;

        /* ---- 11.8 : Call wallet_activity - METAL CREDIT (only for SLICE) ---- */
        IF v_product_type != 'PRODUCT' THEN
            CALL wallet_activity(
                                    v_customer_rec_id,
                                    v_metal_wallet_id,
                                    'CREDIT',
                                    v_metal_txn_amount,
                                    CONCAT('Buy order credited: ', v_order_number),
                                    v_order_rec_id,
                                    v_order_number,
                                    v_txn_num_credit
                                );
        END IF;

        /* ---- 11.9 : Call wallet_activity - CASH DEBIT ---- */
        CALL wallet_activity(
                                v_customer_rec_id,
                                v_cash_wallet_id,
                                'DEBIT',
                                v_cash_txn_amount,
                                CONCAT('Buy order debited: ', v_order_number),
                                v_order_rec_id,
                                v_order_number,
                                v_txn_num_debit
                                );

        /* ---- 11.10 : Update customer_products for PRODUCT orders ---- */
        IF v_product_type = 'PRODUCT' THEN

            -- Loop through buy_items and append to customer_products
            SET v_items_count = JSON_LENGTH(v_buy_items_output);
            SET v_loop_idx = 0;
            
            WHILE v_loop_idx < v_items_count DO

                SET v_single_item             = JSON_EXTRACT(v_buy_items_output, CONCAT('$[', v_loop_idx, ']'));

                SET v_customer_products_json  = JSON_ARRAY_APPEND(v_customer_products_json, '$', 
                                                                JSON_OBJECT(
                                                                                'asset_code',           getJVal(v_single_item, 'asset_code'),
                                                                                'product_name',         getJVal(v_single_item, 'item_name'),
                                                                                'product_type',         getJVal(v_single_item, 'item_type'),
                                                                                'product_price',        getJVal(v_single_item, 'bought_price'),
                                                                                'product_weight',       getJVal(v_single_item, 'item_weight'),
                                                                                'status',               'Not Picked up',
                                                                                'product_quantity',     getJVal(v_single_item, 'item_quantity'),
                                                                                'order_rec_id',         v_order_rec_id,
                                                                                'customer_rec_id',      v_customer_rec_id,
                                                                                'purchase_date',        DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ'),
                                                                                'item_code',            getJval(v_single_item, 'item_code')
                                                                            )
                                                                );

                    SET v_loop_idx = v_loop_idx + 1;

            END WHILE;

        INSERT INTO customer_products
        SET customer_rec_id         = v_customer_rec_id,
            order_rec_id            = v_order_rec_id,
            order_type              = v_order_type,
            status                  = 'Not Picked up',
            customer_products_json  = v_customer_products_json,
            row_metadata            = v_row_metadata;
        END IF;

        /* ===================== Step 12: Success Response ===================== */
 
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 	0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',    CONCAT('Buy order created successfully for order number: ', v_order_number));

        END main_block;



    END$$
    DELIMITER ;
