SET @pjReqObj = JSON_OBJECT(
	'product_rec_id', 5,
    'tradable_assets_rec_id', 3,
    'asset_code', 'PLD',
    'product_code', 'pld-1',
    'product_type', 'Bar',
    'product_name', '1g Bar'
);

CALL createProduct(@pjReqObj, @psResObj);

SELECT @psResObj AS response;
