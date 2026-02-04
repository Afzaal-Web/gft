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
    status							VARCHAR(50),	
    account_num 					VARCHAR(50),																			
    request_type 					ENUM('deposit','withdraw')															NOT NULL,
    transaction_type 				ENUM('cash deposit','bank transfer', 'check deposit', 'e wallets', 'credit card')	NOT NULL,
    backoffice_post_number			VARCHAR(255),
    trans_posted_at 				DATETIME,

    money_manager_json			 	JSON,
    row_metadata 					JSON
);

-- to drop unique index from account_num

ALTER TABLE money_manager
DROP INDEX account_number;


-- ===============================================
-- Demo row: money_manager_rec_id = 0
-- ===============================================

INSERT INTO money_manager
SET
    money_manager_rec_id    =  0,
    customer_rec_id       	=  1,
    status					= 'INITIATED',
    account_num        		= 'CUS-001',
    request_type          	= 'Deposit',
    transaction_type      	= 'Bank Transfer',
	backoffice_post_number	= 'GFT-2026-0001',
    trans_posted_at			=  NOW(),

    money_manager_json      = castJson('money_manager'),
	row_metadata            = castJson('row_metadata');


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
    status					 VARCHAR(50),	
    account_num          	 VARCHAR(50),
    processor_name           VARCHAR(50),
    processor_token          VARCHAR(100),
    card_last_4              CHAR(4),
    trans_posted_at          DATETIME,
    backoffice_post_number   VARCHAR(20),
    
    credit_card_json         JSON,
    row_metadata             JSON
);

ALTER TABLE credit_card
DROP INDEX account_number;
-- ===============================================
-- Demo row: credit_card_rec_id   = 0
-- ===============================================

INSERT INTO credit_card
SET
	credit_card_rec_id      = 0,
    money_manager_rec_id    = 0,
    status					= 'INITIATED',
    account_num		        = 'AZS-001',
    processor_name          = 'Visa Processor',
    processor_token         = 'tok_1A2B3C4D5E6F',
    card_last_4             = '1234',
    trans_posted_at         = NOW(),
    backoffice_post_number  = 'BOP-2026-0005',

	credit_card_json		= castJson('credit_card'),
	row_metadata 			= castJson('row_metadata');




-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';