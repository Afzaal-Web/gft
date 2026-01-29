-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- Money Manager Module Started

-- ===============================================
-- Money Manger Table Started
-- ===============================================

DROP TABLE IF EXISTS money_manager;
-- ===============================================
-- Create money_manager table
-- ===============================================
CREATE TABLE IF NOT EXISTS money_manager (
    money_manager_rec_id			INT 																				PRIMARY KEY AUTO_INCREMENT,
    customer_rec_id					INT,														
    account_number 					VARCHAR(50)																			UNIQUE,
    request_type 					ENUM('deposit','withdraw')															NOT NULL,

    transaction_type 				ENUM('cash deposit','bank transfer', 'check deposit', 'e wallets', 'credit card')							NOT NULL,
    transaction_posted_at			DATETIME,    

    back_office_post_num			VARCHAR(50),
    
    money_manager_json			 	JSON,
    row_metadata 					JSON
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ===============================================
-- Demo row: money_manager_rec_id = 0
-- ===============================================

INSERT INTO money_manager
SET
    money_manager_rec_id    =  0,
    customer_rec_id       	=  1,
    account_number        	= 'CUS-001',
    request_type          	= 'Deposit',
    transaction_type      	= 'Bank Transfer',
    transaction_posted_at 	=  NOW(),
    back_office_post_num  	=  'GFT-2026-0001',

    money_manager_json      = JSON_OBJECT(
    'money_manager_rec_id',          0,
    'customer_rec_id',               1,
    'account_number',                'CUS-001',
    'request_type',                  'Deposit',
    'transaction_type',              'Bank Transfer',
    'transaction_posted_at',          NOW(),
    'back_office_post_num',           'GFT-2026-0001',

    'sender_info', JSON_OBJECT(
        'institution_name',           'Bank Al Habib',      		'_comment_institution_name',        'Name of sending institution',
        'account_holder_name',        'Ali Raza',           		'_comment_account_holder_name',     'Sender account holder name',
        'account_number',             'ACC-123456',         		'_comment_account_number',          'Sender account number',
        'amount_sent',                45838.50,             		'_comment_amount_sent',             'Amount sent by sender',
        'transaction_id',             'TXN-2026-001',       		'_comment_transaction_id',          'Transaction reference ID',
        'receipt_number',             'RCT-2026-0001',      		'_comment_receipt_number',          'Receipt number for the transaction',
        'receipt_picture_rec_id',      501,                 		'_comment_receipt_picture_rec_id',  'Reference ID for receipt picture',
        'trans_at',                   '2026-01-14 14:04:39',		'_comment_trans_at',                'Transaction timestamp'
    ),

    'receiver_info', JSON_OBJECT(
        'institution_name',           'Meezan Bank',        		'_comment_institution_name',        'Name of receiving institution',
        'account_holder_name',         'GFT Company',        		'_comment_account_holder_name',     'Receiver account holder name',
        'account_number',              'ACC-987654',        		 '_comment_account_number',          'Receiver account number',
        'amount_received',             45838.50,             		'_comment_amount_received',         'Amount received',
        'received_at',                 NOW(),                		'_comment_received_at',             'Timestamp when amount received',
        'processing_fee',              25.00,                		'_comment_processing_fee',          'Fee charged for processing'
    )
),

	row_metadata                 = JSON_OBJECT(
		'created_at',                    NOW(),
		'created_by',                    NULL,
		'updated_at',                    NULL,
		'updated_by',                    NULL,
		'status',                        'Active'
);


-- ===============================================
-- money_manager table ended
-- ===============================================

-- ===============================================
-- credit_card table started
-- ===============================================

DROP TABLE IF EXISTS credit_card;

CREATE TABLE IF NOT EXISTS credit_card (
    credit_card_rec_id       INT                                 PRIMARY KEY AUTO_INCREMENT,
    money_manager_rec_id     INT,
    account_number           VARCHAR(50)					     UNIQUE,
    trans_posted_at          DATETIME,
    backoffice_post_number   VARCHAR(20),
    processor_name           VARCHAR(50),
    processor_token          VARCHAR(100),
    card_last_4              CHAR(4),
    
    card_json                JSON,
    row_metadata             JSON
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===============================================
-- Demo row: credit_card_rec_id   = 0
-- ===============================================

INSERT INTO credit_card
SET
	credit_card_rec_id      = 0,
    money_manager_rec_id    = 0,
    account_number          = 'AZS-001',
    trans_posted_at         = NOW(),
    backoffice_post_number  = 'BOP-2026-0005',
    processor_name          = 'Visa Processor',
    processor_token         = 'tok_1A2B3C4D5E6F',
    card_last_4             = '1234',

card_json = JSON_OBJECT(
    'credit_card_rec_id', 		0,
    'money_manager_rec_id', 	0,
    'account_number', 			'CUS-001',
    'trans_posted_at', 			NOW(),
    'backoffice_post_number',	'BOP-2026-0005',
    'processor_name', 			'Visa Processor',
    'processor_token',			'tok_1A2B3C4D5E6F',
    'card_last_4',				'1234',

    /* ===================== Card Info ===================== */
    'card_info', JSON_OBJECT(
        'card_type', 			'Visa',                  '_comment_card_type', 'Type of card: Visa, Mastercard, etc.',
        'card_number',           '**** **** **** 1234',    '_comment_card_number', 'Masked card number',
        'card_holder_name',      'Ali Raza',              '_comment_card_holder_name', 'Name on card',
        'card_expiration_date',  '12/2028',               '_comment_card_expiration_date', 'Card expiry date',
        'cvv2',                  '932',                   '_comment_cvv2', 'Masked CVV2'
    ),

    /* ===================== Billing Address ===================== */
    'billing_address', JSON_OBJECT(
        'billing_country',      'Pakistan',               '_comment_billing_country', 'Country for billing',
        'billing_address1',     'Shahrah-e-Faisal',       '_comment_billing_address1', 'Primary billing address line',
        'billing_address2',      'Business Plaza',         '_comment_billing_address2', 'Secondary billing address line',
        'billing_city',          'Karachi',                '_comment_billing_city', 'Billing city',
        'billing_state',         'Sindh',                  '_comment_billing_state', 'Billing state or province',
        'billing_zip_code',      '75400',                  '_comment_billing_zip_code', 'Billing postal code'
    ),

    /* ===================== Bank Approval ===================== */
    'bank_approval', JSON_OBJECT(
        'approval_number',       'APR-00077',              '_comment_approval_number', 'Bank approval reference',
        'approval_at',            NOW(),                    '_comment_approval_at', 'Approval timestamp',
        'settlement_amount',      45838.50,                 '_comment_settlement_amount', 'Settled amount',
        'settlement_date',        NOW(),                    '_comment_settlement_date', 'Settlement date'
    )
),

row_metadata = JSON_OBJECT(
    'created_at',               NOW(3),
    'created_by',               NULL,
    'updated_at',               NULL,
    'updated_by',               NULL,
    'status',                   'Active'
);




-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';