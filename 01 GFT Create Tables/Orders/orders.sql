-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- Order Module Started

-- ===============================================
-- Orders Table Started
-- ===============================================

DROP TABLE IF EXISTS orders;
-- ===============================================
-- Create corporate_account table
-- ===============================================
CREATE TABLE IF NOT EXISTS orders (	
    order_rec_id					INT 																PRIMARY KEY AUTO_INCREMENT,
    customer_rec_id					INT,
    account_number					VARCHAR(50),
    order_number					VARCHAR(50)															UNIQUE,
    receipt_number 					VARCHAR(50)															UNIQUE,
    
    order_date			 			DATETIME,
    order_status 					ENUM('pending','approved', 'rejected', 'completed', 'failed'),
    order_type 						ENUM('DO','IOC', 'GTC'),   											-- ('DO - day order','IOC - immediate or cancel', 'GTC - good till cancel')
    transaction_type 				ENUM('Buy','Sell', 'Exchange', 'Redeem')							NOT NULL,
    
    order_json			 			JSON,
    row_metadata 					JSON
);

-- ===============================================
-- Demo row: order_rec_id = 0
-- ===============================================

INSERT INTO orders
SET
	order_rec_id		= 0,
    customer_rec_id	       = 0,
    customer_number        = 'aaa000',
    order_number        = '0000',
    receipt_number      = '000',
    order_date          = NOW(),

    order_status        = 'Pending',
    order_type          = 'GTC',
    transaction_type    = 'Buy',

  order_json            = JSON_OBJECT(

		'order_rec_id',						 0,
		'order_number', 					'ORD-2026-0001',
		'receipt_number', 					'RCT-2026-0001',
		'order_date',						 NOW(),
		'order_status', 					'Pending',
		'order_type', 						'GTC',
		'transaction_type', 				'Buy',
        
		'notes', 							'Initial buy order placed by customer',
		'customer_ip_address', 				'192.168.1.25',
		'latitude', 						24.860735,
		'longitude', 						67.001137,
  
       /* ===================== Customer Info ===================== */
    'customer_info', JSON_OBJECT(
            'customer_rec_id',				101,                                  	'_comment_customer_rec_id', 'Unique customer record ID',
            'customer_name', 				'Ali Raza',                            '_comment_customer_name', 'Full name of customer',
            'customer_account_number', 		'CUS-001',                        		'_comment_customer_account_number', 'Customer account number',
            'customer_phone', 				'+92-300-9876543',                    	'_comment_customer_phone', 'Primary phone number',
            'whatsapp', 					'+92-300-9876543',                      '_comment_whatsapp', 'WhatsApp contact number',
            'customer_email', 				'ali.raza@email.com',                 	'_comment_customer_email', 'Customer email address',
            'customer_address', 			'Karachi, Pakistan',                  	'_comment_customer_address', 'Residential or billing address'
    ),

        /* ===================== Rate Info =====================- */
    'rate_info', JSON_OBJECT(
            'rate_rec_id', 					55,                                     '_comment_rate_rec_id', 'Rate record reference ID',
            'spot_rate', 					4433.85,                                 '_comment_spot_rate', 'Spot market rate',
            'currency_unit', 				'USD',                                  '_comment_currency_unit', 'Currency unit',
            'rate_source', 					'metals-api',                           '_comment_rate_source', 'Source of spot rate',
            'foreign_exchange_rate', 		278.50,                             	'_comment_foreign_exchange_rate', 'FX conversion rate',
            'foreign_exchange_source', 		'OpenExchange',                   		'_comment_foreign_exchange_source', 'FX rate source'
        ),

        /* ===================== Items Bought (Array) ===================== */
    'items_bought', JSON_ARRAY(
            JSON_OBJECT(
                'buy_item_id', 				1,                                    '_comment_buy_item_id', 'Bought item record ID',
                'buy_item_type', 			'Metal',                              '_comment_buy_item_type', 'Type of item purchased',
                'item_name', 				'Gold Bar',                            '_comment_item_name', 'Name of item',
                'item_quality', 			'24K',                                '_comment_item_quality', 'Purity or quality',
                'buy_weight', 				10.000,                               '_comment_buy_weight', 'Weight purchased',
                'premium', 					150.00,                                '_comment_premium', 'Premium charged',
                'net_amount', 				 45838.50,                            '_comment_net_amount', 'Final amount',
                'is_sliceable', 			 TRUE,                                '_comment_is_sliceable', 'Can item be sliced',
                'weight_sold', 				 0.000,                               '_comment_weight_sold', 'Weight sold',
                'weight_unit', 				'gram',                                '_comment_weight_unit', 'Unit of weight',
                'location', 				'Vault-A',                              '_comment_location', 'Storage or vault location'
            ),
               JSON_OBJECT(
                'buy_item_id', 				1,                                   '_comment_buy_item_id', 'Bought item record ID',
                'buy_item_type', 			'Metal',                             '_comment_buy_item_type', 'Type of item purchased',
                'item_name', 				'Gold Bar',                           '_comment_item_name', 'Name of item',
                'item_quality', 			'24K',                                '_comment_item_quality', 'Purity or quality',
                'buy_weight', 				10.000,                                '_comment_buy_weight', 'Weight purchased',
                'premium', 					150.00,                                '_comment_premium', 'Premium charged',
                'net_amount', 				45838.50,                              '_comment_net_amount', 'Final amount',
                'is_sliceable', 			TRUE,                                 '_comment_is_sliceable', 'Can item be sliced',
                'weight_sold', 				0.000,                                 '_comment_weight_sold', 'Weight sold',
                'weight_unit', 				'gram',                                '_comment_weight_unit', 'Unit of weight',
                'location', 				 'Vault-A',                           '_comment_location', 'Storage or vault location'
            )
        ),

        /* ===================== Item Bought From ===================== */
    'item_bought_from', JSON_OBJECT(
            'source_rec_id', 				  12,                                 '_comment_source_rec_id', 'Source record ID',
            'source_type', 					  'Vendor',                           '_comment_source_type', 'Vendor / Internal / Exchange',
            'source_name', 					  'Dubai Gold Market',                '_comment_source_name', 'Source name'
        ),

        /* ===================== Payment Credit Info ===================== */
    'payment_credit_info', JSON_OBJECT(
            'cash_manager_rec_id', 			5,                                 '_comment_cash_manager_rec_id', 'Cash manager reference',
            'credit_amount', 				45838.50,                          '_comment_credit_amount', 'Credit amount',
            'credit_payment_status', 		'PAID',                            '_comment_credit_payment_status', 'Payment status',
            'credit_payment_date', 			NOW(),                             '_comment_credit_payment_date', 'Payment date',
            'credit_balance_remaining', 	0.00,                             '_comment_credit_balance_remaining', 'Remaining credit balance'
        ),

        /* ===================== Item Sold ===================== */
    'item_sold', JSON_OBJECT(
            'sell_item_id',             NULL,                                '_comment_sell_item_id', 'Sold item ID',
            'item_name',                NULL,                                '_comment_item_name', 'Item name sold',
            'item_quality',            	NULL,                                 '_comment_item_quality', 'Item quality',
            'weight_sold',              0.000,                               '_comment_weight_sold', 'Weight sold',
            'premium', 					0.00,                                 '_comment_premium', 'Premium on sale',
            'net_amount', 				0.00,                                 '_comment_net_amount', 'Net sale amount'
        ),

       /* ===================== Item Sold To ===================== */
        'item_sold_to', JSON_OBJECT(
            'sell_to_rec_id', 			NULL,                                '_comment_sell_to_rec_id', 'Buyer record ID',
            'sell_to_type',             NULL,                                 '_comment_sell_to_type', 'Customer / Market',
            'sell_to_name',             NULL,                                 '_comment_sell_to_name', 'Buyer name'
        ),

       /* ===================== Payment Debit Info ===================== */
    'payment_debit_info', JSON_OBJECT(
            'cash_manager_rec_id',       5,                                   '_comment_cash_manager_rec_id', 'Cash manager ID',
            'payment_method',           'Cash',                               '_comment_payment_method', 'Payment method',
            'debit_amount',              0.00,                                '_comment_debit_amount', 'Debit amount',
            'debit_payment_status',     'NA',                                 '_comment_debit_payment_status', 'Debit status',
            'debit_payment_date',        NULL,                                '_comment_debit_payment_date', 'Debit date',
            'debit_balance_remaining',   0.00,                                '_comment_debit_balance_remaining', 'Remaining debit'
        ),

        /* ===================== Order Charges ===================== */
    'order_charges', JSON_OBJECT(
            'items_total_amount',       44338.50,                           '_comment_items_total_amount', 'Total items amount',
            'making_charges',           500.00,                             '_comment_making_charges', 'Making charges',
            'premium_charged',          150.00,                            '_comment_premium_charged', 'Premium charged',
            'transaction_fee',          50.00,                             '_comment_transaction_fee', 'Transaction fee',
            'processing_charges',       25.00,                              '_comment_processing_charges', 'Processing fee',
            'taxes',                    775.00,                             '_comment_taxes', 'Taxes applied',
            'taxes_description',       	'GST 18%',                          '_comment_taxes_description', 'Tax description',
            'total_discounts',          0.00,                               '_comment_total_discounts', 'Discounts applied',
            'total_order_amount',       45838.50,                           '_comment_total_order_amount', 'Final payable amount'
        ),

        /* ===================== Pickup Info ===================== */
    'order_pickup_info', JSON_OBJECT(
            'pickup_required',          TRUE,                                '_comment_pickup_required', 'Is pickup required',
            'store_address',            'Main Branch Karachi',               '_comment_store_address', 'Pickup location',
            'pickup_status',            'Pending',                           '_comment_pickup_status', 'Pickup status',
            'pickup_date',              NULL,                                '_comment_pickup_date', 'Pickup date',
            'pickup_tracking_number',   NULL,                                '_comment_pickup_tracking_number', 'Tracking number'
        ),

       /* ===================== Order Approval ===================== */
    'order_approval', JSON_OBJECT(
            'authentication_process_rec_id',      9,                        '_comment_authentication_process_rec_id', 'Auth process ID',
            'is_mfa',                             TRUE,                     '_comment_is_mfa', 'Multi-factor authentication used',
            'processed_at',                       NOW(),                    '_comment_processed_at', 'Processing timestamp',
            'cash_balance_before_transaction',    150000.00,                '_comment_cash_balance_before_transaction', 'Cash before',
            'cash_balance_after_transaction',     104161.50,                '_comment_cash_balance_after_transaction', 'Cash after',
            'product_weight_before_transaction',  0.000,                    '_comment_product_weight_before_transaction', 'Weight before',
            'product_weight_after_transaction',   10.000,                   '_comment_product_weight_after_transaction', 'Weight after',
            'approved_by_rec_id',                 3,                        '_comment_approved_by_rec_id', 'Approver ID',
            'approved_by_name',                   'Manager One',            '_comment_approved_by_name', 'Approver name',
            'approval_number',                    'APR-00045',              '_comment_approval_number', 'Approval reference',
            'approved_at',                        NOW(),                    '_comment_approved_at', 'Approval timestamp'
        ),

        /* ===================== Contract Info ===================== */
    'contract_info', JSON_OBJECT(
            'contract_number',                   'CNT-2026-009',           					'_comment_contract_number', 'Contract reference',
            'contract_executed_at',               NOW(),                                  '_comment_contract_executed_at', 'Execution date',
            'contract_terms_and_conditions',      'Standard bullion trading terms apply'
        )
    ),

    row_metadata         = JSON_OBJECT(
		    'created_at',                             NOW(3),
        'created_by',                             NULL,
        'updated_at',                             NULL,
        'updated_by',                             NULL,
        'status',                                 'Active'
    );


-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';



