CREATE DATABASE IF NOT EXISTS gft;
USE gft;
DROP DATABASE gft;

-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

-- Auth and customer Module Started

-- ===============================================
-- Corporate Account Table Started
-- ===============================================

DROP TABLE IF EXISTS corporate_account;
-- ===============================================
-- Create corporate_account table
-- ===============================================
CREATE TABLE IF NOT EXISTS corporate_account (
    corporate_account_rec_id 			INT 																		PRIMARY KEY AUTO_INCREMENT,
    main_account_num 					VARCHAR(15),
    main_account_title					VARCHAR(50),
    account_status 						ENUM('registration req', 'active', 'inactive', 'blocked')					NOT NULL,
    corporate_account_json 				JSON,
    row_metadata 						JSON
);

ALTER TABLE corporate_account
MODIFY account_status
ENUM('registration req', 'active', 'inactive', 'blocked')
NOT NULL;
-- ===============================================
-- Demo row: corporate_account_rec_id = 0
-- ===============================================
INSERT INTO corporate_account
SET
    corporate_account_rec_id   		= 0,
    main_account_num            	= '000',
    main_account_title              = NULL,
    account_status             		= 'inactive',
    corporate_account_json 			= castJson('corporate_account'),
    row_metadata              		= castJson('row_metadata');

-- ===============================================
-- Update Sample row with dummy data at row 0
-- ===============================================
UPDATE corporate_account
SET
corporate_account_json 			= castJson('corporate_account'),
row_metadata              		= castJson('row_metadata')
 WHERE corporate_account_rec_id = 0;
 
 -- ===============================================
-- update row with null values data
-- ===============================================
UPDATE corporate_account
SET
corporate_account_json 			= getTemplate('corporate_account'),
row_metadata              		= getTemplate('row_metadata')
WHERE corporate_account_rec_id = 0;
 

 
-- ===============================================
-- Corporate Account Table Ended
-- ===============================================

-- ===============================================
-- Customers Table started
-- ===============================================
DROP TABLE IF EXISTS customer;

CREATE TABLE IF NOT EXISTS customer (
    customer_rec_id 			INT 					PRIMARY KEY AUTO_INCREMENT,
    customer_status				ENUM					('active','inactive', 'registration_request', 'suspended'),
    customer_type 				ENUM					('personal','corporate'),
	corporate_account_rec_id  	INT NULL,
    
	first_name 					VARCHAR(100),
    last_name 					VARCHAR(100),
    user_name					VARCHAR(100),
    email						VARCHAR(50),
    phone						VARCHAR(20),
    whatsapp_num				VARCHAR(20),
    national_id					VARCHAR(50) 			UNIQUE,
    main_account_num			VARCHAR(50),
    account_num					VARCHAR(50),
    
    customer_json 				JSON,
    row_metadata				JSON,
    
    CONSTRAINT account_num_combination
    UNIQUE (main_account_num, account_num)
);

ALTER TABLE customer
MODIFY customer_status
ENUM('active','inactive','suspended')
NOT NULL;

-- ===============================================
-- Demo row: customer_rec_id = 0
-- ===============================================

INSERT INTO customer
SET
    customer_rec_id            				= 0,
    customer_status            				= 'active',
    customer_type              				= 'corporate',
    corporate_account_rec_id   				= 1,
    first_name                 				= 'John',
    last_name                  				= 'Doe',
	user_name								= 'john.doe123',
    email                  					= 'johndoe@gmail.com',
    phone	                  				= '+92301-1232123',
    whatsapp_num	                  		= '+92301-3212342',
    national_id                				= '331013434343433',
    main_account_num           				= 'AZS-001',
    account_num                				= '001',

    customer_json             				= castJson('customer'),
    row_metadata              				= castJson('row_metadata');

-- ===============================================
-- Update Sample row with dummy data at row 0
-- ===============================================
UPDATE customer
SET
customer_json             		= castJson('customer'),
row_metadata              		= castJson('row_metadata')
WHERE customer_rec_id = 0;

 -- ===============================================
-- update row with null values data
-- ===============================================
UPDATE customer
SET
customer_json 		 			= getTemplate('customer'),
row_metadata              		= getTemplate('row_metadata')
WHERE customer_rec_id = 0;
 


-- ===============================================
-- Auth table Started
-- ===============================================

DROP TABLE IF EXISTS auth;

-- ===============================================
-- Create auth table
-- ===============================================
CREATE TABLE IF NOT EXISTS auth (
    auth_rec_id 				INT 				PRIMARY KEY AUTO_INCREMENT,
    parent_table_name 			VARCHAR(50),
    parent_table_rec_id 		INT,
    user_name					VARCHAR(50),
    
    auth_json 					JSON,
    row_metadata 				JSON
);

-- ===============================================
-- Insert Demo row: auth_rec_id = 0
-- ===============================================
INSERT INTO auth
SET
    auth_rec_id               = 0,
    parent_table_name         = 'CUSTOMER',
    parent_table_rec_id       = 0,
    user_name				  = 'jhon@gmail.com',
    
    auth_json                 = castJson('auth'),
    row_metadata              = castJson('row_metadata');
  
-- ===============================================
-- Update Sample row with dummy data at row 0
-- ===============================================
UPDATE auth
SET
auth_json             				= castJson('auth'),
row_metadata              			= castJson('row_metadata')
WHERE auth_rec_id = 0;

-- ===============================================
-- update row with null values data
-- ===============================================
UPDATE auth
SET
auth_json 		 				= getTemplate('auth'),
row_metadata              		= getTemplate('row_metadata')
WHERE auth_rec_id = 0;
 


-- ===============================================
-- Auth table ended
-- ===============================================


-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';



-- ===============================================
-- account_seq table started
-- ===============================================

DROP TABLE seq_num;
CREATE TABLE seq_num (
    seq_id BIGINT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (seq_id)
) ENGINE=InnoDB;

CREATE TABLE seq_num (
    seq_rec_id        INT 					AUTO_INCREMENT PRIMARY KEY,
    column_name       VARCHAR(255) 			NOT NULL,
    sequence_value    VARCHAR(255) 			NOT NULL,
    requested_by	  VARCHAR(255) 			NOT NULL,
    created_at        DATETIME 				DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- password-history table started
-- ===============================================

DROP TABLE IF EXISTS password_history;

CREATE TABLE password_history (
    password_history_rec_id     	INT 				AUTO_INCREMENT PRIMARY KEY,
    parent_table_name				VARCHAR(255),
    parent_table_rec_id             INT,
    password_hash                	VARCHAR(255),		
    password_set_at            		DATETIME			DEFAULT CURRENT_TIMESTAMP,
    password_changed_by         	VARCHAR(50),
    password_change_reason      	VARCHAR(255),
    last_password_updated_at    	DATETIME			DEFAULT CURRENT_TIMESTAMP		ON UPDATE CURRENT_TIMESTAMP,
    password_expiration_date    	DATETIME,
    is_active                   	BOOLEAN
);


INSERT INTO password_history
SET
    password_history_rec_id   	= 0,
    parent_table_name         	= 'customer',
    parent_table_rec_id         = 0,
    password_hash       		= 'K9QpZzZxXxYyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRr',
    password_set_at				=  NOW(),
	password_changed_by   		= 'SYSTEM',
    password_change_reason      = 'Initial password setup',
    password_expiration_date    = DATE_ADD(NOW(), INTERVAL 90 DAY),
    is_active				  	= TRUE;

 
-- ===============================================
-- Restore default strict mode
-- ===============================================
SET SESSION sql_mode='STRICT_TRANS_TABLES';


