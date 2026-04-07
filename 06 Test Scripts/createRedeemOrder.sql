/* =====================================================================
   TEST SCRIPT : createRedeemOrder
   =====================================================================
   Each test:
     1. Sets @req  (the JSON input)
     2. CALLs the SP
     3. SELECTs @res  (the JSON output) with a label
     4. Optionally verifies side-effects (orders table, wallet_ledger)

   Tests are grouped by:
     A.  Validation failures          (status_code 2)
     B.  Lookup failures              (status_code 3 / 4 / 6 / 7 / 8 / 9 / 10 / 11 / 12)
     C.  Happy path                   (status_code 0)
     D.  Side-effect verification     (orders, wallet_ledger rows)

   Prerequisites — the following must exist in your DB before running:
     • customers row          account_number = 'P-501'
                              customer_rec_id = 101
                              customer_json contains customer_wallets with METAL wallet for 'GLD' and CASH wallet
                              with sufficient balances (metal >= weight, cash >= charges)
     • tradable_assets row    asset_code = 'GLD'
                              tradable_assets_json.spot_rate.current_rate = 4433.85
     • inventory rows         item_code = 'GLD-BAR-1G' (item_weight=1.0, item_name='Gold Bar 1g')
                              item_code = 'GLD-COIN-5G' (item_weight=5.0, item_name='Gold Coin 5g')
     • sequences set up       ORDERS.ORDER_NUM, ORDERS.RECEIPT_NUM, ORDERS.TXN_NUM
   ===================================================================== */


