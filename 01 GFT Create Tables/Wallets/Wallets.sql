-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- Wallet Module Started

-- ===============================================
-- tradable_assets Table Started
-- ===============================================

DROP TABLE IF EXISTS tradable_assets;
-- ===============================================
-- Create tradable_assets table
-- ===============================================
CREATE TABLE IF NOT EXISTS tradable_assets (
    tradable_assets_rec_id          		INT                         PRIMARY KEY AUTO_INCREMENT,
    asset_name            					VARCHAR(50),
    short_name              				VARCHAR(20),                          
    asset_code            					VARCHAR(10),					
    asset_intl_code         				VARCHAR(10),
    asset_type              				VARCHAR(20),
    forex_code    							VARCHAR(20),
    available_to_customers  				BOOLEAN,
    
    tradable_assets_json     				JSON,
    row_metadata		      				JSON
);

-- ===============================================
-- Demo row: tradable_assets_rec_id = 0
-- ===============================================

INSERT INTO tradable_assets
SET
    tradable_assets_rec_id      = 0,
    asset_name            		= 'GOLD',
    short_name             		= 'gold',
    asset_code             		= 'gld',
    asset_intl_code        		= 'XAU',
    asset_type             		= 'Metal',
    forex_code             		= 'XAU',
    available_to_customers 		= TRUE,

	tradable_assets_json 		= castJson('tradable_assets'),
	row_metadata 				= castJson('row_metadata');

-- ===============================================
-- tradable_assets table ended
-- ===============================================

-- ===============================================
-- asset_rate_history table started
-- ===============================================

DROP TABLE IF EXISTS asset_rate_history;

CREATE TABLE IF NOT EXISTS asset_rate_history (
    asset_rate_rec_id        	 INT                              PRIMARY KEY AUTO_INCREMENT,
    tradable_assets_rec_id		 INT,
    asset_code             		 VARCHAR(10),                                   
    rate_timestamp               TIMESTAMP                        DEFAULT CURRENT_TIMESTAMP,
    
    asset_rate_history_json      JSON,
    row_metadata                 JSON
);

-- ===============================================
-- Demo row: asset_rate_history_rec_id   = 0
-- ===============================================

INSERT INTO asset_rate_history
SET
	asset_rate_rec_id      		= 0,
    tradable_assets_rec_id  	= 0,           
    asset_code             		= 'XAU',        
    rate_timestamp         		= CURRENT_TIMESTAMP,
    
	asset_rate_history_json		= castJson('asset_rate_history'),
	row_metadata 				= castJson('row_metadata');

-- ===============================================
-- asset_rate_historyEnded
-- ===============================================

-- ===============================================
-- Wallet_Ledger table started
-- ===============================================

DROP TABLE IF EXISTS wallet_ledger;

CREATE TABLE IF NOT EXISTS wallet_ledger (
    wallet_ledger_rec_id            INT                     PRIMARY KEY AUTO_INCREMENT,
    customer_rec_id                 INT,
    account_number                  VARCHAR(100),
    wallet_id                       VARCHAR(100),
    wallet_title                    VARCHAR(100),
    asset_code                      VARCHAR(10),
    asset_name                      VARCHAR(50),
    order_rec_id                    INT,
    order_number                    VARCHAR(50),
    transaction_number              VARCHAR(50),
    transaction_type                VARCHAR(20),
    
    wallet_ledger_json              JSON,
    row_metadata                    JSON
);

-- ===============================================
-- Demo row: wallet_ledger_rec_id   = 0
-- ===============================================

INSERT INTO wallet_ledger
SET
	wallet_ledger_rec_id   	= 0,
    customer_rec_id        	= 0,
    account_number         	= 'ACC123456',
    wallet_id              	= 'WALLET001',
    wallet_title           	= 'Main Trading Wallet',
    asset_code             	= 'XAU',
    asset_name             	= 'Gold',
    order_rec_id           	= 5001,
    order_number           	= 'ORD5001',
    transaction_number     	= 'TXN10001',
    transaction_type       	= 'buy',
    
    wallet_ledger_json     = castJson('wallet_ledger'),
    row_metadata 		   = castJson('row_metadata');
    
-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';