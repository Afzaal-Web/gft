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
    next_action_required			ENUM('pending','approved', 'rejected', 'completed', 'failed'),
    order_cat 						ENUM('DO','IOC', 'GTC'),   											-- ('DO - day order','IOC - immediate or cancel', 'GTC - good till cancel')
    order_type 						ENUM('Buy','Sell', 'Exchange', 'Redeem')							NOT NULL,
    metal							VARCHAR(50),
    
    order_json			 			JSON,
    row_metadata 					JSON
);

-- ===============================================
-- Demo row: order_rec_id = 0
-- ===============================================

INSERT INTO orders
SET
	order_rec_id			= 0,
    customer_rec_id	        = 0,
    account_number        	= 'aaa000',
    order_number        	= '0000',
    receipt_number      	= '000',
    
    order_date          	= NOW(),
    order_status        	= 'pending',
    next_action_required	= 'approved',
    order_cat	          	= 'GTC',
    order_type		    	= 'Buy',
    metal					= 'Gold',

   order_json            	=  castJson('orders'),
   row_metadata         	=  castJson('row_metadata');


-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';



