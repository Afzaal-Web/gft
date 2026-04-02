DROP PROCEDURE IF EXISTS createExchangeOrder;
DELIMITER $$
CREATE PROCEDURE createExchangeOrder(
    IN pjReqObj JSON,
    OUT psResObj JSON
)
BEGIN
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

    DECLARE v_exchange_from_metal       VARCHAR(50);
    DECLARE v_exchange_to_metal         VARCHAR(50);
    DECLARE v_exchange_from_asset_code  VARCHAR(10);
    DECLARE v_exchange_to_asset_code    VARCHAR(10);
    DECLARE v_exchange_weight           VARCHAR(20);

    DECLARE v_from_asset_rate_rec_id    INT;
    DECLARE v_from_rate_json            JSON;
    DECLARE v_to_asset_rate_rec_id      INT;
    DECLARE v_to_rate_json              JSON;

    DECLARE v_customer_json             JSON;
    DECLARE v_order_json                JSON;
    DECLARE v_row_metadata              JSON;
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

    /* ===================== Step 1: Extract Request Values ===================== */
    SET v_order_type = 'Exchange';
    SET v_account_number = getJval(pjReqObj, 'account_number');
    SET v_order_sub_type = getJval(pjReqObj, 'order_sub_type');
    SET v_metal = getJval(pjReqObj, 'metal');
    SET v_exchange_from_metal = getJval(pjReqObj, 'exchange.from.metal');
    SET v_exchange_to_metal = getJval(pjReqObj, 'exchange.to.metal');
    SET v_exchange_from_asset_code = getJval(pjReqObj, 'exchange.from.asset_code');
    SET v_exchange_to_asset_code = getJval(pjReqObj, 'exchange.to.asset_code');
    SET v_exchange_weight = getJval(pjReqObj, 'exchange.weight');
    SET v_cr_payment_method = getJval(pjReqObj, 'customer_request.payment_method');
    SET v_cr_date_of_purchase = NOW();

    /* ===================== Step 2: Exchange Validations ===================== */
    IF isFalsy(v_account_number) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'account_number is required');
    END IF;
    IF isFalsy(v_exchange_from_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.from.asset_code is required');
    END IF;
    IF isFalsy(v_exchange_to_asset_code) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.to.asset_code is required');
    END IF;
    IF isFalsy(v_exchange_from_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.from.metal is required');
    END IF;
    IF isFalsy(v_exchange_to_metal) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.to.metal is required');
    END IF;
    IF isFalsy(v_exchange_weight) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'exchange.weight is required');
    END IF;
    IF isFalsy(v_cr_payment_method) THEN
        SET v_errors = JSON_ARRAY_APPEND(v_errors, '$', 'customer_request.payment_method is required');
    END IF;

    IF JSON_LENGTH(v_errors) > 0 THEN
        SET psResObj = JSON_OBJECT('status','error','status_code','2','message','Validation failed','errors',v_errors);
        LEAVE;
    END IF;

    /* ===================== Step 3: Fetch Customer Record ===================== */
    SELECT customer_rec_id INTO v_customer_rec_id
    FROM customers
    WHERE account_number = v_account_number;

    CALL getCustomer(v_customer_rec_id, v_customer_json);
    IF isFalsy(v_customer_json) THEN
        SET psResObj = JSON_OBJECT('status','error','status_code','3','message','Customer not found','customer_rec_id',v_customer_rec_id);
        LEAVE;
    END IF;

    SELECT asset_rate_rec_id, asset_rate_history_json
    INTO v_from_asset_rate_rec_id, v_from_rate_json
    FROM asset_rate_history
    WHERE asset_code = v_exchange_from_asset_code
    ORDER BY rate_timestamp DESC
    LIMIT 1;
    IF isFalsy(v_from_rate_json) THEN
        SET psResObj = JSON_OBJECT('status','error','status_code','4','message','Rate not found for exchange.from.asset_code','asset_code',v_exchange_from_asset_code);
        LEAVE;
    END IF;

    SELECT asset_rate_rec_id, asset_rate_history_json
    INTO v_to_asset_rate_rec_id, v_to_rate_json
    FROM asset_rate_history
    WHERE asset_code = v_exchange_to_asset_code
    ORDER BY rate_timestamp DESC
    LIMIT 1;
    IF isFalsy(v_to_rate_json) THEN
        SET psResObj = JSON_OBJECT('status','error','status_code','4','message','Rate not found for exchange.to.asset_code','asset_code',v_exchange_to_asset_code);
        LEAVE;
    END IF;

    /* ===================== Step 5: Generate Order & Receipt Numbers ===================== */
    CALL getSequence('ORDER.ORDER_NUM', NULL, NULL, 'createExchangeOrder', v_order_number);
    CALL getSequence('ORDER.RECEIPT_NUM', NULL, NULL, 'createExchangeOrder', v_receipt_number);

    /* ===================== Step 6: Set Common Order Header Values ===================== */
    SET v_order_date = NOW();
    SET v_order_status = 'Pending';
    SET v_next_action_required = 'Approval';
    SET v_order_cat = 'DO';

    /* ===================== Step 7: Load Order Template & Row Metadata ===================== */
    SET v_order_json = getTemplate('orders');
    SET v_row_metadata = getTemplate('row_metadata');

    /* ===================== Step 8: Populate Customer Info & Exchange Details ===================== */
    SET v_order_json = JSON_SET(v_order_json,
        '$.customer_info.customer_rec_id',          v_customer_rec_id,
        '$.customer_info.customer_name',            getJval(v_customer_json, 'first_name') + ' ' + getJval(v_customer_json, 'last_name'),
        '$.customer_info.customer_account_number',  getJval(v_customer_json, 'main_account_number'),
        '$.customer_info.customer_phone',           getJval(v_customer_json, 'phone'),
        '$.customer_info.whatsapp',                 getJval(v_customer_json, 'whatsapp'),
        '$.customer_info.customer_email',           getJval(v_customer_json, 'email'),
        '$.customer_info.customer_address',         getJval(v_customer_json, 'residential_address'),
        '$.customer_info.customer_ip_address',      getJval(pjReqObj, 'customer_ip_address'),
        '$.customer_info.latitude',                 getJval(pjReqObj, 'latitude'),
        '$.customer_info.longitude',                getJval(pjReqObj, 'longitude'),
        '$.customer_info.notes',                    getJval(pjReqObj, 'notes'),
        '$.order_cat',                              v_order_cat,
        '$.order_type',                             v_order_type,
        '$.order_sub_type',                         v_order_sub_type,
        '$.metal',                                  v_exchange_from_metal,
        '$.exchange.from.metal',                    v_exchange_from_metal,
        '$.exchange.from.asset_code',               v_exchange_from_asset_code,
        '$.exchange.to.metal',                      v_exchange_to_metal,
        '$.exchange.to.asset_code',                 v_exchange_to_asset_code,
        '$.exchange.weight',                        v_exchange_weight,
        '$.sell_items',                              JSON_ARRAY(JSON_OBJECT('metal', v_exchange_from_metal, 'asset_code', v_exchange_from_asset_code, 'weight', v_exchange_weight)),
        '$.buy_items',                               JSON_ARRAY(JSON_OBJECT('metal', v_exchange_to_metal, 'asset_code', v_exchange_to_asset_code, 'weight', v_exchange_weight)),
        '$.rate_info.from_rate_rec_id',              v_from_asset_rate_rec_id,
        '$.rate_info.from_rate_json',                v_from_rate_json,
        '$.rate_info.to_rate_rec_id',                v_to_asset_rate_rec_id,
        '$.rate_info.to_rate_json',                  v_to_rate_json,
        '$.customer_request.payment_method',         v_cr_payment_method,
        '$.customer_request.date_of_purchase',       DATE_FORMAT(v_cr_date_of_purchase, '%Y-%m-%dT%H:%i:%sZ')
    );

    /* ===================== Step 9: INSERT into orders table ===================== */
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
                metal                   = v_exchange_from_metal,
                order_json              = v_order_json,
                row_metadata            = v_row_metadata;

        SET v_order_rec_id = LAST_INSERT_ID();
    COMMIT;

    /* ===================== Step 10: Success Response ===================== */
    SET psResObj = JSON_OBJECT(
        'status',       'success',
        'status_code',  '0',
        'message',      'Exchange order inserted successfully',
        'order_rec_id', v_order_rec_id,
        'order_number', v_order_number,
        'receipt_number', v_receipt_number,
        'order_type',   v_order_type,
        'order_sub_type', v_order_sub_type,
        'order_cat',    v_order_cat,
        'order_json',   v_order_json
    );
END$$
DELIMITER ;
