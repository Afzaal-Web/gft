SET @pjReqObj = JSON_OBJECT(
    
    'tradable_assets_rec_id', 1,

    'asset_code', 'GOLD-001',
    'product_code', 'P-GOLD-50G',
    'product_type', 'commodity',
    'product_name', '24K Gold Bar 50g',

    'product_short_name', 'Gold Bar 50g',
    'product_description', 'High purity 24 karat gold bar for trading.',
    'product_classification', 'precious_metals',
    'asset_type', 'physical',
    'product_quality', '24K',

    'approximate_weight', 50,
    'weight_unit', 'grams',
    'dimensions', '8cm x 4cm x 0.4cm',

    'is_physical', TRUE,
    'is_SliceAble', FALSE,

    'standard_price', 360000,
    'standard_premium', 8000,
    'price_currency', 'PKR',

    'applicable_taxes', JSON_ARRAY(
        JSON_OBJECT(
            'tax_name', 'Sales Tax',
            'taxes_description', 'Government sales tax',
            'amount', 17,
            'fixed_or_percent', 'percent'
        )
    ),

    'quantity_on_hand', 180,
    'minimum_order_quantity', 1,
    'total_sold', 0,

    'offer_to_customer', TRUE,
    'display_order', 1,
    'Alert_on_low_stock', 15,

    'media_library', JSON_ARRAY(
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/gold50_front.jpg','is_featured',TRUE),
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/gold50_back.jpg','is_featured',FALSE),
        JSON_OBJECT('media_type','video','media_url','https://cdn.example.com/gold50_video.mp4','is_featured',FALSE)
    ),

    'transaction_fee', JSON_OBJECT(
        'fee_type','platform_fee',
        'fee_value',0.5,
        'fee_currency','percent',
        'fee_description','Marketplace processing fee'
    )
);

SET @pjReqObj = JSON_OBJECT(
    'tradable_assets_rec_id', 2,

    'asset_code', 'SILVER-001',
    'product_code', 'P-SILVER-1KG',
    'product_type', 'commodity',
    'product_name', 'Fine Silver Bar 1kg',

    'product_short_name', 'Silver Bar 1kg',
    'product_description', '999 purity silver bullion bar.',
    'product_classification', 'precious_metals',
    'asset_type', 'physical',
    'product_quality', '999',

    'approximate_weight', 1000,
    'weight_unit', 'grams',
    'dimensions', '15cm x 6cm x 1cm',

    'is_physical', TRUE,
    'is_SliceAble', FALSE,

    'standard_price', 250000,
    'standard_premium', 5000,
    'price_currency', 'PKR',

    'applicable_taxes', JSON_ARRAY(
        JSON_OBJECT(
            'tax_name','Sales Tax',
            'taxes_description','Government sales tax',
            'amount',10,
            'fixed_or_percent','percent'
        )
    ),

    'quantity_on_hand', 90,
    'minimum_order_quantity', 1,
    'total_sold', 5,

    'offer_to_customer', TRUE,
    'display_order', 2,
    'Alert_on_low_stock', 10,

    'media_library', JSON_ARRAY(
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/silver1kg_front.jpg','is_featured',TRUE),
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/silver1kg_back.jpg','is_featured',FALSE),
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/silver1kg_side.jpg','is_featured',FALSE)
    ),

    'transaction_fee', JSON_OBJECT(
        'fee_type','platform_fee',
        'fee_value',300,
        'fee_currency','PKR',
        'fee_description','Flat trading commission'
    )
);

SET @pjReqObj = JSON_OBJECT(
    'tradable_assets_rec_id', 3,

    'asset_code', 'PLAT-001',
    'product_code', 'P-PLAT-20G',
    'product_type', 'commodity',
    'product_name', 'Platinum Bar 20g',

    'product_short_name', 'Platinum 20g',
    'product_description', 'Investment grade platinum bar.',
    'product_classification', 'precious_metals',
    'asset_type', 'physical',
    'product_quality', '999.5',

    'approximate_weight', 20,
    'weight_unit', 'grams',
    'dimensions', '5cm x 3cm x 0.3cm',

    'is_physical', TRUE,
    'is_SliceAble', FALSE,

    'standard_price', 190000,
    'standard_premium', 4000,
    'price_currency', 'PKR',

    'applicable_taxes', JSON_ARRAY(
        JSON_OBJECT(
            'tax_name','Luxury Tax',
            'taxes_description','Premium metals tax',
            'amount',5,
            'fixed_or_percent','percent'
        )
    ),

    'quantity_on_hand', 40,
    'minimum_order_quantity', 1,
    'total_sold', 2,

    'offer_to_customer', FALSE,
    'display_order', 3,
    'Alert_on_low_stock', 5,

    'media_library', JSON_ARRAY(
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/platinum20_front.jpg','is_featured',TRUE),
        JSON_OBJECT('media_type','image','media_url','https://cdn.example.com/platinum20_back.jpg','is_featured',FALSE),
        JSON_OBJECT('media_type','video','media_url','https://cdn.example.com/platinum20_video.mp4','is_featured',FALSE)
    ),

    'transaction_fee', JSON_OBJECT(
        'fee_type','platform_fee',
        'fee_value',0.75,
        'fee_currency','percent',
        'fee_description','Premium asset transaction fee'
    )
);

-- for update

SET @pjReqObj = JSON_OBJECT(
	'product_rec_id', 3,
    'tradable_assets_rec_id', 3,
    'asset_code', 'PLAT-001',
    'product_code', 'P-PLAT-20G',
    'product_type', 'PLATINUM',
    'product_name', 'Platinum Bar 20g'
);

CALL upsertProduct(@pjReqObj, @psResObj);

SELECT @psResObj AS response;
