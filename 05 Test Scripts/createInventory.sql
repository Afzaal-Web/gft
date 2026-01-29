-- Test script for createInventory SP

SET @pjReqObj = JSON_OBJECT(
 'inventory_rec_id',           2,
    'product_rec_id',             6,  
    'item_name',                  'Gold Ring 10g',
    'item_type',                  'Ring',
    'asset_type',                 'Gold',
    'availability_status',        'Available'
);

-- Call the stored procedure
CALL createInventory(@pjReqObj, @psResObj);

-- See the response
SELECT @psResObj AS response;
