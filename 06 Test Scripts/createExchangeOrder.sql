/* =====================================================================
   TEST SCRIPT : createExchangeOrder
   =====================================================================
   This script exercises the createExchangeOrder stored procedure.

   Each test:
     1. Sets @req  (the JSON input)
     2. CALLs createExchangeOrder(@req, @res)
     3. SELECTs JSON_PRETTY(@res) as result

   Prerequisites — the following must exist before running:
     • customer row with account_number = 'P-501'
     • customer JSON contains customer_wallets with METAL wallets for asset_codes 'GLD' and 'SLV'
       and a CASH wallet with sufficient balance
     • tradable_assets rows with asset_codes 'GLD' and 'SLV'
     • inventory rows with item_codes 'GLD-2412' and 'SLV-2412' for SLICE tests
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
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-241212',
    'to_item_code',     'SLV-241212',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-2 : Missing from_asset_code
-- Expected  : status_code 2, from_asset_code is required
-- --------------------------------------------------------------------
SELECT '=== TEST A-2 : Missing from_asset_code ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-241212',
    'to_item_code',     'SLV-241212',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-3 : Same from and to asset_code
-- Expected  : status_code 2, from_asset_code and to_asset_code must be different
-- --------------------------------------------------------------------
SELECT '=== TEST A-3 : Same from and to asset_code ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'GLD',
    'to_asset_code',    'GLD',
    'from_metal',       'Gold',
    'to_metal',         'Gold',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'GLD-2412',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 1.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION B : Lookup Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST B-1 : Customer not found
-- Expected  : status_code 3, Customer not found
-- --------------------------------------------------------------------
SELECT '=== TEST B-1 : Customer not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'NONEXISTENT',
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-2 : From asset rate not found
-- Expected  : status_code 4, Rate not found for from_asset_code
-- --------------------------------------------------------------------
SELECT '=== TEST B-2 : From asset rate not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'INVALID',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-3 : From inventory item not found
-- Expected  : status_code 6, Inventory item not found for from_item_code
-- --------------------------------------------------------------------
SELECT '=== TEST B-3 : From inventory item not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'INVALID',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION C : Wallet Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST C-1 : From metal wallet not found
-- Expected  : status_code 7, Metal wallet not found for from_asset_code
-- --------------------------------------------------------------------
SELECT '=== TEST C-1 : From metal wallet not found ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1000.0, 'to_weight', 10.0)  -- Assuming insufficient balance
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST C-2 : Insufficient from metal balance
-- Expected  : status_code 9, Insufficient metal balance for exchange
-- --------------------------------------------------------------------
SELECT '=== TEST C-2 : Insufficient from metal balance ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1000.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION D : Happy Path
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST D-1 : Successful Exchange Order
-- Expected  : status_code 0, Exchange order created successfully
-- --------------------------------------------------------------------
SELECT '=== TEST D-1 : Successful Exchange Order ===' AS test_case;
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'from_asset_code',  'GLD',
    'to_asset_code',    'SLV',
    'from_metal',       'Gold',
    'to_metal',         'Silver',
    'from_item_code',   'GLD-2412',
    'to_item_code',     'SLV-2412',
    'customer_request', JSON_OBJECT('from_weight', 1.0, 'to_weight', 10.0)
);
CALL createExchangeOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;