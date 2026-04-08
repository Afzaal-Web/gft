/* =====================================================================
   TEST SCRIPT : createBuyOrder
   =====================================================================
   
*/

/* =====================================================================
   SECTION A : Validation Failures  (status_code 2)
   ===================================================================== */


SELECT '=== TEST A-1 : Missing account_number ===' AS test_case;

SET @req = JSON_OBJECT(
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-2 : Missing asset_code
-- Expected  : status=error, status_code=2, errors contains 'asset_code is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-2 : Missing asset_code ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-3 : Missing order_sub_type
-- Expected  : status=error, status_code=2, errors contains 'order_sub_type is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-3 : Missing order_sub_type ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-4 : Missing metal
-- Expected  : status=error, status_code=2, errors contains 'metal is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-4 : Missing metal ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'product_type',     'SLICE',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-5 : Missing payment_method
-- Expected  : status=error, status_code=2, errors contains 'customer_request.payment_method is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-5 : Missing payment_method ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE'
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-6 : Multiple missing fields at once
-- Expected  : status=error, status_code=2, errors array has multiple entries
-- --------------------------------------------------------------------
SELECT '=== TEST A-6 : Multiple missing fields ===' AS test_case;

SET @req = JSON_OBJECT(
    'product_type', 'SLICE'
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-7 : SLICE/Market — missing item_code
-- Expected  : status=error, status_code=2, errors contains 'item_code is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-7 : SLICE/Market — missing item_code ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-8 : SLICE/Market — missing item_weight
-- Expected  : status=error, status_code=2, errors contains 'item_weight is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-8 : SLICE/Market — missing item_weight ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-9 : SLICE/Market — missing customer_request.amount
-- Expected  : status=error, status_code=2, errors contains 'customer_request.amount is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-9 : SLICE/Market — missing amount ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-2412',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer'
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-10 : SLICE/Limit — missing rate, Expiration_time + bad order_cat
-- Expected  : status=error, status_code=2, multiple errors in array
-- --------------------------------------------------------------------
SELECT '=== TEST A-10 : SLICE/Limit — missing rate + expiry + bad order_cat ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Limit',
    'order_cat',        'BADCAT',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-241212',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'weight',           2.0
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-11 : PRODUCT — empty buy_items array
-- Expected  : status=error, status_code=2
-- --------------------------------------------------------------------
SELECT '=== TEST A-11 : PRODUCT — empty buy_items ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(),
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-12 : PRODUCT — buy_items item missing item_code
-- Expected  : status=error, status_code=2, 'buy_items[0].item_code is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-12 : PRODUCT — item missing item_code ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(
                            JSON_OBJECT(
                                'item_weight',   1.0,
                                'item_quantity', 2
                            )
                        ),
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-13 : Unknown product_type
-- Expected  : status=error, status_code=5
-- --------------------------------------------------------------------
SELECT '=== TEST A-13 : Unknown product_type ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'UNKNOWN',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST A-14 : SLICE — unknown order_sub_type
-- Expected  : status=error, status_code=5
-- --------------------------------------------------------------------
SELECT '=== TEST A-14 : SLICE — unknown order_sub_type ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'BADTYPE',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-2412',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION B : Lookup Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST B-1 : Customer not found  (status_code 3)
-- Expected  : status=error, status_code=3
-- --------------------------------------------------------------------
SELECT '=== TEST B-1 : Customer not found ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-NOTEXIST',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-2412',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST B-2 : Rate / asset not found  (status_code 4)
-- Expected  : status=error, status_code=4
-- --------------------------------------------------------------------
SELECT '=== TEST B-2 : Asset rate not found ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'NOTEXIST',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'GLD-2412',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST B-3 : Inventory item not found for SLICE  (status_code 6)
-- Expected  : status=error, status_code=6, item_code in response
-- --------------------------------------------------------------------
SELECT '=== TEST B-3 : Inventory item not found (SLICE) ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'SLICE',
    'item_code',        'ITEM-NOTEXIST',
    'item_weight',      2.0,
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


-- --------------------------------------------------------------------
-- TEST B-4 : Inventory item not found for PRODUCT second item  (status_code 6)
-- Expected  : status=error, status_code=6, item_index=1
-- --------------------------------------------------------------------
SELECT '=== TEST B-4 : Inventory not found for PRODUCT item[1] ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'CUS-001',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(
                            JSON_OBJECT(
                                'item_code',     'GLD-BAR-1G',
                                'item_weight',   1.0,
                                'item_quantity', 2
                            ),
                            JSON_OBJECT(
                                'item_code',     'ITEM-NOTEXIST',
                                'item_weight',   5.0,
                                'item_quantity', 1
                            )
                        ),
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION C : Happy Path — SLICE / Market Order
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST C-1 : SLICE / Market — full valid request
-- Expected  : status=success, status_code=0
--             buy_items has 1 item with item_name, item_type populated
--             bought_price = spot_rate * item_weight
--             transactions array has 2 entries (Credit Metal + Debit Cash)
-- --------------------------------------------------------------------
SELECT '=== TEST C-1 : SLICE/Market — happy path ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',       'P-593',
    'asset_code',           'GLD',
    'order_sub_type',       'Market',
    'metal',                'Gold',
    'product_type',         'SLICE',
    'item_code',            'GLD-241212',
    'item_weight',          2.0,
    'customer_ip_address',  '192.168.1.25',
    'latitude',             24.860735,
    'longitude',            67.001137,
    'notes',                'Test Market order',
    'customer_request',     JSON_OBJECT(
                                'payment_method',   'Bank Transfer',
                                'amount',           8867.70
                            )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION D : Happy Path — SLICE / Limit Order
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST D-1 : SLICE / Limit — default order_cat (GTC auto-assigned)
-- Expected  : status=success, order_cat=GTC
-- --------------------------------------------------------------------
SELECT '=== TEST D-1 : SLICE/Limit — order_cat defaults to GTC ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',       'P-501',
    'asset_code',           'GLD',
    'order_sub_type',       'Limit',
    'metal',                'Gold',
    'product_type',         'SLICE',
    'item_code',            'GLD-241212',
    'customer_ip_address',  '192.168.1.25',
    'latitude',             24.860735,
    'longitude',            67.001137,
    'notes',                'Test Limit GTC order',
    'customer_request',     JSON_OBJECT(
                                'payment_method',           'Bank Transfer',
                                'rate',                     4433.85,
                                'weight',                   2.0,
                                'amount',                   8867.70,
                                'Expiration_time',          '2026-12-31T23:59:59Z',
                                'is_partial_fill_allowed',  TRUE
                            )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