/* =====================================================================
   SECTION A : Validation Failures  (status_code 2)
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST A-1 : Missing account_number
-- Expected  : status=error, status_code=2, errors contains 'account_number is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-1 : Missing account_number ===' AS test_case;

SET @req = JSON_OBJECT(
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-2 : Missing asset_code
-- Expected  : status=error, status_code=2, errors contains 'asset_code is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-2 : Missing asset_code ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-3 : Missing metal
-- Expected  : status=error, status_code=2, errors contains 'metal is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-3 : Missing metal ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'customer_request', JSON_OBJECT(
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-4 : Missing customer_request.payment_method
-- Expected  : status=error, status_code=2, errors contains 'customer_request.payment_method is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-4 : Missing payment_method ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-5 : Missing customer_request.weight
-- Expected  : status=error, status_code=2, errors contains 'customer_request.weight is required and must be greater than 0'
-- --------------------------------------------------------------------
SELECT '=== TEST A-5 : Missing weight ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-6 : Zero weight
-- Expected  : status=error, status_code=2, errors contains 'customer_request.weight is required and must be greater than 0'
-- --------------------------------------------------------------------
SELECT '=== TEST A-6 : Zero weight ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         0.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-BAR-1G',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-7 : Empty redeem_items
-- Expected  : status=error, status_code=2, errors contains 'redeem_items array is required and must not be empty'
-- --------------------------------------------------------------------
SELECT '=== TEST A-7 : Empty redeem_items ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY()
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-8 : Missing item_code in redeem_items
-- Expected  : status=error, status_code=2, errors contains 'redeem_items[0].item_code is required'
-- --------------------------------------------------------------------
SELECT '=== TEST A-8 : Missing item_code ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST A-9 : Weight mismatch
-- Expected  : status=error, status_code=2, message 'customer_request.weight does not match total weight of selected redeem items'
-- --------------------------------------------------------------------
SELECT '=== TEST A-9 : Weight mismatch ===' AS test_case;

    SET @req = JSON_OBJECT(
        'account_number',   'P-501',
        'asset_code',       'GLD',
        'metal',            'Gold',
        'customer_request', JSON_OBJECT(
            'payment_method', 'Bank Transfer',
            'weight',         5.0  -- mismatch: items total 10.0
        ),
        'redeem_items',     JSON_ARRAY(
            JSON_OBJECT(
                'item_code',     'GLD-241212',
                'item_weight',   1.0,
                'item_quantity', 10
            )
        )
    );

    CALL createRedeemOrder(@req, @res);
    SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION B : Lookup Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST B-1 : Customer not found
-- Expected  : status=error, status_code=3, message 'Customer not found'
-- --------------------------------------------------------------------
SELECT '=== TEST B-1 : Customer not found ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'NONEXISTENT',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-2 : Rate not found
-- Expected  : status=error, status_code=4, message 'Rate not found for asset_code'
-- --------------------------------------------------------------------
SELECT '=== TEST B-2 : Rate not found ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'gdfgd',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-3 : Inventory item not found
-- Expected  : status=error, status_code=6, message 'Inventory item not found for item_code'
-- --------------------------------------------------------------------
SELECT '=== TEST B-3 : Inventory item not found ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'NONEXISTENT',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-4 : Metal wallet not found
-- Expected  : status=error, status_code=7, message 'Metal wallet not found for asset_code'
-- --------------------------------------------------------------------
SELECT '=== TEST B-4 : Metal wallet not found ===' AS test_case;

-- Assuming customer has no GLD METAL wallet
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'SLV',  -- assuming no SLV wallet
    'metal',            'Silver',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-5 : Cash wallet not found
-- Expected  : status=error, status_code=8, message 'Cash wallet not found for customer'
-- --------------------------------------------------------------------
SELECT '=== TEST B-5 : Cash wallet not found ===' AS test_case;

-- Assuming customer has no CASH wallet
SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-6 : Insufficient metal balance
-- Expected  : status=error, status_code=9, message 'Insufficient metal balance'
-- --------------------------------------------------------------------
SELECT '=== TEST B-6 : Insufficient metal balance ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         1000.0  -- assuming balance < 1000
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 1000
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-7 : Negative charges (discount too high)
-- Expected  : status=error, status_code=10, message 'Net charges amount cannot be negative'
-- --------------------------------------------------------------------
SELECT '=== TEST B-7 : Negative charges ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    ),
    'discount_amount',  10000.00  -- excessive discount
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST B-8 : Insufficient cash balance
-- Expected  : status=error, status_code=12, message 'Insufficient cash balance to cover redemption charges'
-- --------------------------------------------------------------------
SELECT '=== TEST B-8 : Insufficient cash balance ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    )
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION C : Happy Path  (status_code 0)
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST C-1 : Successful redeem order
-- Expected  : status=success, status_code=0, message 'Redeem order inserted successfully'
-- --------------------------------------------------------------------
SELECT '=== TEST C-1 : Successful redeem ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         10.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   1.0,
            'item_quantity', 10
        )
    ),
    'customer_ip_address', '192.168.1.1',
    'latitude',          40.7128,
    'longitude',         -74.0060,
    'notes',             'Test redeem order'
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

-- --------------------------------------------------------------------
-- TEST C-2 : Successful redeem order with multiple redeem_items
-- Expected  : status=success, status_code=0, customer_request.total_qty_to_buy = 6
-- --------------------------------------------------------------------
SELECT '=== TEST C-2 : Successful redeem with multiple items ===' AS test_case;

SET @req = JSON_OBJECT(
    'account_number',   'P-501',
    'asset_code',       'GLD',
    'metal',            'Gold',
    'customer_request', JSON_OBJECT(
        'payment_method', 'Bank Transfer',
        'weight',         25.0
    ),
    'redeem_items',     JSON_ARRAY(
        JSON_OBJECT(
            'item_code',     'GLD-241212',
            'item_weight',   15.00,
            'item_quantity', 1
        ),
        JSON_OBJECT(
            'item_code',     'GLD-RNG-1001',
            'item_weight',   10.00,
            'item_quantity', 1
        )
    ),
    'customer_ip_address', '192.168.1.1',
    'latitude',          40.7128,
    'longitude',         -74.0060,
    'notes',             'Test redeem order with 2 items'
);

CALL createRedeemOrder(@req, @res);
SELECT JSON_PRETTY(@res) AS result;

/* =====================================================================
   SECTION D : Side-effect Verification
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST D-1 : Verify order inserted
-- --------------------------------------------------------------------
SELECT '=== TEST D-1 : Verify order inserted ===' AS test_case;

SELECT order_rec_id,
       order_number,
       order_status,
       order_type,
       metal,
       order_json->>'$.customer_request.total_qty_to_buy' AS total_qty_to_buy,
       order_json->>'$.order_summary.total_redeem_weight' AS total_weight
FROM orders
WHERE order_type = 'Redeem'
ORDER BY order_rec_id DESC
LIMIT 1;

-- --------------------------------------------------------------------
-- TEST D-2 : Verify wallet transactions
-- --------------------------------------------------------------------
SELECT '=== TEST D-2 : Verify wallet transactions ===' AS test_case;

SELECT wl.wallet_ledger_rec_id, wl.transaction_type, wl.wallet_type, wl.asset_code, wl.transaction_amount, wl.balance_after, wl.description
FROM wallet_ledger wl
WHERE wl.order_number LIKE 'ORD-%'
ORDER BY wl.wallet_ledger_rec_id DESC
LIMIT 5;