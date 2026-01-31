-- Test script for createInventory SP

SET @pjReqObj = JSON_OBJECT(
    'product_rec_id',    1,
    'item_name',         'Gold Bar 50g',
    'item_type',         'Bar',
    'asset_type',        'Metal',
    'availability_status','available',
    'item_Size',         '50g',
    'weight_adjustment', 0.00,
    'net_weight',        50.00,
    'available_weight', 50.00,
    'item_quality',      '999.9',
    'location_details',  'Vault A - Shelf 3',

    'pricing_adjustments', JSON_OBJECT(
        'item_margin_adjustment', 2.5,
        'Discount',               0.00,
        'Promotions',             'New Year Offer'
    ),

    'media_library', JSON_ARRAY(
        JSON_OBJECT(
            'media_type','image',
            'media_url','https://cdn.example.com/inventory/gold_bar_50g.jpg',
            'is_featured', TRUE
        )
    ),

    'ownership_metrics', JSON_OBJECT(
        'weight_sold_so_far',     0,
        'number_of_shareholders', 0,
        'number_of_transactions',0
    ),

    'manufacturer_info', JSON_OBJECT(
        'manufacturing_country','Switzerland',
        'manufacturer_name','PAMP',
        'manufacturing_date','2025-01-10',
        'serial_number','GB50-99221',
        'serial_verification_url','https://verify.pamp.com/GB50-99221',
        'serial_verification_text','Verified',
        'dimensions','60x30x5 mm'
    ),

    'purchase_from', JSON_OBJECT(
        'purchase_from_rec_id',101,
        'receipt_number','RCPT-99211',
        'receipt_date','2025-01-12',
        'from_name','Global Bullion Traders',
        'from_address','Dubai Gold Souk',
        'from_phone','+971501234567',
        'from_email','sales@gbt.ae',
        'purchase_date','2025-01-12',
        'packaging','sealed',
        'metal_rate',7200.50,
        'metal_weight',50,
        'making_charges',0,
        'premium_paid',120,
        'total_tax_paid',90,
        'tax_description','Import VAT',
        'total_price_paid',361000,
        'mode_of_payment','bank_transfer',
        'check_or_transaction_no','TXN88221'
    )
);

SET @pjReqObj = JSON_OBJECT(

    'product_rec_id',    9,
    'item_name',         'Silver Ring 10g',
    'item_type',         'Ring',
    'asset_type',        'Metal',
    'availability_status','out of stock',
    'item_Size',         '10g',
    'weight_adjustment', 0.10,
    'net_weight',        9.90,
    'available_weight', 0,
    'item_quality',      '925',
    'location_details',  'Showroom Counter 2',

    'pricing_adjustments', JSON_OBJECT(
        'item_margin_adjustment', 5,
        'Discount',               3,
        'Promotions',             'Festival Sale'
    ),

    'media_library', JSON_ARRAY(
        JSON_OBJECT(
            'media_type','image',
            'media_url','https://cdn.example.com/inventory/silver_ring.jpg',
            'is_featured', TRUE
        )
    ),

    'ownership_metrics', JSON_OBJECT(
        'weight_sold_so_far',     10,
        'number_of_shareholders', 1,
        'number_of_transactions',1
    ),

    'manufacturer_info', JSON_OBJECT(
        'manufacturing_country','India',
        'manufacturer_name','Tanishq',
        'manufacturing_date','2024-12-01',
        'serial_number','SR10-44112',
        'serial_verification_url','https://verify.tanishq.com/SR10-44112',
        'serial_verification_text','Verified',
        'dimensions','22mm diameter'
    ),

    'purchase_from', JSON_OBJECT(
        'purchase_from_rec_id',221,
        'receipt_number','RCPT-55110',
        'receipt_date','2024-12-05',
        'from_name','Mumbai Metals Ltd',
        'from_address','Zaveri Bazaar, Mumbai',
        'from_phone','+919811223344',
        'from_email','sales@mumbaimetals.in',
        'purchase_date','2024-12-05',
        'packaging','retail box',
        'metal_rate',85.75,
        'metal_weight',10,
        'making_charges',15,
        'premium_paid',5,
        'total_tax_paid',12,
        'tax_description','GST',
        'total_price_paid',890,
        'mode_of_payment','card',
        'check_or_transaction_no','TXN77882'
    ),

    'sold_to', JSON_ARRAY(
        JSON_OBJECT(
            'order_date','2025-01-18',
            'order_number','ORD-7712',
            'receipt_number','RCP-7712',
            'sold_date','2025-01-18',
            'sold_to_id',501,
            'sold_to_name','Ali Raza',
            'sold_to_phone','+923001234567',
            'sold_to_email','ali.raza@email.com',
            'sold_to_address','Lahore, Pakistan',
            'metal_rate',92.50,
            'weight_sold',10,
            'making_charges',15,
            'premium_charged',5,
            'taxes',12,
            'taxes_description','GST',
            'total_price_charged',890,

            'transaction_details', JSON_OBJECT(
                'transaction_num','TRX-55112',
                'fee_type','gateway',
                'fee_value',2.5,
                'fee_currency','PKR',
                'fee_description','Card processing fee',
                'transaction_status','completed'
            )
        )
    )
);






-- Call the stored procedure
CALL upsertInventory(@pjReqObj, @psResObj);

-- See the response
SELECT @psResObj AS response;
