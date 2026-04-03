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