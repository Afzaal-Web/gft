-- Test script for createInventory SP

SET @pjReqObj = JSON_OBJECT(
 'inventory_rec_id',           2,
    'product_rec_id',             6,  
    'item_name',                  'Silver Ring 10g',
    'item_type',                  'Ring',
    'asset_type',                 'Metal',
    'availability_status',        'out of stock'
);

-- Call the stored procedure
CALL createInventory(@pjReqObj, @psResObj);

-- See the response
SELECT @psResObj AS response;