SELECT  JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status'))                    AS expect_success,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_cat'))                 AS expect_GTC,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.buy_items'))      AS expect_1_buy_item,
        JSON_EXTRACT(@res, '$.order_json.buy_items[0].bought_price')    AS bought_price,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.transactions'))   AS expect_2_transactions;




/* =====================================================================
   SECTION E : Happy Path — PRODUCT Order (multiple items)
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST E-1 : PRODUCT — two items
-- Expected  : status=success
--             buy_items has 2 items, each with item_name + item_type populated
--             bought_price = spot_rate * item_weight * item_quantity per item
--             transactions array has 1 entry (Cash DEBIT only, no metal credit)
--             customer_products array updated with 2 new entries (one per item type, with quantities, etc.)
-- --------------------------------------------------------------------
SELECT '=== TEST E-1 : PRODUCT — two items happy path ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',       'P-593',
    'asset_code',           'GLD',
    'order_sub_type',       'Market',
    'metal',                'Gold',
    'product_type',         'PRODUCT',
    'customer_ip_address',  '192.168.1.25',
    'latitude',             24.860735,
    'longitude',            67.001137,
    'notes',                'Test PRODUCT order two items',
    'buy_items',            JSON_ARRAY(
                                JSON_OBJECT(
                                    'item_code',     'GLD-241212',
                                    'item_weight',   1.0,
                                    'item_quantity', 2
                                ),
                                JSON_OBJECT(
                                    'item_code',     'GLD-RNG-1001',
                                    'item_weight',   5.0,
                                    'item_quantity', 1
                                )
                            ),
    'customer_request',     JSON_OBJECT(
                                'payment_method', 'Bank Transfer'
                            )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

SELECT  JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status'))                                        AS expect_success,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status_code'))                                   AS expect_0,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_cat'))                                     AS expect_DO,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.buy_items'))                          AS expect_2_buy_items,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_json.buy_items[0].item_name'))             AS item0_name,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_json.buy_items[1].item_name'))             AS item1_name,
        JSON_EXTRACT(@res, '$.order_json.buy_items[0].bought_price')                        AS item0_bought_price,
        JSON_EXTRACT(@res, '$.order_json.buy_items[1].bought_price')                        AS item1_bought_price,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.transactions'))                       AS expect_1_transaction,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_json.transactions[0].transaction_type'))   AS expect_Debit,
        JSON_EXTRACT(@res, '$.order_json.transactions[0].transaction_amount')               AS cash_debited;


-- --------------------------------------------------------------------
-- TEST E-2 : PRODUCT — single item (edge case: array with 1 element)
-- Expected  : status=success, buy_items length=1, transactions length=1, customer_products updated with 1 entry
-- --------------------------------------------------------------------
SELECT '=== TEST E-2 : PRODUCT — single item in array ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-593',
    'asset_code',       'SLV',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(
                            JSON_OBJECT(
                                'item_code',     'SLV-241212',
                                'item_weight',   1.0,
                                'item_quantity', 3
                            )
                        ),
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

SELECT  JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status'))                        AS expect_success,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.buy_items'))          AS expect_1_buy_item,
        JSON_LENGTH (JSON_EXTRACT(@res, '$.order_json.transactions'))       AS expect_1_transaction;


-- TEST A-15 : PRODUCT — order_sub_type provided (ignored)
-- Expected  : status=success, status_code=0 (order_sub_type is ignored for PRODUCT), transactions=1
SELECT '=== TEST A-15 : PRODUCT — order_sub_type ignored ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Limit',
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(
                            JSON_OBJECT(
                                'item_code',     'GLD-BAR-1G',
                                'item_weight',   1.0,
                                'item_quantity', 2
                            )
                        ),
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

CALL createBuyOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

SELECT  JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status'))                        AS expect_success,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.status_code'))                   AS expect_0,
        JSON_UNQUOTE(JSON_EXTRACT(@res, '$.limit_or_market'))               AS expect_null_for_product;
   Run after successful tests to confirm DB state is correct
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST F-1 : Confirm order was inserted into orders table
-- Run after any successful C/D/E test
-- --------------------------------------------------------------------
SELECT '=== TEST F-1 : orders table — latest rows ===' AS test_case;

SELECT  order_rec_id,
        order_number,
        receipt_number,
        order_status,
        order_cat,
        order_type,
        metal,
        JSON_UNQUOTE(JSON_EXTRACT(order_json, '$.product_type'))                        AS product_type,
        JSON_LENGTH (JSON_EXTRACT(order_json, '$.buy_items'))                           AS buy_items_count,
        JSON_LENGTH (JSON_EXTRACT(order_json, '$.transactions'))                        AS transactions_count,
        JSON_UNQUOTE(JSON_EXTRACT(order_json, '$.transactions[0].transaction_type'))    AS txn0_type,
        JSON_UNQUOTE(JSON_EXTRACT(order_json, '$.transactions[1].transaction_type'))    AS txn1_type,
        JSON_EXTRACT(order_json, '$.transactions[0].transaction_amount')                AS metal_credited,
        JSON_EXTRACT(order_json, '$.transactions[1].transaction_amount')                AS cash_debited
FROM    orders
ORDER BY order_rec_id DESC
LIMIT   5;


-- --------------------------------------------------------------------
-- TEST F-2 : Confirm wallet_ledger rows were inserted (2 per order)
-- --------------------------------------------------------------------
SELECT '=== TEST F-2 : wallet_ledger — latest rows ===' AS test_case;

SELECT  wallet_ledger_rec_id,
        customer_rec_id,
        wallet_id,
        wallet_title,
        asset_code,
        transaction_type,
        JSON_EXTRACT(wallet_ledger_json, '$.ledger_transaction.balance_before')     AS balance_before,
        JSON_EXTRACT(wallet_ledger_json, '$.ledger_transaction.credit_amount')      AS credit_amount,
        JSON_EXTRACT(wallet_ledger_json, '$.ledger_transaction.debit_amount')       AS debit_amount,
        JSON_EXTRACT(wallet_ledger_json, '$.ledger_transaction.balance_after')      AS balance_after
FROM    wallet_ledger
ORDER BY wallet_ledger_rec_id DESC
LIMIT   4;


-- --------------------------------------------------------------------
-- TEST F-3 : Confirm customer wallet balances were updated
-- --------------------------------------------------------------------
SELECT '=== TEST F-3 : customer wallet balances after buy ===' AS test_case;

SELECT  JSON_UNQUOTE(JSON_EXTRACT(w.value, '$.wallet_id'))          AS wallet_id,
        JSON_UNQUOTE(JSON_EXTRACT(w.value, '$.asset_code'))         AS asset_code,
        JSON_UNQUOTE(JSON_EXTRACT(w.value, '$.wallet_type'))        AS wallet_type,
        JSON_EXTRACT(w.value, '$.wallet_balance')                   AS wallet_balance,
        JSON_UNQUOTE(JSON_EXTRACT(w.value, '$.balance_last_updated_at')) AS last_updated
FROM    customer c,
        JSON_TABLE(
            JSON_EXTRACT(c.customer_json, '$.customer_wallets'),
            '$[*]' COLUMNS (value JSON PATH '$')
        ) AS w
WHERE   c.account_number = 'CUS-001';




-- Test Script for createBuyOrder Stored Procedure
-- This script tests the createBuyOrder procedure with sample data for PRODUCT type.

-- Set up the request JSON for a PRODUCT buy order
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Limit',  -- This will be ignored for PRODUCT
    'metal',            'Gold',
    'product_type',     'PRODUCT',
    'buy_items',        JSON_ARRAY(
                            JSON_OBJECT(
                                'item_code',     'GLD-RNG-1001',
                                'item_weight',   1.0,
                                'item_quantity', 2
                            )
                        ),
    'customer_request', JSON_OBJECT(
                            'payment_method',   'Bank Transfer',
                            'amount',           8867.70
                        )
);

-- Call the procedure
CALL createBuyOrder(@req, @res);

-- Display the result
SELECT JSON_PRETTY(@res) AS result;

-- Optional: Check the inserted order
-- SELECT order_number, order_status, limit_or_market FROM orders WHERE order_number = JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_number'));


-- Test Script for createBuyOrder Stored Procedure - SLICE Limit Order
-- This script tests the createBuyOrder procedure with sample data for SLICE Limit order.

-- Set up the request JSON for a SLICE Limit buy order
SET @req = JSON_OBJECT(
    'account_number',       'P-501',
    'asset_code',           'GLD',
    'order_sub_type',       'Limit',
    'order_cat',            'GTC',  -- Good Till Cancelled
    'metal',                'Gold',
    'product_type',         'SLICE',
    'item_code',            'GLD-241212',
    'item_weight',          2.0,
    'customer_ip_address',  '192.168.1.25',
    'latitude',             24.860735,
    'longitude',            67.001137,
    'notes',                'Test Limit GTC order',
    'customer_request',     JSON_OBJECT(
                                'payment_method',           'Bank Transfer',
                                'rate',                     4433.85,
                                'weight',                   2.0,
                                'amount',                   8867.70,
                                'Expiration_time',          '2026-12-31T23:59:59Z',
                                'is_partial_fill_allowed',  TRUE
                            )
);

-- Call the procedure
CALL createBuyOrder(@req, @res);

-- Display the result
SELECT JSON_PRETTY(@res) AS result;

-- Optional: Check the inserted order
-- SELECT order_number, order_status, limit_or_market FROM orders WHERE order_number = JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_number'));



-- Test Script for createBuyOrder Stored Procedure - SLICE Market Order
-- This script tests the createBuyOrder procedure with sample data for SLICE Market order.

-- Set up the request JSON for a SLICE Market buy order
SET @req = JSON_OBJECT(
    'account_number',       'P-501',
    'asset_code',           'GLD',
    'order_sub_type',       'Market',
    'metal',                'Gold',
    'product_type',         'SLICE',
    'item_code',            'GLD-241212',
    'item_weight',          2.0,
    'customer_ip_address',  '192.168.1.25',
    'latitude',             24.860735,
    'longitude',            67.001137,
    'notes',                'Test Market order',
    'customer_request',     JSON_OBJECT(
                                        'payment_method',   'Bank Transfer',
                                        'amount',           8867.70
                                    )
);

-- Call the procedure
CALL createBuyOrder(@req, @res);

-- Display the result
SELECT JSON_PRETTY(@res) AS result;

-- Optional: Check the inserted order
-- SELECT order_number, order_status, limit_or_market FROM orders WHERE order_number = JSON_UNQUOTE(JSON_EXTRACT(@res, '$.order_number'));