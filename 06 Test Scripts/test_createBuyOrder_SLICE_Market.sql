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