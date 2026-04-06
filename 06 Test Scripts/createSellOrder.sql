/* =====================================================================
   TEST SCRIPT : createSellOrder
   =====================================================================
   This script exercises the createSellOrder stored procedure.

   Each test:
     1. Sets @req  (the JSON input)
     2. CALLs createSellOrder(@req, @res)
     3. SELECTs JSON_PRETTY(@res) as result

   Prerequisites — the following must exist before running:
     • customer row with account_number = 'P-501'
     • customer JSON contains customer_wallets with a METAL wallet for asset_code 'GLD'
       and a CASH wallet with sufficient balance
     • tradable_assets row with asset_code = 'GLD'
     • inventory row with item_code = 'GLD-2412' for SLICE tests
     • sequences for ORDERS.ORDER_NUM, ORDERS.RECEIPT_NUM, ORDERS.TXN_NUM
   ===================================================================== */


/* =====================================================================
   SECTION A : Validation Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST A-1 : Missing account_number
-- Expected  : status_code 2, account_number is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-1 : Missing account_number ===' AS test_case;
SET @req = JSON_OBJECT(
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-2 : Missing asset_code
-- Expected  : status_code 2, asset_code is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-2 : Missing asset_code ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-3 : Missing order_sub_type
-- Expected  : status_code 2, order_sub_type is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-3 : Missing order_sub_type ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-4 : Missing metal
-- Expected  : status_code 2, metal is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-4 : Missing metal ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-5 : Missing item_code
-- Expected  : status_code 2, item_code is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-5 : Missing item_code ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-6 : Missing customer_request.weight
-- Expected  : status_code 2, customer_request.weight is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-6 : Missing customer_request.weight ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer')
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-7 : Missing customer_request.payment_method
-- Expected  : status_code 2, payment_method is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-7 : Missing payment_method ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-8 : Invalid order_sub_type
-- Expected  : status=error, status_code=5
-- --------------------------------------------------------------------
SELECT '=== TEST A-8 : Invalid order_sub_type ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'BadType',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION B : Lookup Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST B-1 : Asset rate not found
-- Expected  : status_code 4
-- --------------------------------------------------------------------
SELECT '=== TEST B-1 : Asset rate not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'UNKNOWN',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-2412',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-2 : Inventory item not found
-- Expected  : status_code 6
-- --------------------------------------------------------------------
SELECT '=== TEST B-2 : Inventory item not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-UNKNOWN',
    'customer_request', JSON_OBJECT('payment_method', 'Bank Transfer', 'weight', 2.0)
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION C : Happy Path — SLICE / Market
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST C-1 : Valid Market sell order
-- Expected  : status_code 0
-- --------------------------------------------------------------------
SELECT '=== TEST C-1 : Valid Market sell order ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Market',
    'metal',            'Gold',
    'item_code',        'GLD-241212',
    'customer_request', JSON_OBJECT(
                            'payment_method', 'Bank Transfer',
                            'weight',         2.0
                        )
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;


/* =====================================================================
   SECTION D : Happy Path — SLICE / Limit
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST D-1 : Valid Limit sell order
-- Expected  : status_code 0
-- --------------------------------------------------------------------
SELECT '=== TEST D-1 : Valid Limit sell order ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'order_sub_type',   'Limit',
    'order_cat',        'GTC',
    'metal',            'Gold',
    'item_code',        'GLD-241212',
    'customer_request', JSON_OBJECT(
                            'payment_method',            'Bank Transfer',
                            'weight',                    2.0,
                            'rate',                      4400.00,
                            'amount',                    8800.00,
                            'Expiration_time',           '2025-01-25   23:59',
                            'is_partial_fill_allowed',   'false'
                        )
);
CALL createSellOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;
